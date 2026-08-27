import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/routing/app_router.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/address/data/address_repository.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';
import 'package:foodexpressdelivery/features/address/presentation/screens/address_list_screen.dart';
import 'package:foodexpressdelivery/features/address/providers/address_provider.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/presentation/screens/login_screen.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_model.dart';
import 'package:foodexpressdelivery/features/cart/presentation/screens/cart_screen.dart';
import 'package:foodexpressdelivery/features/cart/providers/cart_provider.dart';
import 'package:foodexpressdelivery/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:foodexpressdelivery/features/checkout/presentation/screens/order_success_screen.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';
import 'package:foodexpressdelivery/features/profile/providers/user_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/providers/restaurant_provider.dart';
import '../../../../test/helpers/fake_auth_repository.dart';
import '../../../../test/helpers/fake_user_repository.dart';

void main() {
  const testUser = UserModel(
    id: 'user-nav-checkout',
    email: 'customer@test.com',
    name: 'Emily Watson',
    role: UserRole.customer,
    phone: '+1 555-0123',
    address: '742 Evergreen Terrace',
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

  const testDish = FoodItemModel(
    id: 'food-1',
    restaurantId: 'rest-1',
    name: 'Truffle Smash Burger',
    description: 'Double beef patty',
    imageUrl: 'https://example.com/dish1.jpg',
    price: 15.00,
    category: 'Burgers',
    isAvailable: true,
  );

  final address1 = AddressModel(
    id: 'addr-1',
    userId: 'user-nav-checkout',
    label: 'Home',
    fullAddress: '742 Evergreen Terrace, Apt 4B',
    city: 'Springfield',
    phone: '+1 (555) 012-3456',
    isDefault: true,
    createdAt: DateTime(2026, 8, 20),
  );

  final address2 = AddressModel(
    id: 'addr-2',
    userId: 'user-nav-checkout',
    label: 'Work',
    fullAddress: '100 Industrial Parkway',
    city: 'Springfield',
    phone: '+1 (555) 987-6543',
    isDefault: false,
    createdAt: DateTime(2026, 8, 21),
  );

  Widget createTestApp({
    required FakeAuthRepository authRepo,
    required FakeUserRepository userRepo,
    required MockRestaurantRepository restaurantRepo,
    required MockAddressRepository addressRepo,
    MockOrderRepository? orderRepo,
    CartModel? cart,
  }) {
    final effectiveOrderRepo = orderRepo ?? MockOrderRepository();

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        userRepositoryProvider.overrideWithValue(userRepo),
        restaurantRepositoryProvider.overrideWithValue(restaurantRepo),
        addressRepositoryProvider.overrideWithValue(addressRepo),
        orderRepositoryProvider.overrideWithValue(effectiveOrderRepo),
        if (cart != null)
          cartControllerProvider.overrideWith((ref) => CartController(cart)),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(appRouterProvider);
          return MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }

  group('Checkout & Address Navigation & Route Guard Tests', () {
    testWidgets('CartScreen Proceed to Checkout button navigates to /checkout', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final authRepo = FakeAuthRepository(initialUser: testUser);
      final userRepo = FakeUserRepository(initialUsers: {testUser.id: testUser});
      final restaurantRepo = MockRestaurantRepository(
        restaurants: [testRestaurant],
        foodItems: [testDish],
      );
      final addressRepo = MockAddressRepository(
        initialData: {testUser.id: [address1, address2]},
      );
      final cart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish, quantity: 1),
        ],
      );

      await tester.pumpWidget(
        createTestApp(
          authRepo: authRepo,
          userRepo: userRepo,
          restaurantRepo: restaurantRepo,
          addressRepo: addressRepo,
          cart: cart,
        ),
      );
      await tester.pumpAndSettle();

      // Open Cart from Home
      final cartBtn = find.byKey(const Key('home_cart_button'));
      expect(cartBtn, findsOneWidget);
      await tester.tap(cartBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CartScreen), findsOneWidget);

      // Tap Proceed to Checkout
      final checkoutBtn = find.text('Proceed to Checkout • \$17.99');
      expect(checkoutBtn, findsOneWidget);
      await tester.tap(checkoutBtn);
      await tester.pumpAndSettle();

      // On CheckoutScreen
      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('742 Evergreen Terrace, Apt 4B'), findsOneWidget);
      expect(find.byKey(const Key('place_order_button')), findsOneWidget);
    });

    testWidgets('CheckoutScreen Change Address button navigates to /addresses and selects address', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final authRepo = FakeAuthRepository(initialUser: testUser);
      final userRepo = FakeUserRepository(initialUsers: {testUser.id: testUser});
      final restaurantRepo = MockRestaurantRepository(
        restaurants: [testRestaurant],
        foodItems: [testDish],
      );
      final addressRepo = MockAddressRepository(
        initialData: {testUser.id: [address1, address2]},
      );
      final cart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish, quantity: 1),
        ],
      );

      await tester.pumpWidget(
        createTestApp(
          authRepo: authRepo,
          userRepo: userRepo,
          restaurantRepo: restaurantRepo,
          addressRepo: addressRepo,
          cart: cart,
        ),
      );
      await tester.pumpAndSettle();

      // Open Cart and proceed to checkout
      await tester.tap(find.byKey(const Key('home_cart_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proceed to Checkout • \$17.99'));
      await tester.pumpAndSettle();

      expect(find.text('Change'), findsOneWidget);
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      // On AddressListScreen in select mode
      expect(find.byType(AddressListScreen), findsOneWidget);
      expect(find.text('Select Delivery Address'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);

      // Tap Work address
      await tester.tap(find.text('100 Industrial Parkway'));
      await tester.pumpAndSettle();

      // Returned to CheckoutScreen with Work address updated
      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(find.text('100 Industrial Parkway'), findsOneWidget);
    });

    testWidgets('placing order on CheckoutScreen navigates to /order-success/:orderId', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final authRepo = FakeAuthRepository(initialUser: testUser);
      final userRepo = FakeUserRepository(initialUsers: {testUser.id: testUser});
      final restaurantRepo = MockRestaurantRepository(
        restaurants: [testRestaurant],
        foodItems: [testDish],
      );
      final addressRepo = MockAddressRepository(
        initialData: {testUser.id: [address1]},
      );
      final cart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish, quantity: 1),
        ],
      );

      await tester.pumpWidget(
        createTestApp(
          authRepo: authRepo,
          userRepo: userRepo,
          restaurantRepo: restaurantRepo,
          addressRepo: addressRepo,
          cart: cart,
        ),
      );
      await tester.pumpAndSettle();

      // Open cart and proceed to checkout
      await tester.tap(find.byKey(const Key('home_cart_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proceed to Checkout • \$17.99'));
      await tester.pumpAndSettle();

      final placeOrderBtn = find.byKey(const Key('place_order_button'));
      expect(placeOrderBtn, findsOneWidget);
      await tester.tap(placeOrderBtn);
      await tester.pumpAndSettle();

      // Verify on OrderSuccessScreen
      expect(find.byType(OrderSuccessScreen), findsOneWidget);
      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.byKey(const Key('order_success_track_button')), findsOneWidget);
      expect(find.byKey(const Key('order_success_home_button')), findsOneWidget);
    });

    testWidgets('unauthenticated access to /checkout is guarded and redirects to /login', (tester) async {
      final authRepo = FakeAuthRepository(initialUser: null);
      final userRepo = FakeUserRepository();
      final restaurantRepo = MockRestaurantRepository();
      final addressRepo = MockAddressRepository();

      await tester.pumpWidget(
        createTestApp(
          authRepo: authRepo,
          userRepo: userRepo,
          restaurantRepo: restaurantRepo,
          addressRepo: addressRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
    });
  });
}
