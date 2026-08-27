import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/cart/providers/cart_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';

void main() {
  const itemRest1A = FoodItemModel(
    id: 'dish-1',
    restaurantId: 'rest-1',
    name: 'Classic Smash Cheeseburger',
    description: 'Double beef, cheddar cheese, brioche.',
    imageUrl: 'https://example.com/dish1.jpg',
    price: 12.00,
    category: 'Burgers',
    isAvailable: true,
  );

  const itemRest1B = FoodItemModel(
    id: 'dish-2',
    restaurantId: 'rest-1',
    name: 'Crispy Garlic Fries',
    description: 'Tossed in roasted garlic oil and herbs.',
    imageUrl: 'https://example.com/dish2.jpg',
    price: 6.00,
    category: 'Sides',
    isAvailable: true,
  );

  const unavailableDish = FoodItemModel(
    id: 'dish-3',
    restaurantId: 'rest-1',
    name: 'Seasonal Truffle Burger',
    description: 'Out of season.',
    imageUrl: 'https://example.com/dish3.jpg',
    price: 18.00,
    category: 'Burgers',
    isAvailable: false,
  );

  const itemRest2 = FoodItemModel(
    id: 'dish-4',
    restaurantId: 'rest-2',
    name: 'Margherita Pizza',
    description: 'Fresh mozzarella, basil, San Marzano tomatoes.',
    imageUrl: 'https://example.com/dish4.jpg',
    price: 16.00,
    category: 'Pizza',
    isAvailable: true,
  );

  group('CartController & Cart Providers Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is an empty cart with zero count and zero prices', () {
      final cart = container.read(cartProvider);
      final itemCount = container.read(cartItemCountProvider);
      final subtotal = container.read(cartSubtotalProvider);
      final deliveryFee = container.read(cartDeliveryFeeProvider);
      final total = container.read(cartTotalProvider);
      final isCartEmpty = container.read(isCartEmptyProvider);

      expect(cart.items, isEmpty);
      expect(cart.isEmpty, isTrue);
      expect(itemCount, 0);
      expect(subtotal, 0.0);
      expect(deliveryFee, 0.0);
      expect(total, 0.0);
      expect(isCartEmpty, isTrue);
    });

    test('addToCart adds new available item with quantity 1', () {
      final controller = container.read(cartControllerProvider.notifier);
      final result = controller.addToCart(itemRest1A);

      expect(result, AddToCartResult.added);

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.foodItemId, 'dish-1');
      expect(cart.items.first.quantity, 1);
      expect(cart.effectiveRestaurantId, 'rest-1');
      expect(container.read(cartItemCountProvider), 1);
      expect(container.read(cartSubtotalProvider), 12.00);
      expect(container.read(cartDeliveryFeeProvider), 2.99);
      expect(container.read(cartTotalProvider), 14.99);
      expect(container.read(isCartEmptyProvider), isFalse);
    });

    test('addToCart with existing item increments quantity instead of adding duplicate', () {
      final controller = container.read(cartControllerProvider.notifier);
      controller.addToCart(itemRest1A);
      final result = controller.addToCart(itemRest1A);

      expect(result, AddToCartResult.updatedQuantity);

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 2);
      expect(container.read(cartItemCountProvider), 2);
      expect(container.read(cartSubtotalProvider), 24.00);
      expect(container.read(cartTotalProvider), 26.99);
    });

    test('addToCart rejects unavailable item and does not modify cart', () {
      final controller = container.read(cartControllerProvider.notifier);
      final result = controller.addToCart(unavailableDish);

      expect(result, AddToCartResult.unavailable);
      expect(container.read(cartProvider).isEmpty, isTrue);
      expect(container.read(cartItemCountProvider), 0);
    });

    test('increaseQuantity increments line item quantity', () {
      final controller = container.read(cartControllerProvider.notifier);
      controller.addToCart(itemRest1A);
      controller.increaseQuantity('dish-1');

      final cart = container.read(cartProvider);
      expect(cart.items.first.quantity, 2);
      expect(container.read(cartSubtotalProvider), 24.00);
    });

    test('decreaseQuantity decrements quantity, and removes item when reaching zero', () {
      final controller = container.read(cartControllerProvider.notifier);
      controller.addToCart(itemRest1A);
      controller.addToCart(itemRest1A); // qty = 2

      controller.decreaseQuantity('dish-1');
      expect(container.read(cartProvider).items.first.quantity, 1);

      // Decrementing again should remove it from the cart
      controller.decreaseQuantity('dish-1');
      expect(container.read(cartProvider).items, isEmpty);
      expect(container.read(cartProvider).isEmpty, isTrue);
      expect(container.read(cartProvider).effectiveRestaurantId, isNull);
    });

    test('removeFromCart immediately removes specific food item', () {
      final controller = container.read(cartControllerProvider.notifier);
      controller.addToCart(itemRest1A);
      controller.addToCart(itemRest1B);

      expect(container.read(cartProvider).items.length, 2);

      controller.removeFromCart('dish-1');
      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.foodItemId, 'dish-2');
      expect(container.read(cartSubtotalProvider), 6.00);
    });

    test('clearCart empties all items and resets restaurant identity', () {
      final controller = container.read(cartControllerProvider.notifier);
      controller.addToCart(itemRest1A);
      controller.addToCart(itemRest1B);

      controller.clearCart();

      final cart = container.read(cartProvider);
      expect(cart.items, isEmpty);
      expect(cart.effectiveRestaurantId, isNull);
      expect(container.read(cartSubtotalProvider), 0.0);
      expect(container.read(cartTotalProvider), 0.0);
    });

    test('multi-restaurant rule: rejects items from different restaurant without mutating cart', () {
      final controller = container.read(cartControllerProvider.notifier);
      controller.addToCart(itemRest1A); // rest-1

      // Attempt to add dish from rest-2
      final result = controller.addToCart(itemRest2);

      expect(result, AddToCartResult.restaurantMismatch);

      // Existing cart should remain completely unchanged
      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.foodItemId, 'dish-1');
      expect(cart.effectiveRestaurantId, 'rest-1');
    });

    test('clearAndAddToCart clears existing cart and adds new restaurant item', () {
      final controller = container.read(cartControllerProvider.notifier);
      controller.addToCart(itemRest1A); // rest-1

      // Explicitly clear and add from rest-2
      controller.clearAndAddToCart(itemRest2);

      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.foodItemId, 'dish-4');
      expect(cart.effectiveRestaurantId, 'rest-2');
      expect(container.read(cartSubtotalProvider), 16.00);
    });
  });
}
