import 'dart:async';
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

  /// Streams real-time updates for all menu food items belonging to [restaurantId].
  Stream<List<FoodItemModel>> watchFoodItems(String restaurantId);

  /// Streams real-time updates for a single restaurant identified by [restaurantId].
  Stream<RestaurantModel?> watchRestaurantById(String restaurantId);

  /// Updates the open/closed availability status for a restaurant.
  Future<void> updateRestaurantOpenStatus(String restaurantId, bool isOpen);

  /// Updates owner-editable profile and settings metadata for a restaurant.
  Future<void> updateRestaurantProfile(
    String restaurantId,
    RestaurantModel restaurant,
  );

  /// Creates a new menu food item under `restaurants/{restaurantId}/menu_items`.
  /// Returns the newly created food item's unique identifier.
  Future<String> createFoodItem(String restaurantId, FoodItemModel item);

  /// Updates all mutable fields of an existing menu food item.
  Future<void> updateFoodItem(String restaurantId, FoodItemModel item);

  /// Deletes a menu food item document identified by [foodItemId].
  Future<void> deleteFoodItem(String restaurantId, String foodItemId);

  /// Updates only the [isAvailable] stock toggle of a menu food item.
  Future<void> updateFoodItemAvailability(
    String restaurantId,
    String foodItemId,
    bool isAvailable,
  );
}

/// In-memory mock implementation of [RestaurantRepository] for Day 4.
class MockRestaurantRepository implements RestaurantRepository {
  MockRestaurantRepository({
    List<RestaurantModel>? restaurants,
    List<FoodItemModel>? foodItems,
    this.simulatedDelay = Duration.zero,
  })  : _restaurants = List<RestaurantModel>.from(restaurants ?? RestaurantMockData.mockRestaurants),
        _foodItems = List<FoodItemModel>.from(foodItems ?? RestaurantMockData.mockFoodItems);

  final List<RestaurantModel> _restaurants;
  final List<FoodItemModel> _foodItems;
  final Duration simulatedDelay;

  final Map<String, StreamController<RestaurantModel?>> _restaurantControllers = {};
  final Map<String, StreamController<List<FoodItemModel>>> _foodItemsControllers = {};

  StreamController<RestaurantModel?> _getRestaurantController(String id) {
    return _restaurantControllers.putIfAbsent(
      id,
      () => StreamController<RestaurantModel?>.broadcast(),
    );
  }

  StreamController<List<FoodItemModel>> _getFoodItemsController(String restaurantId) {
    return _foodItemsControllers.putIfAbsent(
      restaurantId,
      () => StreamController<List<FoodItemModel>>.broadcast(),
    );
  }

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
  Stream<RestaurantModel?> watchRestaurantById(String restaurantId) async* {
    final initial = await getRestaurantById(restaurantId);
    yield initial;
    yield* _getRestaurantController(restaurantId).stream;
  }

  @override
  Future<void> updateRestaurantOpenStatus(String restaurantId, bool isOpen) async {
    await _delayIfNeeded();
    final index = _restaurants.indexWhere((r) => r.id == restaurantId);
    if (index != -1) {
      final updated = _restaurants[index].copyWith(isOpen: isOpen);
      _restaurants[index] = updated;
      _getRestaurantController(restaurantId).add(updated);
    }
  }

  @override
  Future<void> updateRestaurantProfile(
    String restaurantId,
    RestaurantModel restaurant,
  ) async {
    await _delayIfNeeded();
    final index = _restaurants.indexWhere((r) => r.id == restaurantId);
    if (index != -1) {
      final existing = _restaurants[index];
      final updated = existing.copyWith(
        name: restaurant.name,
        description: restaurant.description,
        cuisine: restaurant.cuisine,
        address: restaurant.address,
        deliveryTime: restaurant.deliveryTime,
        deliveryFee: restaurant.deliveryFee,
        imageUrl: restaurant.imageUrl,
        isOpen: restaurant.isOpen,
      );
      _restaurants[index] = updated;
      _getRestaurantController(restaurantId).add(updated);
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
  Stream<List<FoodItemModel>> watchFoodItems(String restaurantId) async* {
    final initial = await getFoodItems(restaurantId);
    yield initial;
    yield* _getFoodItemsController(restaurantId).stream;
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

  @override
  Future<String> createFoodItem(String restaurantId, FoodItemModel item) async {
    await _delayIfNeeded();
    final newId = item.id.isNotEmpty
        ? item.id
        : 'item_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = item.copyWith(id: newId, restaurantId: restaurantId);
    _foodItems.add(newItem);
    _getFoodItemsController(restaurantId).add(
      _foodItems.where((i) => i.restaurantId == restaurantId).toList(),
    );
    return newId;
  }

  @override
  Future<void> updateFoodItem(String restaurantId, FoodItemModel item) async {
    await _delayIfNeeded();
    final index = _foodItems.indexWhere(
      (i) => i.id == item.id && i.restaurantId == restaurantId,
    );
    if (index != -1) {
      _foodItems[index] = item;
      _getFoodItemsController(restaurantId).add(
        _foodItems.where((i) => i.restaurantId == restaurantId).toList(),
      );
    }
  }

  @override
  Future<void> deleteFoodItem(String restaurantId, String foodItemId) async {
    await _delayIfNeeded();
    _foodItems.removeWhere(
      (i) => i.id == foodItemId && i.restaurantId == restaurantId,
    );
    _getFoodItemsController(restaurantId).add(
      _foodItems.where((i) => i.restaurantId == restaurantId).toList(),
    );
  }

  @override
  Future<void> updateFoodItemAvailability(
    String restaurantId,
    String foodItemId,
    bool isAvailable,
  ) async {
    await _delayIfNeeded();
    final index = _foodItems.indexWhere(
      (i) => i.id == foodItemId && i.restaurantId == restaurantId,
    );
    if (index != -1) {
      _foodItems[index] = _foodItems[index].copyWith(isAvailable: isAvailable);
      _getFoodItemsController(restaurantId).add(
        _foodItems.where((i) => i.restaurantId == restaurantId).toList(),
      );
    }
  }

  void dispose() {
    for (final controller in _restaurantControllers.values) {
      controller.close();
    }
    for (final controller in _foodItemsControllers.values) {
      controller.close();
    }
  }
}

