import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/address/data/address_repository.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';
import 'package:foodexpressdelivery/features/address/providers/address_provider.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_model.dart';
import 'package:foodexpressdelivery/features/cart/providers/cart_provider.dart';
import 'package:foodexpressdelivery/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:foodexpressdelivery/features/checkout/presentation/widgets/checkout_address_section.dart';
import 'package:foodexpressdelivery/features/checkout/presentation/widgets/checkout_order_summary.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/providers/restaurant_provider.dart';

void main() {
  const testUser = UserModel(
    id: 'user-checkout-ui',
    email: 'customer@test.com',
    name: 'Emily Watson',
    role: UserRole.customer,
  );

  const testRestaurant = RestaurantModel(
    id: 'rest-1',
    name: 'The Burger Studio',
    description: 'Artisanal brioche burgers',
    imageUrl: 'https://example.com/burger.jpg',
    rating: 4.8,
    reviewCount: 342,
    deliveryTime: '20-30 min',
    deliveryFee: 'Free delivery',
    cuisine: 'Burgers • American',
    isOpen: true,
    address: '142 S Broadway',
  );

  const testDish1 = FoodItemModel(
    id: 'food-1',
    restaurantId: 'rest-1',
    name: 'Truffle Smash Burger',
    description: 'Double beef patty',
    imageUrl: 'https://example.com/dish1.jpg',
    price: 15.00,
    category: 'Burgers',
    isAvailable: true,
  );

  const testDish2 = FoodItemModel(
    id: 'food-2',
    restaurantId: 'rest-1',
    name: 'Rosemary Garlic Fries',
    description: 'Crispy skin-on fries',
    imageUrl: 'https://example.com/dish2.jpg',
    price: 5.00,
    category: 'Sides',
    isAvailable: true,
  );

  final testAddress = AddressModel(
    id: 'addr-1',
    userId: 'user-checkout-ui',
    label: 'Home',
    fullAddress: '742 Evergreen Terrace, Apt 4B',
    city: 'Springfield',
    phone: '+1 (555) 012-3456',
    additionalInstructions: 'Ring bell twice',
    isDefault: true,
    createdAt: DateTime(2026, 8, 20),
  );

  Widget createTestWidget({
    CartModel? cart,
    AddressModel? selectedAddress,
    bool nullAddress = false,
  }) {
    final effectiveAddress = nullAddress ? null : (selectedAddress ?? testAddress);
    final fakeRestaurantRepo = MockRestaurantRepository(
      restaurants: [testRestaurant],
      foodItems: [testDish1, testDish2],
    );

    final fakeAddressRepo = MockAddressRepository(
      initialData: {
        testUser.id: effectiveAddress != null ? [effectiveAddress] : [],
      },
    );

    final fakeOrderRepo = MockOrderRepository();

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(testUser),
        restaurantRepositoryProvider.overrideWithValue(fakeRestaurantRepo),
        addressRepositoryProvider.overrideWithValue(fakeAddressRepo),
        orderRepositoryProvider.overrideWithValue(fakeOrderRepo),
        if (cart != null)
          cartControllerProvider.overrideWith((ref) => CartController(cart)),
        if (effectiveAddress != null)
          selectedAddressProvider.overrideWithValue(effectiveAddress)
        else
          selectedAddressProvider.overrideWithValue(null),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CheckoutScreen(),
      ),
    );
  }

  group('CheckoutScreen Widget Tests', () {
    testWidgets('renders empty cart state when no items in shopping cart', (tester) async {
      await tester.pumpWidget(createTestWidget(cart: const CartModel(items: [])));
      await tester.pumpAndSettle();

      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Browse Restaurants'), findsOneWidget);
      expect(find.byType(CheckoutAddressSection), findsNothing);
    });

    testWidgets('renders full checkout review screen with address, restaurant, line items, and pricing', (tester) async {
      final cart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 2), // 30.00
          CartItemModel(foodItem: testDish2, quantity: 1), // 5.00
        ],
      );

      await tester.pumpWidget(createTestWidget(cart: cart));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.byType(CheckoutAddressSection), findsOneWidget);
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('742 Evergreen Terrace, Apt 4B'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);

      expect(find.byType(CheckoutOrderSummary), findsOneWidget);
      expect(find.text('Truffle Smash Burger'), findsOneWidget);
      expect(find.text('Rosemary Garlic Fries'), findsOneWidget);
      expect(find.text('\$30.00'), findsOneWidget);
      expect(find.text('\$5.00'), findsOneWidget);
      expect(find.text('\$35.00'), findsOneWidget); // subtotal
      expect(find.text('\$37.99'), findsWidgets); // grand total in bill summary & bottom bar

      expect(find.byKey(const Key('place_order_button')), findsOneWidget);
    });

    testWidgets('displays warning card when no delivery address is selected', (tester) async {
      final cart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 1),
        ],
      );

      await tester.pumpWidget(createTestWidget(cart: cart, nullAddress: true));
      await tester.pumpAndSettle();

      expect(find.text('No Delivery Address Selected'), findsOneWidget);
      expect(find.text('Add Delivery Address'), findsOneWidget);
    });

    testWidgets('tapping Place Order places order and shows success dialog', (tester) async {
      final cart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 1),
        ],
      );

      await tester.pumpWidget(createTestWidget(cart: cart));
      await tester.pumpAndSettle();

      final placeOrderBtn = find.byKey(const Key('place_order_button'));
      expect(placeOrderBtn, findsOneWidget);

      await tester.tap(placeOrderBtn);
      await tester.pumpAndSettle();

      // Verify order success dialog appeared
      expect(find.text('Order Placed!'), findsOneWidget);
      expect(find.text('View Order History'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });
  });
}
