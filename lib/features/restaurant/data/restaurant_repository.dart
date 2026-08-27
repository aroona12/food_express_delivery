import '../../../../core/mock/restaurant_mock_data.dart';
import '../models/food_item_model.dart';
import '../models/restaurant_model.dart';

/// Abstract contract for restaurant discovery and menu browsing operations.
///
/// Decoupled from any specific data source (e.g. Mock Data or Cloud Firestore).
abstract class RestaurantRepository {
  /// Fetches a list of restaurants, optionally filtered by category or search query.
  Future<List<RestaurantModel>> getRestaurants({
    String? category,
    String? query,
  });

  /// Fetches a single restaurant by its unique [id]. Returns null if not found.
  Future<RestaurantModel?> getRestaurantById(String id);

  /// Fetches all menu food items for the given [restaurantId].
  Future<List<FoodItemModel>> getFoodItems(String restaurantId);

  /// Fetches menu food items for a specific restaurant and category.
  Future<List<FoodItemModel>> getFoodItemsByCategory(
    String restaurantId,
    String category,
  );

  /// Retrieves the distinct list of menu categories available for a restaurant.
  Future<List<String>> getMenuCategories(String restaurantId);
}

/// In-memory mock implementation of [RestaurantRepository] for Day 4.
class MockRestaurantRepository implements RestaurantRepository {
  MockRestaurantRepository({
    List<RestaurantModel>? restaurants,
    List<FoodItemModel>? foodItems,
    this.simulatedDelay = Duration.zero,
  })  : _restaurants = restaurants ?? RestaurantMockData.mockRestaurants,
        _foodItems = foodItems ?? RestaurantMockData.mockFoodItems;

  final List<RestaurantModel> _restaurants;
  final List<FoodItemModel> _foodItems;
  final Duration simulatedDelay;

  Future<void> _delayIfNeeded() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
  }

  @override
  Future<List<RestaurantModel>> getRestaurants({
    String? category,
    String? query,
  }) async {
    await _delayIfNeeded();
    List<RestaurantModel> result = List.unmodifiable(_restaurants);

    // Filter by category / cuisine
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      final cat = category.toLowerCase();
      result = result.where((r) {
        return r.cuisine.toLowerCase().contains(cat) ||
            r.name.toLowerCase().contains(cat);
      }).toList();
    }

    // Filter by search query (name or cuisine)
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((r) {
        return r.name.toLowerCase().contains(q) ||
            r.cuisine.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  @override
  Future<RestaurantModel?> getRestaurantById(String id) async {
    await _delayIfNeeded();
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FoodItemModel>> getFoodItems(String restaurantId) async {
    await _delayIfNeeded();
    return _foodItems
        .where((item) => item.restaurantId == restaurantId)
        .toList();
  }

  @override
  Future<List<FoodItemModel>> getFoodItemsByCategory(
    String restaurantId,
    String category,
  ) async {
    await _delayIfNeeded();
    final items = _foodItems.where((item) => item.restaurantId == restaurantId);

    if (category.isEmpty || category.toLowerCase() == 'all') {
      return items.toList();
    }

    return items
        .where((item) => item.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<String>> getMenuCategories(String restaurantId) async {
    await _delayIfNeeded();
    final items = _foodItems.where((item) => item.restaurantId == restaurantId);
    final categories = <String>{'All'};

    for (final item in items) {
      categories.add(item.category);
    }

    return categories.toList();
  }
}
