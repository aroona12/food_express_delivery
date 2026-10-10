import 'dart:async';
import 'package:foodexpressdelivery/features/auth/data/auth_exception.dart';
import 'package:foodexpressdelivery/features/auth/data/auth_repository.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';

/// In-memory fake implementation of [AuthRepository] for widget and unit testing.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({UserModel? initialUser}) : _currentUser = initialUser;

  UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();

  @override
  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (password == 'wrongpassword') {
      throw const AuthException('Incorrect email or password.', code: 'invalid-credentials');
    }

    final user = UserModel(
      id: 'test-user-id',
      email: email,
      name: 'Test Customer',
      role: UserRole.customer,
    );
    _currentUser = user;
    _authStateController.add(_currentUser);
    return user;
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email == 'existing@test.com') {
      throw const AuthException('An account with this email already exists.', code: 'email-already-in-use');
    }

    final user = UserModel(
      id: 'new-user-id',
      email: email,
      name: name,
      role: UserRole.customer,
    );
    _currentUser = user;
    _authStateController.add(_currentUser);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (email == 'invalid@test.com') {
      throw const AuthException('Please enter a valid email address.', code: 'invalid-email');
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  void setUser(UserModel? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  void dispose() {
    _authStateController.close();
  }
}
