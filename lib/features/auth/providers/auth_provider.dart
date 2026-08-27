import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_exception.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

/// Provider for accessing the [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Stream provider that emits authentication state changes in real time.
///
/// Used by [GoRouter] for route protection and anywhere in the app
/// that needs to react to login/logout events.
final authStateChangesProvider = StreamProvider<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider for accessing the currently authenticated [UserModel] synchronously.
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull;
});

/// State notifier managing the execution state (idle, loading, error, success)
/// of authentication actions such as Login, Register, and Password Reset.
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  final AuthRepository _authRepository;

  /// Signs in a user with email and password.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      final error = e is AuthException ? e : AuthException(e.toString());
      state = AsyncValue.error(error, st);
      return false;
    }
  }

  /// Registers a new customer account.
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      final error = e is AuthException ? e : AuthException(e.toString());
      state = AsyncValue.error(error, st);
      return false;
    }
  }

  /// Sends a password reset email.
  Future<bool> sendPasswordResetEmail({
    required String email,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      final error = e is AuthException ? e : AuthException(e.toString());
      state = AsyncValue.error(error, st);
      return false;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      final error = e is AuthException ? e : AuthException(e.toString());
      state = AsyncValue.error(error, st);
    }
  }

  /// Clears any lingering error state.
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

/// Provider for [AuthController] to drive UI actions and progress indicators.
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});
