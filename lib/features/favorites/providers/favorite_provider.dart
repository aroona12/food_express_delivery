import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../restaurant/models/restaurant_model.dart';
import '../../restaurant/providers/restaurant_provider.dart';
import '../data/favorite_repository.dart';
import '../data/firestore_favorite_repository.dart';
import '../models/favorite_model.dart';

/// Provider exposing the [FavoriteRepository] singleton for the app session.
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FirestoreFavoriteRepository();
});

/// State notifier managing the set of favorited restaurant IDs for the active user.
class FavoriteController extends StateNotifier<Set<String>> {
  FavoriteController({
    required this.repository,
    required this.userId,
  }) : super(<String>{}) {
    if (userId != null && userId!.isNotEmpty) {
      loadFavorites();
    }
  }

  final FavoriteRepository repository;
  final String? userId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Loads all favorites for the current user from the repository.
  Future<void> loadFavorites() async {
    final uid = userId;
    if (uid == null || uid.isEmpty) {
      state = <String>{};
      return;
    }

    _isLoading = true;
    try {
      final favorites = await repository.getFavorites(uid);
      final repoIds = favorites.map((f) => f.restaurantId).toSet();
      state = Set<String>.from(state)..addAll(repoIds);
    } catch (_) {
      // Keep existing state on failure
    } finally {
      _isLoading = false;
    }
  }

  /// Toggles favorite status for a restaurant with optimistic state update.
  Future<bool> toggleFavorite(String restaurantId) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) return false;

    final wasFavorite = state.contains(restaurantId);
    final previousState = Set<String>.from(state);

    // Optimistic UI update
    if (wasFavorite) {
      state = Set<String>.from(state)..remove(restaurantId);
    } else {
      state = Set<String>.from(state)..add(restaurantId);
    }

    try {
      final isNowFavorite = await repository.toggleFavorite(uid, restaurantId);
      // Ensure state matches repository response
      if (isNowFavorite) {
        state = Set<String>.from(state)..add(restaurantId);
      } else {
        state = Set<String>.from(state)..remove(restaurantId);
      }
      return isNowFavorite;
    } catch (e) {
      // Revert to previous state on error
      state = previousState;
      rethrow;
    }
  }

  /// Explicitly adds a restaurant to favorites.
  Future<void> addFavorite(String restaurantId) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) return;

    if (!state.contains(restaurantId)) {
      state = Set<String>.from(state)..add(restaurantId);
      try {
        await repository.addFavorite(uid, restaurantId);
      } catch (_) {
        state = Set<String>.from(state)..remove(restaurantId);
        rethrow;
      }
    }
  }

  /// Explicitly removes a restaurant from favorites.
  Future<void> removeFavorite(String restaurantId) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) return;

    if (state.contains(restaurantId)) {
      state = Set<String>.from(state)..remove(restaurantId);
      try {
        await repository.removeFavorite(uid, restaurantId);
      } catch (_) {
        state = Set<String>.from(state)..add(restaurantId);
        rethrow;
      }
    }
  }
}

/// Riverpod provider for [FavoriteController] scoped to the current authenticated user.
final favoriteControllerProvider =
    StateNotifierProvider<FavoriteController, Set<String>>((ref) {
  final repository = ref.watch(favoriteRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return FavoriteController(
    repository: repository,
    userId: user?.id,
  );
});

/// Exposes the set of favorited restaurant IDs for the current user.
final favoriteIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(favoriteControllerProvider);
});

/// Family provider checking if a specific [restaurantId] is in the customer's favorites.
final isFavoriteProvider =
    Provider.family<bool, String>((ref, restaurantId) {
  final favoriteIds = ref.watch(favoriteIdsProvider);
  return favoriteIds.contains(restaurantId);
});

/// Future provider fetching the raw [FavoriteModel] records for the current user.
final userFavoritesProvider =
    FutureProvider<List<FavoriteModel>>((ref) async {
  final repository = ref.watch(favoriteRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final uid = user?.id;
  if (uid == null || uid.isEmpty) return [];
  return repository.getFavorites(uid);
});

/// Future provider resolving full [RestaurantModel] objects for all favorited restaurants.
final favoriteRestaurantsProvider =
    FutureProvider<List<RestaurantModel>>((ref) async {
  final favoriteIds = ref.watch(favoriteIdsProvider);
  if (favoriteIds.isEmpty) return [];

  final restaurantRepo = ref.watch(restaurantRepositoryProvider);
  final allRestaurants = await restaurantRepo.getRestaurants();

  return allRestaurants.where((r) => favoriteIds.contains(r.id)).toList();
});
