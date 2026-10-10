import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';

void main() {
  const testItem = FoodItemModel(
    id: 'item-101',
    restaurantId: 'rest-1',
    name: 'Truffle Umami Smash Burger',
    description: 'Double Angus beef patties, aged white cheddar, black truffle garlic aioli.',
    imageUrl: 'https://example.com/item.jpg',
    price: 15.99,
    category: 'Burgers',
    isAvailable: true,
    rating: 4.9,
    calories: 820,
  );

  group('FoodItemModel Tests', () {
    test('formattedPrice formats price with dollar sign and two decimal places', () {
      expect(testItem.formattedPrice, '\$15.99');

      const item2 = FoodItemModel(
        id: 'item-2',
        restaurantId: 'rest-1',
        name: 'Soda',
        description: 'Drink',
        imageUrl: '',
        price: 3.5,
        category: 'Drinks',
      );
      expect(item2.formattedPrice, '\$3.50');
    });

    test('toMap converts model into valid map', () {
      final map = testItem.toMap();

      expect(map['id'], 'item-101');
      expect(map['restaurantId'], 'rest-1');
      expect(map['name'], 'Truffle Umami Smash Burger');
      expect(map['price'], 15.99);
      expect(map['category'], 'Burgers');
      expect(map['isAvailable'], true);
      expect(map['rating'], 4.9);
      expect(map['calories'], 820);
    });

    test('fromMap parses map accurately with optional fields', () {
      final map = {
        'restaurantId': 'rest-2',
        'name': 'Fries',
        'description': 'Crispy fries',
        'imageUrl': 'https://example.com/fries.jpg',
        'price': 4.49,
        'category': 'Sides',
        'isAvailable': false,
      };

      final item = FoodItemModel.fromMap(map, 'item-202');

      expect(item.id, 'item-202');
      expect(item.name, 'Fries');
      expect(item.isAvailable, false);
      expect(item.rating, isNull);
      expect(item.calories, isNull);
    });

    test('fromMap parses dish-1, dish-2, dish-3 test payloads correctly', () {
      final dish1Data = {
        'id': 'dish-1',
        'restaurantId': 'rest-test-1',
        'name': 'Classic Cheeseburger',
        'description': 'Angus beef patty, cheddar cheese, crisp lettuce, tomato, and house special sauce.',
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
        'price': 9.99,
        'category': 'Burgers',
        'isAvailable': true,
        'rating': 4.9,
        'calories': 650,
      };
      final dish1 = FoodItemModel.fromMap(dish1Data, 'dish-1');
      expect(dish1.id, 'dish-1');
      expect(dish1.restaurantId, 'rest-test-1');
      expect(dish1.name, 'Classic Cheeseburger');
      expect(dish1.price, 9.99);
      expect(dish1.formattedPrice, '\$9.99');
      expect(dish1.category, 'Burgers');
      expect(dish1.isAvailable, true);
      expect(dish1.rating, 4.9);
      expect(dish1.calories, 650);

      final dish2Data = {
        'id': 'dish-2',
        'restaurantId': 'rest-test-1',
        'name': 'Crispy Loaded Fries',
        'description': 'Golden skin-on fries topped with melted cheddar cheese and smoky paprika.',
        'imageUrl': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=800',
        'price': 4.99,
        'category': 'Sides',
        'isAvailable': true,
        'rating': 4.7,
        'calories': 420,
      };
      final dish2 = FoodItemModel.fromMap(dish2Data, 'dish-2');
      expect(dish2.id, 'dish-2');
      expect(dish2.price, 4.99);

      final dish3Data = {
        'id': 'dish-3',
        'restaurantId': 'rest-test-1',
        'name': 'Vanilla Bean Milkshake',
        'description': 'Creamy artisanal milkshake made with pure Madagascar vanilla and whole milk.',
        'imageUrl': 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=800',
        'price': 3.99,
        'category': 'Drinks',
        'isAvailable': true,
        'rating': 4.8,
        'calories': 380,
      };
      final dish3 = FoodItemModel.fromMap(dish3Data, 'dish-3');
      expect(dish3.id, 'dish-3');
      expect(dish3.price, 3.99);
    });

    test('copyWith creates modified clone', () {
      final updated = testItem.copyWith(
        isAvailable: false,
        price: 16.99,
      );

      expect(updated.id, testItem.id);
      expect(updated.isAvailable, false);
      expect(updated.price, 16.99);
      expect(updated.name, testItem.name);
    });

    test('equality and toString work properly', () {
      const duplicate = FoodItemModel(
        id: 'item-101',
        restaurantId: 'rest-1',
        name: 'Truffle Umami Smash Burger',
        description: 'Double Angus beef patties, aged white cheddar, black truffle garlic aioli.',
        imageUrl: 'https://example.com/item.jpg',
        price: 15.99,
        category: 'Burgers',
        isAvailable: true,
        rating: 4.9,
        calories: 820,
      );

      expect(testItem, equals(duplicate));
      expect(testItem.hashCode, equals(duplicate.hashCode));
      expect(testItem.toString(), contains('Truffle Umami Smash Burger'));
    });
  });
}
