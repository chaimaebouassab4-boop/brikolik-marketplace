import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'notification_service.dart';

class AuthServiceException implements Exception {
  final String code;
  final String message;

  const AuthServiceException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'AuthServiceException($code): $message';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedFullName = fullName.trim();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: trimmedPassword,
    );

    final user = credential.user;
    if (user == null) {
      throw const AuthServiceException(
        code: 'auth-user-null',
        message: 'Inscription impossible. Veuillez reessayer.',
      );
    }

    try {
      final isAdminEmail = await _isAdminEmail(trimmedEmail);
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': trimmedEmail,
        'fullName': trimmedFullName,
        'createdAt': Timestamp.now(),
        'isVerified': isAdminEmail,
        'verificationRequested': false,
        'verificationStatus': isAdminEmail ? 'approved' : 'pending',
        if (isAdminEmail) 'role': 'admin',
        if (isAdminEmail) 'verifiedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      await _rollbackSignupUser(user);
      throw AuthServiceException(
        code: e.code,
        message: _firestoreSignupErrorMessage(e),
      );
    } catch (_) {
      await _rollbackSignupUser(user);
      throw const AuthServiceException(
        code: 'profile-write-failed',
        message:
            'Compte cree mais profil non enregistre. Le compte a ete annule, reessayez.',
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = credential.user;
    if (user != null) {
      await _ensureAdminRoleIfWhitelisted(user);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw const AuthServiceException(
            code: 'google-cancelled',
            message: 'Connexion Google annulee.',
          );
        }

        final googleAuth = await googleUser.authentication;
        final googleCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        credential = await _auth.signInWithCredential(googleCredential);
      }

      final user = credential.user;
      if (user == null) {
        throw const AuthServiceException(
          code: 'auth-user-null',
          message: 'Connexion Google impossible. Reessayez.',
        );
      }

      await _upsertUserProfile(user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthServiceException(
        code: e.code,
        message: _firebaseGoogleErrorMessage(e),
      );
    } catch (e) {
      if (e is AuthServiceException) rethrow;
      throw const AuthServiceException(
        code: 'google-signin-failed',
        message: 'Connexion Google impossible pour le moment.',
      );
    }
  }

  /// Retourne le rÃ´le de l'utilisateur connectÃ© ('customer' | 'worker' | null).
  /// Retourne null en cas d'erreur (permissions, rÃ©seau, etc.) sans crasher.
  Future<String?> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return doc.data()?['role'] as String?;
    } catch (e) {
      debugPrint('getUserRole error (ignored): $e');
      return null; // redirige vers /role par dÃ©faut
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      debugPrint('getCurrentUserProfile error (ignored): $e');
      return null;
    }
  }

  Future<bool> isCurrentUserVerified() async {
    final profile = await getCurrentUserProfile();
    return profile?['isVerified'] == true;
  }

  Future<bool> isCurrentUserAdmin() async {
    final profile = await getCurrentUserProfile();
    return profile?['role'] == 'admin';
  }

  Future<void> requestIdentityVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthServiceException(
        code: 'auth-user-null',
        message: 'Vous devez etre connecte pour envoyer la demande.',
      );
    }

    await _db.collection('users').doc(user.uid).set({
      'verificationRequested': true,
      'verificationRequestedAt': FieldValue.serverTimestamp(),
      'isVerified': false,
      'verificationStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final requesterProfile = await getCurrentUserProfile();
    final requesterName = (requesterProfile?['fullName'] as String?)?.trim();
    final requesterLabel = (requesterName != null && requesterName.isNotEmpty)
        ? requesterName
        : (user.email ?? user.uid);

    final adminEmails = await _getAdminEmails();
    if (adminEmails.isNotEmpty) {
      await _queueEmail(
        to: adminEmails,
        subject: 'Nouvelle demande de verification Brikolik',
        text:
            'Une demande de verification a ete envoyee par $requesterLabel (${user.email ?? 'email indisponible'}).',
      );
    }
  }

  Future<void> updateUserVerificationStatus({
    required String userId,
    required bool approved,
    String? rejectionReason,
  }) async {
    final adminUser = _auth.currentUser;
    if (adminUser == null) {
      throw const AuthServiceException(
        code: 'auth-user-null',
        message: 'Session admin invalide.',
      );
    }

    final userRef = _db.collection('users').doc(userId);
    final userSnapshot = await userRef.get();
    if (!userSnapshot.exists) {
      throw const AuthServiceException(
        code: 'user-not-found',
        message: 'Utilisateur introuvable.',
      );
    }

    final userData = userSnapshot.data() ?? const <String, dynamic>{};
    final userEmail = (userData['email'] as String?)?.trim();
    final userName = (userData['fullName'] as String?)?.trim();
    final userRole = (userData['role'] as String?)?.trim();

    await userRef.set({
      'isVerified': approved,
      'verificationRequested': false,
      'verificationStatus': approved ? 'approved' : 'rejected',
      'verificationReason':
          approved ? FieldValue.delete() : (rejectionReason ?? ''),
      'verifiedAt':
          approved ? FieldValue.serverTimestamp() : FieldValue.delete(),
      'rejectedAt':
          approved ? FieldValue.delete() : FieldValue.serverTimestamp(),
      'verifiedBy': adminUser.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (userEmail != null && userEmail.isNotEmpty) {
      final displayName =
          (userName != null && userName.isNotEmpty) ? userName : userEmail;
      await _queueEmail(
        to: <String>[userEmail],
        subject: approved
            ? 'Verification approuvee - Brikolik'
            : 'Verification refusee - Brikolik',
        text: approved
            ? 'Bonjour $displayName, votre compte Brikolik est maintenant approuve.'
            : 'Bonjour $displayName, votre demande de verification a ete refusee. ${rejectionReason?.trim().isNotEmpty == true ? 'Raison: ${rejectionReason!.trim()}' : ''}',
      );
    }

    if (approved && userRole == 'worker') {
      try {
        await NotificationService.notifyWorkerProfileApproved(
          workerId: userId,
        );
      } catch (e) {
        debugPrint('Profile approval notification failed: $e');
      }
    }
  }

  Future<void> _rollbackSignupUser(User user) async {
    try {
      await user.delete();
    } catch (_) {}

    try {
      await _auth.signOut();
    } catch (_) {}
  }

  Future<void> _upsertUserProfile(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    final email = (user.email ?? '').trim();
    final isAdminEmail = await _isAdminEmail(email);

    await userRef.set({
      'uid': user.uid,
      'email': email,
      'fullName': (user.displayName ?? '').trim(),
      'photoUrl': user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'isVerified': false,
      if (!snapshot.exists) 'verificationRequested': false,
      if (!snapshot.exists) 'verificationStatus': 'pending',
      if (isAdminEmail) 'role': 'admin',
      if (isAdminEmail) 'isVerified': true,
      if (isAdminEmail) 'verificationRequested': false,
      if (isAdminEmail) 'verificationStatus': 'approved',
      if (isAdminEmail) 'verifiedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> _isAdminEmail(String? email) async {
    final normalized = (email ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return false;

    try {
      final doc = await _db.collection('admin_emails').doc(normalized).get();
      return doc.exists;
    } catch (e) {
      debugPrint('isAdminEmail error (ignored): $e');
      return false;
    }
  }

  Future<void> _ensureAdminRoleIfWhitelisted(User user) async {
    final email = (user.email ?? '').trim();
    final isAdminEmail = await _isAdminEmail(email);
    if (!isAdminEmail) return;

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'role': 'admin',
      'isVerified': true,
      'verificationRequested': false,
      'verificationStatus': 'approved',
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<String>> _getAdminEmails() async {
    try {
      final query =
          await _db.collection('users').where('role', isEqualTo: 'admin').get();

      final emails = query.docs
          .map((doc) => (doc.data()['email'] as String?)?.trim() ?? '')
          .where((email) => email.isNotEmpty)
          .toSet()
          .toList();

      return emails;
    } catch (e) {
      debugPrint('getAdminEmails error (ignored): $e');
      return <String>[];
    }
  }

  Future<void> _queueEmail({
    required List<String> to,
    required String subject,
    required String text,
  }) async {
    if (to.isEmpty) return;

    try {
      await _db.collection('mail').add({
        'to': to,
        'message': <String, dynamic>{
          'subject': subject,
          'text': text,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Optional email queue: do not block user/admin flows if not configured.
      debugPrint('queueEmail error (ignored): $e');
    }
  }

  String _firestoreSignupErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Inscription bloquee: Firestore refuse la creation du profil. Le compte a ete annule.';
      default:
        return 'Compte cree mais profil non enregistre. Le compte a ete annule, reessayez.';
    }
  }

  String _firebaseGoogleErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Connexion Google annulee.';
      case 'account-exists-with-different-credential':
        return 'Un compte existe deja avec un autre mode de connexion.';
      case 'operation-not-allowed':
        return 'Google Sign-In est desactive dans Firebase Auth.';
      case 'invalid-credential':
        return 'Configuration Google invalide. Verifiez SHA-1/SHA-256 dans Firebase.';
      default:
        return 'Connexion Google impossible. Reessayez.';
    }
  }
}
