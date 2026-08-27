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
