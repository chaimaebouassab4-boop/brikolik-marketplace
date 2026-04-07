import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': trimmedEmail,
        'fullName': trimmedFullName,
        'createdAt': Timestamp.now(),
        'isVerified': false,
        'verificationRequested': false,
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
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
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
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

    await userRef.set({
      'uid': user.uid,
      'email': user.email ?? '',
      'fullName': (user.displayName ?? '').trim(),
      'photoUrl': user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'isVerified': false,
      if (!snapshot.exists) 'verificationRequested': false,
    }, SetOptions(merge: true));
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
