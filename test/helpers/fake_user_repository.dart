import 'dart:async';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/profile/data/user_repository.dart';

/// In-memory fake implementation of [UserRepository] for unit and widget testing.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({Map<String, UserModel>? initialUsers}) {
    if (initialUsers != null) {
      _users.addAll(initialUsers);
    }
  }

  final Map<String, UserModel> _users = {};
  final Map<String, StreamController<UserModel?>> _controllers = {};

  StreamController<UserModel?> _getController(String uid) {
    return _controllers.putIfAbsent(uid, () => StreamController<UserModel?>.broadcast());
  }

  @override
  Stream<UserModel?> watchUserProfile(String uid) async* {
    yield _users[uid];
    yield* _getController(uid).stream;
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    return _users[uid];
  }

  @override
  Future<void> createUserProfile(UserModel user) async {
    _users[user.id] = user;
    _getController(user.id).add(user);
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    _users[user.id] = user;
    _getController(user.id).add(user);
  }

  @override
  Future<void> updateFields({
    required String uid,
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) async {
    if (uid == 'error-uid') {
      throw Exception('Simulated Firestore error');
    }

    final existing = _users[uid] ??
        UserModel(
          id: uid,
          email: 'test@foodexpress.com',
          name: 'Default Customer',
        );

    final updated = existing.copyWith(
      name: name ?? existing.name,
      phone: phone ?? existing.phone,
      address: address ?? existing.address,
      profileImageUrl: profileImageUrl ?? existing.profileImageUrl,
    );

    _users[uid] = updated;
    _getController(uid).add(updated);
  }

  @override
  Future<void> updateFcmToken({
    required String uid,
    required String token,
  }) async {
    final existing = _users[uid];
    if (existing != null) {
      final updated = existing.copyWith(fcmToken: token);
      _users[uid] = updated;
      _getController(uid).add(updated);
    }
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
  }
}
