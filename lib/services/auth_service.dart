import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Retourne le rôle de l'utilisateur connecté ('customer' | 'worker' | null).
  /// Retourne null en cas d'erreur (permissions, réseau, etc.) sans crasher.
  Future<String?> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return doc.data()?['role'] as String?;
    } catch (e) {
      print('getUserRole error (ignored): $e');
      return null; // redirige vers /role par défaut
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

  String _firestoreSignupErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Inscription bloquee: Firestore refuse la creation du profil. Le compte a ete annule.';
      default:
        return 'Compte cree mais profil non enregistre. Le compte a ete annule, reessayez.';
    }
  }
}
