import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/restaurant_repository.dart';
import '../models/food_item_model.dart';
import '../models/restaurant_model.dart';

/// Exposes the [RestaurantRepository] instance. Overridable in widget and unit tests.
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return MockRestaurantRepository();
});

/// Holds the active search query for restaurant discovery on the Home screen.
final restaurantSearchQueryProvider = StateProvider<String>((ref) => '');

/// Holds the selected category/cuisine filter for restaurant discovery on the Home screen.
final restaurantCategoryFilterProvider = StateProvider<String>((ref) => 'all');

/// Fetches the complete list of all restaurants.
final restaurantListProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getRestaurants();
});

/// Fetches restaurants dynamically based on active search query and category filter.
final filteredRestaurantsProvider =
    FutureProvider<List<RestaurantModel>>((ref) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  final query = ref.watch(restaurantSearchQueryProvider);
  final category = ref.watch(restaurantCategoryFilterProvider);

  return repository.getRestaurants(
    category: category,
    query: query,
  );
});

/// Fetches a specific restaurant by its unique [restaurantId].
final restaurantByIdProvider =
    FutureProvider.family<RestaurantModel?, String>((ref, restaurantId) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getRestaurantById(restaurantId);
});

/// Fetches all food items for a specific [restaurantId].
final foodItemsProvider =
    FutureProvider.family<List<FoodItemModel>, String>((ref, restaurantId) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getFoodItems(restaurantId);
});

/// Retrieves available menu categories for a specific [restaurantId].
final menuCategoriesProvider =
    FutureProvider.family<List<String>, String>((ref, restaurantId) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  return repository.getMenuCategories(restaurantId);
});

/// Holds the currently selected menu category on the restaurant details screen for a specific [restaurantId].
final selectedMenuCategoryProvider =
    StateProvider.family<String, String>((ref, restaurantId) => 'All');

/// Fetches menu food items for a specific [restaurantId], filtered by the currently selected menu category.
final filteredFoodItemsProvider =
    FutureProvider.family<List<FoodItemModel>, String>((ref, restaurantId) async {
  final repository = ref.watch(restaurantRepositoryProvider);
  final selectedCategory = ref.watch(selectedMenuCategoryProvider(restaurantId));

  return repository.getFoodItemsByCategory(restaurantId, selectedCategory);
});
