import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize();
      _isInitialized = true;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return false;
    }
  }

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      lastError = null;
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      lastError = '${e.code}: ${e.message}';
      debugPrint('Email/Password Sign-In Error: $lastError');
      return false;
    } catch (e) {
      lastError = 'unknown: $e';
      debugPrint('Error during Email/Password Sign-In: $e');
      return false;
    }
  }

  String? lastError;

  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      lastError = null;
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      lastError = '${e.code}: ${e.message}';
      debugPrint('Email/Password Sign-Up Error: $lastError');
      return false;
    } catch (e) {
      lastError = 'unknown: $e';
      debugPrint('Error during Email/Password Sign-Up: $e');
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Password Reset Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error during Password Reset: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
