import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';

void main() {
  late MockRestaurantRepository repository;

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
    const FoodItemModel(
      id: 'item-3',
      restaurantId: 'rest-2',
      name: 'Margherita Pizza',
      description: 'Classic pizza',
      imageUrl: 'https://example.com/item3.jpg',
      price: 18.99,
      category: 'Pizza',
      isAvailable: true,
    ),
  ];

  setUp(() {
    repository = MockRestaurantRepository(
      restaurants: sampleRestaurants,
      foodItems: sampleFoodItems,
    );
  });

  group('MockRestaurantRepository Tests', () {
    test('getRestaurants returns all restaurants when no filter is provided', () async {
      final list = await repository.getRestaurants();
      expect(list.length, 2);
      expect(list.first.name, 'The Burger Studio');
    });

    test('getRestaurants filters by category/cuisine', () async {
      final burgers = await repository.getRestaurants(category: 'burgers');
      expect(burgers.length, 1);
      expect(burgers.first.id, 'rest-1');

      final pizza = await repository.getRestaurants(category: 'Pizza');
      expect(pizza.length, 1);
      expect(pizza.first.id, 'rest-2');

      final all = await repository.getRestaurants(category: 'all');
      expect(all.length, 2);
    });

    test('getRestaurants filters by query search string', () async {
      final searchResult = await repository.getRestaurants(query: 'Napoli');
      expect(searchResult.length, 1);
      expect(searchResult.first.name, 'Napoli Artisan Pizzeria');

      final emptyResult = await repository.getRestaurants(query: 'NonExistentFood');
      expect(emptyResult, isEmpty);
    });

    test('getRestaurantById returns matching restaurant or null if not found', () async {
      final found = await repository.getRestaurantById('rest-1');
      expect(found, isNotNull);
      expect(found!.name, 'The Burger Studio');

      final notFound = await repository.getRestaurantById('invalid-id');
      expect(notFound, isNull);
    });

    test('getFoodItems returns all items for given restaurantId', () async {
      final items1 = await repository.getFoodItems('rest-1');
      expect(items1.length, 2);

      final items2 = await repository.getFoodItems('rest-2');
      expect(items2.length, 1);
      expect(items2.first.name, 'Margherita Pizza');

      final empty = await repository.getFoodItems('unknown-restaurant');
      expect(empty, isEmpty);
    });

    test('getFoodItemsByCategory filters food items by category', () async {
      final burgers = await repository.getFoodItemsByCategory('rest-1', 'Burgers');
      expect(burgers.length, 1);
      expect(burgers.first.name, 'Truffle Burger');

      final all = await repository.getFoodItemsByCategory('rest-1', 'All');
      expect(all.length, 2);
    });

    test('getMenuCategories returns distinct list including "All"', () async {
      final categories = await repository.getMenuCategories('rest-1');
      expect(categories, containsAll(['All', 'Burgers', 'Sides']));
      expect(categories.length, 3);
    });

    test('createFoodItem adds new item and assigns ID if empty', () async {
      const newItem = FoodItemModel(
        id: '',
        restaurantId: 'rest-1',
        name: 'Crispy Wings',
        description: 'Spicy buffalo wings',
        imageUrl: 'https://example.com/wings.jpg',
        price: 11.99,
        category: 'Sides',
      );

      final createdId = await repository.createFoodItem('rest-1', newItem);
      expect(createdId, isNotEmpty);

      final items = await repository.getFoodItems('rest-1');
      expect(items.length, 3);
      expect(items.any((i) => i.id == createdId && i.name == 'Crispy Wings'), isTrue);
    });

    test('updateFoodItem modifies existing food item', () async {
      final existing = (await repository.getFoodItems('rest-1')).first;
      final updated = existing.copyWith(
        name: 'Truffle Bacon Burger Deluxe',
        price: 17.99,
      );

      await repository.updateFoodItem('rest-1', updated);

      final items = await repository.getFoodItems('rest-1');
      final found = items.firstWhere((i) => i.id == existing.id);
      expect(found.name, 'Truffle Bacon Burger Deluxe');
      expect(found.price, 17.99);
    });

    test('deleteFoodItem removes specific food item', () async {
      final initialCount = (await repository.getFoodItems('rest-1')).length;
      await repository.deleteFoodItem('rest-1', 'item-1');

      final items = await repository.getFoodItems('rest-1');
      expect(items.length, initialCount - 1);
      expect(items.any((i) => i.id == 'item-1'), isFalse);
    });

    test('updateFoodItemAvailability changes isAvailable status', () async {
      final item = (await repository.getFoodItems('rest-1')).firstWhere((i) => i.id == 'item-1');
      expect(item.isAvailable, isTrue);

      await repository.updateFoodItemAvailability('rest-1', 'item-1', false);

      final updated = (await repository.getFoodItems('rest-1')).firstWhere((i) => i.id == 'item-1');
      expect(updated.isAvailable, isFalse);
    });

    test('updateRestaurantProfile updates editable profile fields and preserves system fields', () async {
      final existing = await repository.getRestaurantById('rest-1');
      expect(existing, isNotNull);
      expect(existing!.name, 'The Burger Studio');
      expect(existing.rating, 4.8);
      expect(existing.reviewCount, 300);

      final updatedProfile = existing.copyWith(
        name: 'The Burger Studio & Grill',
        description: 'Artisanal burgers and barbecue',
        cuisine: 'Gourmet Burgers • BBQ',
        address: '999 Market Way',
        deliveryTime: '15-25 min',
        deliveryFee: '\$2.49',
        imageUrl: 'https://example.com/new-burger.jpg',
        isOpen: false,
        // Attempting to change system-controlled fields in input model
        rating: 5.0,
        reviewCount: 9999,
        featuredBadge: 'Hacked Badge',
      );

      await repository.updateRestaurantProfile('rest-1', updatedProfile);

      final result = await repository.getRestaurantById('rest-1');
      expect(result, isNotNull);
      // Editable fields are updated
      expect(result!.name, 'The Burger Studio & Grill');
      expect(result.description, 'Artisanal burgers and barbecue');
      expect(result.cuisine, 'Gourmet Burgers • BBQ');
      expect(result.address, '999 Market Way');
      expect(result.deliveryTime, '15-25 min');
      expect(result.deliveryFee, '\$2.49');
      expect(result.imageUrl, 'https://example.com/new-burger.jpg');
      expect(result.isOpen, isFalse);
      // System-controlled fields are preserved from existing
      expect(result.rating, 4.8);
      expect(result.reviewCount, 300);
      expect(result.id, 'rest-1');
    });
  });
}


