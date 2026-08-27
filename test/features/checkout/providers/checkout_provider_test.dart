import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';
import 'package:foodexpressdelivery/features/address/providers/address_provider.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_model.dart';
import 'package:foodexpressdelivery/features/cart/providers/cart_provider.dart';
import 'package:foodexpressdelivery/features/checkout/providers/checkout_provider.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/providers/restaurant_provider.dart';

void main() {
  group('Checkout Providers & Controller Tests', () {
    const testUser = UserModel(
      id: 'user-checkout-1',
      email: 'customer@test.com',
      name: 'Checkout Tester',
      role: UserRole.customer,
    );

    const testRestaurant = RestaurantModel(
      id: 'rest-1',
      name: 'Burger Joint',
      description: 'Burgers & Fries',
      imageUrl: 'https://example.com/burger.jpg',
      rating: 4.8,
      reviewCount: 50,
      deliveryTime: '20 min',
      deliveryFee: '\$2.99',
      cuisine: 'Burgers',
      isOpen: true,
      address: '10 Main St',
    );

    const testDish = FoodItemModel(
      id: 'food-1',
      restaurantId: 'rest-1',
      name: 'Classic Burger',
      description: 'Single patty burger',
      imageUrl: 'https://example.com/dish.jpg',
      price: 10.00,
      category: 'Burgers',
      isAvailable: true,
    );

    final testAddress = AddressModel(
      id: 'addr-1',
      userId: 'user-checkout-1',
      label: 'Home',
      fullAddress: '742 Evergreen Terrace',
      city: 'Springfield',
      phone: '+1 555-0123',
      isDefault: true,
      createdAt: DateTime(2026, 8, 20),
    );

    ProviderContainer createContainer({
      UserModel? currentUser = testUser,
      CartModel? initialCart,
      AddressModel? selectedAddress,
      OrderRepository? orderRepository,
    }) {
      final fakeRestaurantRepo = MockRestaurantRepository(
        restaurants: [testRestaurant],
        foodItems: [testDish],
      );

      final fakeOrderRepo = orderRepository ?? MockOrderRepository();

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(currentUser),
          restaurantRepositoryProvider.overrideWithValue(fakeRestaurantRepo),
          orderRepositoryProvider.overrideWithValue(fakeOrderRepo),
          if (initialCart != null)
            cartControllerProvider.overrideWith((ref) => CartController(initialCart)),
          if (selectedAddress != null)
            selectedAddressProvider.overrideWithValue(selectedAddress),
        ],
      );

      addTearDown(container.dispose);
      return container;
    }

    test('checkoutProvider derives state from Cart and selected Address', () async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish, quantity: 2),
        ],
      );

      final container = createContainer(
        initialCart: initialCart,
        selectedAddress: testAddress,
      );

      final checkout = container.read(checkoutProvider);

      expect(checkout.items.length, 1);
      expect(checkout.subtotal, 20.00);
      expect(checkout.deliveryFee, 2.99);
      expect(checkout.total, 22.99);
      expect(checkout.deliveryAddress, testAddress);
      expect(checkout.isValid, isTrue);
    });

    test('CheckoutController.placeOrder fails when user is unauthenticated', () async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish, quantity: 1),
        ],
      );

      final container = createContainer(
        currentUser: null,
        initialCart: initialCart,
        selectedAddress: testAddress,
      );

      final controller = container.read(checkoutControllerProvider.notifier);
      final result = await controller.placeOrder();

      expect(result, isNull);
      expect(container.read(checkoutControllerProvider).hasError, isTrue);
    });

    test('CheckoutController.placeOrder fails when cart is empty', () async {
      final container = createContainer(
        initialCart: const CartModel(items: []),
        selectedAddress: testAddress,
      );

      final controller = container.read(checkoutControllerProvider.notifier);
      final result = await controller.placeOrder();

      expect(result, isNull);
      expect(container.read(checkoutControllerProvider).hasError, isTrue);
    });

    test('CheckoutController.placeOrder fails when delivery address is null', () async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish, quantity: 1),
        ],
      );

      final container = createContainer(
        initialCart: initialCart,
        selectedAddress: null,
      );

      final controller = container.read(checkoutControllerProvider.notifier);
      final result = await controller.placeOrder();

      expect(result, isNull);
      expect(container.read(checkoutControllerProvider).hasError, isTrue);
    });

    test('CheckoutController.placeOrder succeeds with valid cart and address, clears cart and returns order ID', () async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish, quantity: 2),
        ],
      );

      final container = createContainer(
        initialCart: initialCart,
        selectedAddress: testAddress,
      );

      final controller = container.read(checkoutControllerProvider.notifier);
      final orderId = await controller.placeOrder();

      expect(orderId, isNotNull);
      expect(orderId, startsWith('ORD-'));

      // Cart is cleared
      final cart = container.read(cartProvider);
      expect(cart.isEmpty, isTrue);
    });

    test('CheckoutController.placeOrder preserves cart when repository throws error', () async {
      const errorUser = UserModel(
        id: 'error-user',
        email: 'err@test.com',
        name: 'Error User',
        role: UserRole.customer,
      );

      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish, quantity: 2),
        ],
      );

      final container = createContainer(
        currentUser: errorUser,
        initialCart: initialCart,
        selectedAddress: testAddress,
      );

      final controller = container.read(checkoutControllerProvider.notifier);
      final orderId = await controller.placeOrder();

      expect(orderId, isNull);
      expect(container.read(checkoutControllerProvider).hasError, isTrue);

      // Cart is NOT cleared on failure!
      final cart = container.read(cartProvider);
      expect(cart.isEmpty, isFalse);
      expect(cart.items.length, 1);
    });
  });
}
