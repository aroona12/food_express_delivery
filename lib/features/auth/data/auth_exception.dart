import 'package:firebase_auth/firebase_auth.dart';

/// Represents a standardized, human-readable authentication error.
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  /// Translates raw Firebase error codes into friendly user messages.
  factory AuthException.fromFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return const AuthException(
          'Incorrect email or password. Please check your credentials and try again.',
          code: 'invalid-credentials',
        );
      case 'email-already-in-use':
        return const AuthException(
          'An account with this email already exists. Please sign in instead.',
          code: 'email-already-in-use',
        );
      case 'invalid-email':
        return const AuthException(
          'Please enter a valid email address.',
          code: 'invalid-email',
        );
      case 'weak-password':
        return const AuthException(
          'Your password is too weak. Please use at least 6 characters.',
          code: 'weak-password',
        );
      case 'user-disabled':
        return const AuthException(
          'This user account has been disabled. Please contact support.',
          code: 'user-disabled',
        );
      case 'operation-not-allowed':
        return const AuthException(
          'Email/Password sign-in is not enabled. Please contact administrator.',
          code: 'operation-not-allowed',
        );
      case 'network-request-failed':
        return const AuthException(
          'Network connection error. Please verify your internet connection.',
          code: 'network-request-failed',
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many failed attempts. Please wait a moment before trying again.',
          code: 'too-many-requests',
        );
      default:
        return AuthException(
          e.message ?? 'An unexpected authentication error occurred. Please try again.',
          code: e.code,
        );
    }
  }

  @override
  String toString() => message;
}
