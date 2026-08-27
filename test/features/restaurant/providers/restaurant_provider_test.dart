import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/providers/restaurant_provider.dart';

void main() {
  late MockRestaurantRepository fakeRepository;

  final sampleRestaurants = [
    const RestaurantModel(
      id: 'rest-1',
      name: 'The Burger Studio',
      description: 'Gourmet burgers',
      imageUrl: 'https://example.com/1.jpg',
      rating: 4.8,
      reviewCount: 300,
      deliveryTime: '20 min',
      deliveryFee: 'Free',
      cuisine: 'Gourmet Burgers • American',
      isOpen: true,
      address: '123 Main St',
    ),
    const RestaurantModel(
      id: 'rest-2',
      name: 'Napoli Artisan Pizzeria',
      description: 'Wood-fired Pizza',
      imageUrl: 'https://example.com/2.jpg',
      rating: 4.9,
      reviewCount: 500,
      deliveryTime: '30 min',
      deliveryFee: '\$1.99',
      cuisine: 'Italian • Pizza',
      isOpen: true,
      address: '456 Italian Way',
    ),
  ];

  final sampleFoodItems = [
    const FoodItemModel(
      id: 'item-1',
      restaurantId: 'rest-1',
      name: 'Truffle Burger',
      description: 'Delicious burger',
      imageUrl: 'https://example.com/item1.jpg',
      price: 15.99,
      category: 'Burgers',
      isAvailable: true,
    ),
    const FoodItemModel(
      id: 'item-2',
      restaurantId: 'rest-1',
      name: 'Parmesan Fries',
      description: 'Crispy fries',
      imageUrl: 'https://example.com/item2.jpg',
      price: 5.99,
      category: 'Sides',
      isAvailable: true,
    ),
  ];

  setUp(() {
    fakeRepository = MockRestaurantRepository(
      restaurants: sampleRestaurants,
      foodItems: sampleFoodItems,
    );
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        restaurantRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Restaurant Riverpod Providers Tests', () {
    test('restaurantListProvider emits full restaurant list', () async {
      final container = createContainer();
      final restaurants = await container.read(restaurantListProvider.future);

      expect(restaurants.length, 2);
      expect(restaurants[0].name, 'The Burger Studio');
      expect(restaurants[1].name, 'Napoli Artisan Pizzeria');
    });

    test('filteredRestaurantsProvider reacts to search query and category filter', () async {
      final container = createContainer();

      // Initial state with default query ('') and category ('all')
      var filtered = await container.read(filteredRestaurantsProvider.future);
      expect(filtered.length, 2);

      // Change category filter
      container.read(restaurantCategoryFilterProvider.notifier).state = 'pizza';
      filtered = await container.read(filteredRestaurantsProvider.future);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'rest-2');

      // Change search query
      container.read(restaurantCategoryFilterProvider.notifier).state = 'all';
      container.read(restaurantSearchQueryProvider.notifier).state = 'Burger';
      filtered = await container.read(filteredRestaurantsProvider.future);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'rest-1');
    });

    test('restaurantByIdProvider loads single restaurant by ID', () async {
      final container = createContainer();
      final restaurant = await container.read(restaurantByIdProvider('rest-1').future);

      expect(restaurant, isNotNull);
      expect(restaurant!.name, 'The Burger Studio');

      final nonExistent = await container.read(restaurantByIdProvider('invalid').future);
      expect(nonExistent, isNull);
    });

    test('foodItemsProvider and filteredFoodItemsProvider return items and respond to category changes', () async {
      final container = createContainer();
      final allItems = await container.read(foodItemsProvider('rest-1').future);
      expect(allItems.length, 2);

      // Default filtered is 'All'
      var filteredItems = await container.read(filteredFoodItemsProvider('rest-1').future);
      expect(filteredItems.length, 2);

      // Change selected category
      container.read(selectedMenuCategoryProvider('rest-1').notifier).state = 'Burgers';
      filteredItems = await container.read(filteredFoodItemsProvider('rest-1').future);
      expect(filteredItems.length, 1);
      expect(filteredItems.first.name, 'Truffle Burger');
    });

    test('menuCategoriesProvider extracts category list with "All"', () async {
      final container = createContainer();
      final categories = await container.read(menuCategoriesProvider('rest-1').future);

      expect(categories, containsAll(['All', 'Burgers', 'Sides']));
    });
  });
}
