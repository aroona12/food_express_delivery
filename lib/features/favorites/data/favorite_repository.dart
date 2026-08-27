import '../models/favorite_model.dart';

/// Abstract contract for customer favorite restaurant operations.
///
/// Decoupled from backend and storage SDKs (e.g. Cloud Firestore).
abstract class FavoriteRepository {
  /// Fetches all favorites for a specific [userId].
  Future<List<FavoriteModel>> getFavorites(String userId);

  /// Checks if a specific [restaurantId] is in the customer's favorites.
  Future<bool> isFavorite(String userId, String restaurantId);

  /// Adds a restaurant to the customer's favorites.
  Future<void> addFavorite(String userId, String restaurantId);

  /// Removes a restaurant from the customer's favorites.
  Future<void> removeFavorite(String userId, String restaurantId);

  /// Toggles favorite status for a restaurant. Returns the new favorite state (`true` if favorited, `false` otherwise).
  Future<bool> toggleFavorite(String userId, String restaurantId);
}

/// In-memory mock implementation of [FavoriteRepository] for Day 6.
class MockFavoriteRepository implements FavoriteRepository {
  MockFavoriteRepository({
    Map<String, List<FavoriteModel>>? initialData,
    this.simulatedDelay = Duration.zero,
  }) : _userFavorites = initialData != null
            ? initialData.map((k, v) => MapEntry(k, List<FavoriteModel>.from(v)))
            : <String, List<FavoriteModel>>{};

  final Map<String, List<FavoriteModel>> _userFavorites;
  final Duration simulatedDelay;

  Future<void> _delayIfNeeded() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
  }

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    await _delayIfNeeded();
    final list = _userFavorites[userId] ?? [];
    return List.unmodifiable(list);
  }

  @override
  Future<bool> isFavorite(String userId, String restaurantId) async {
    await _delayIfNeeded();
    final list = _userFavorites[userId] ?? [];
    return list.any((fav) => fav.restaurantId == restaurantId);
  }

  @override
  Future<void> addFavorite(String userId, String restaurantId) async {
    await _delayIfNeeded();
    final list = _userFavorites.putIfAbsent(userId, () => <FavoriteModel>[]);
    if (!list.any((fav) => fav.restaurantId == restaurantId)) {
      list.add(
        FavoriteModel(
          restaurantId: restaurantId,
          userId: userId,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> removeFavorite(String userId, String restaurantId) async {
    await _delayIfNeeded();
    final list = _userFavorites[userId];
    if (list != null) {
      list.removeWhere((fav) => fav.restaurantId == restaurantId);
    }
  }

  @override
  Future<bool> toggleFavorite(String userId, String restaurantId) async {
    await _delayIfNeeded();
    final isFav = await isFavorite(userId, restaurantId);
    if (isFav) {
      await removeFavorite(userId, restaurantId);
      return false;
    } else {
      await addFavorite(userId, restaurantId);
      return true;
    }
  }
}
