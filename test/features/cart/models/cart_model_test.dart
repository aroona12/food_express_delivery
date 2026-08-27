import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';

void main() {
  const item1 = FoodItemModel(
    id: 'food-1',
    restaurantId: 'rest-1',
    name: 'Truffle Smash Burger',
    description: 'Double patty.',
    imageUrl: 'https://example.com/item1.jpg',
    price: 15.00,
    category: 'Burgers',
  );

  const item2 = FoodItemModel(
    id: 'food-2',
    restaurantId: 'rest-1',
    name: 'Seasoned Fries',
    description: 'Crispy fries.',
    imageUrl: 'https://example.com/item2.jpg',
    price: 5.00,
    category: 'Sides',
  );

  group('CartModel Unit Tests', () {
    test('initializes empty cart with zero calculations', () {
      const emptyCart = CartModel();

      expect(emptyCart.items, isEmpty);
      expect(emptyCart.isEmpty, isTrue);
      expect(emptyCart.isNotEmpty, isFalse);
      expect(emptyCart.totalItemCount, 0);
      expect(emptyCart.subtotal, 0.0);
      expect(emptyCart.deliveryFee, 0.0);
      expect(emptyCart.total, 0.0);
      expect(emptyCart.effectiveRestaurantId, isNull);
      expect(emptyCart.formattedSubtotal, '\$0.00');
      expect(emptyCart.formattedDeliveryFee, '\$0.00');
      expect(emptyCart.formattedTotal, '\$0.00');
    });

    test('calculates subtotal, centralized delivery fee, and grand total with items', () {
      final cart = CartModel(
        items: const [
          CartItemModel(foodItem: item1, quantity: 2), // 15.00 * 2 = 30.00
          CartItemModel(foodItem: item2, quantity: 1), // 5.00 * 1 = 5.00
        ],
      );

      expect(cart.isEmpty, isFalse);
      expect(cart.isNotEmpty, isTrue);
      expect(cart.totalItemCount, 3);
      expect(cart.subtotal, 35.00);
      expect(cart.deliveryFee, 2.99);
      expect(cart.total, 37.99);
      expect(cart.effectiveRestaurantId, 'rest-1');
      expect(cart.formattedSubtotal, '\$35.00');
      expect(cart.formattedDeliveryFee, '\$2.99');
      expect(cart.formattedTotal, '\$37.99');
    });

    test('supports value equality and copyWith', () {
      final cartA = CartModel(
        items: const [CartItemModel(foodItem: item1, quantity: 1)],
      );
      final cartB = CartModel(
        items: const [CartItemModel(foodItem: item1, quantity: 1)],
      );
      final cartC = cartA.copyWith(
        items: const [CartItemModel(foodItem: item1, quantity: 2)],
      );

      expect(cartA, equals(cartB));
      expect(cartA.hashCode, equals(cartB.hashCode));
      expect(cartA, isNot(equals(cartC)));
    });

    test('toMap and fromMap serialization', () {
      final cart = CartModel(
        items: const [CartItemModel(foodItem: item1, quantity: 2)],
      );
      final map = cart.toMap();
      final fromMap = CartModel.fromMap(map);

      expect(fromMap, equals(cart));
      expect(fromMap.subtotal, 30.00);
    });
  });
}
