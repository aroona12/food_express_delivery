import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/user_repository.dart';

/// Provider for accessing the [UserRepository] instance.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository();
});

/// StreamProvider that emits real-time Firestore profile changes for the currently authenticated user.
final userProfileStreamProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(currentUserProvider);
  if (authUser == null) {
    return Stream.value(null);
  }

  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.watchUserProfile(authUser.id);
});

/// Provider exposing the current user profile, preferring the real-time Firestore data
/// and falling back to basic Firebase Auth details while initial data is fetching.
final userProfileProvider = Provider<UserModel?>((ref) {
  final firestoreProfileAsync = ref.watch(userProfileStreamProvider);
  final authUser = ref.watch(currentUserProvider);

  final firestoreUser = firestoreProfileAsync.valueOrNull;
  if (firestoreUser != null) {
    return firestoreUser;
  }

  return authUser;
});

/// State notifier managing the execution state (idle, loading, error, success)
/// of profile updates and mutations.
class UserController extends StateNotifier<AsyncValue<void>> {
  UserController(this._userRepository) : super(const AsyncValue.data(null));

  final UserRepository _userRepository;

  /// Updates profile attributes (name, phone, address) in Cloud Firestore.
  Future<bool> updateProfile({
    required String uid,
    required String name,
    String? phone,
    String? address,
    String? profileImageUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateFields(
        uid: uid,
        name: name,
        phone: phone,
        address: address,
        profileImageUrl: profileImageUrl,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Creates or merges an initial profile document in Firestore.
  Future<bool> initializeProfile(UserModel user) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.createUserProfile(user);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Clears any error state.
  void clearError() {
    if (state.hasError) {
      state = const AsyncValue.data(null);
    }
  }
}

/// Provider for [UserController] to manage profile update requests and loading states.
final userControllerProvider =
    StateNotifierProvider<UserController, AsyncValue<void>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserController(userRepository);
});
