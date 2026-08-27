import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';

void main() {
  const testFoodItem = FoodItemModel(
    id: 'food-1',
    restaurantId: 'rest-1',
    name: 'Truffle Smash Burger',
    description: 'Double patty with house truffle sauce.',
    imageUrl: 'https://example.com/burger.jpg',
    price: 14.50,
    category: 'Burgers',
    isAvailable: true,
  );

  group('CartItemModel Unit Tests', () {
    test('constructs with default quantity and calculates subtotal accurately', () {
      const cartItem = CartItemModel(foodItem: testFoodItem);

      expect(cartItem.id, 'food-1');
      expect(cartItem.foodItemId, 'food-1');
      expect(cartItem.restaurantId, 'rest-1');
      expect(cartItem.name, 'Truffle Smash Burger');
      expect(cartItem.imageUrl, 'https://example.com/burger.jpg');
      expect(cartItem.unitPrice, 14.50);
      expect(cartItem.quantity, 1);
      expect(cartItem.subtotal, 14.50);
      expect(cartItem.formattedUnitPrice, '\$14.50');
      expect(cartItem.formattedSubtotal, '\$14.50');
    });

    test('multi-quantity subtotal calculation', () {
      const cartItem = CartItemModel(foodItem: testFoodItem, quantity: 3);

      expect(cartItem.quantity, 3);
      expect(cartItem.subtotal, 43.50);
      expect(cartItem.formattedSubtotal, '\$43.50');
    });

    test('copyWith modifies quantity and foodItem correctly', () {
      const cartItem = CartItemModel(foodItem: testFoodItem, quantity: 2);
      final updated = cartItem.copyWith(quantity: 5);

      expect(updated.quantity, 5);
      expect(updated.subtotal, 72.50);
      expect(updated.foodItem, testFoodItem);
    });

    test('supports value equality and hash code', () {
      const itemA = CartItemModel(foodItem: testFoodItem, quantity: 2);
      const itemB = CartItemModel(foodItem: testFoodItem, quantity: 2);
      const itemC = CartItemModel(foodItem: testFoodItem, quantity: 3);

      expect(itemA, equals(itemB));
      expect(itemA.hashCode, equals(itemB.hashCode));
      expect(itemA, isNot(equals(itemC)));
    });

    test('serializes toMap and deserializes fromMap', () {
      const cartItem = CartItemModel(foodItem: testFoodItem, quantity: 2);
      final map = cartItem.toMap();
      final fromMap = CartItemModel.fromMap(map);

      expect(fromMap, equals(cartItem));
      expect(fromMap.subtotal, 29.00);
    });
  });
}
