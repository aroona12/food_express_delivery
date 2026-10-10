import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/user_model.dart';

/// Abstract contract for user profile persistence operations.
///
/// Keeps presentation logic and Riverpod controllers completely decoupled
/// from direct Cloud Firestore SDK dependencies.
abstract class UserRepository {
  /// Emits real-time updates for the customer profile identified by [uid].
  Stream<UserModel?> watchUserProfile(String uid);

  /// Retrieves the customer profile identified by [uid] once.
  Future<UserModel?> getUserProfile(String uid);

  /// Creates or initializes a new customer profile at `users/{user.id}`.
  Future<void> createUserProfile(UserModel user);

  /// Updates all mutable fields of an existing customer profile.
  Future<void> updateUserProfile(UserModel user);

  /// Partially updates specific profile fields (name, phone, address, profileImageUrl).
  Future<void> updateFields({
    required String uid,
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
  });

  /// Updates or registers the FCM push notification token for the user.
  Future<void> updateFcmToken({
    required String uid,
    required String token,
  });
}

/// Production implementation of [UserRepository] using Cloud Firestore.
///
/// Stores user documents under collection `users/{firebaseAuthUid}`.
class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  final FirebaseFirestore? _customFirestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  static const String collectionName = 'users';

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(collectionName).doc(uid);

  @override
  Stream<UserModel?> watchUserProfile(String uid) {
    if (uid.isEmpty) return Stream.value(null);

    return _userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      final data = snapshot.data()!;
      // Ensure the id field matches the document uid if missing
      data['id'] = data['id'] ?? snapshot.id;
      return UserModel.fromMap(data);
    });
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    if (uid.isEmpty) return null;

    try {
      final doc = await _userDoc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      final data = doc.data()!;
      data['id'] = data['id'] ?? doc.id;
      return UserModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<void> createUserProfile(UserModel user) async {
    try {
      final data = user.toMap();
      await _userDoc(user.id).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      final data = user.toMap();
      await _userDoc(user.id).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> updateFields({
    required String uid,
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name.trim();
      if (phone != null) updates['phone'] = phone.trim();
      if (address != null) updates['address'] = address.trim();
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl.trim();

      if (updates.isEmpty) return;

      await _userDoc(uid).set(updates, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile details: $e');
    }
  }

  @override
  Future<void> updateFcmToken({
    required String uid,
    required String token,
  }) async {
    if (uid.isEmpty || token.isEmpty) return;
    try {
      await _userDoc(uid).set({'fcmToken': token.trim()}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update FCM device token: $e');
    }
  }
}
