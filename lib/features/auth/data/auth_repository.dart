import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user_model.dart';
import 'auth_exception.dart';

/// Abstract contract defining all authentication operations for FoodExpress.
///
/// This isolates the UI and presentation controllers from any direct
/// dependency on Firebase Authentication.
abstract class AuthRepository {
  /// Stream emitting the currently authenticated [UserModel] or null.
  Stream<UserModel?> get authStateChanges;

  /// Returns the current authenticated [UserModel] synchronously, if available.
  UserModel? get currentUser;

  /// Authenticates a user with email and password.
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registers a new customer account with email, password, and display name.
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  /// Sends a password reset email to the given address.
  Future<void> sendPasswordResetEmail({required String email});

  /// Signs the currently authenticated user out.
  Future<void> signOut();
}

/// Firebase implementation of [AuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((fbUser) {
      if (fbUser == null) return null;
      return UserModel.fromFirebaseUser(fbUser);
    });
  }

  @override
  UserModel? get currentUser {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return UserModel.fromFirebaseUser(fbUser);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('User could not be found after sign-in.');
      }

      return UserModel.fromFirebaseUser(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Failed to create account.');
      }

      // Update Firebase display name
      final trimmedName = name.trim();
      if (trimmedName.isNotEmpty) {
        await user.updateDisplayName(trimmedName);
        await user.reload();
      }

      final createdUser = UserModel.fromFirebaseUser(
        _firebaseAuth.currentUser ?? user,
        name: trimmedName,
        createdAt: DateTime.now(),
      );

      // Store initial customer profile in Firestore at users/{firebaseAuthUid}
      try {
        await _firestore
            .collection('users')
            .doc(createdUser.id)
            .set(createdUser.toMap(), SetOptions(merge: true));
      } catch (_) {
        // Do not block auth flow if firestore sync encounters transient network issue
      }

      return createdUser;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to log out: $e');
    }
  }
}
