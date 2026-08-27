import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/routing/app_router.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/presentation/screens/login_screen.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_model.dart';
import 'package:foodexpressdelivery/features/cart/presentation/screens/cart_screen.dart';
import 'package:foodexpressdelivery/features/cart/providers/cart_provider.dart';
import 'package:foodexpressdelivery/features/profile/providers/user_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/providers/restaurant_provider.dart';
import '../../../helpers/fake_auth_repository.dart';
import '../../../helpers/fake_user_repository.dart';

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late FakeUserRepository fakeUserRepository;
  late MockRestaurantRepository fakeRestaurantRepository;

  final testUser = UserModel(
    id: 'test-uid-1',
    email: 'customer@foodexpress.com',
    name: 'Emily Watson',
    role: UserRole.customer,
    phone: '+1 555-0123',
    address: '742 Evergreen Terrace',
    createdAt: DateTime(2026, 8, 22),
  );

  const testFoodItem = FoodItemModel(
    id: 'item-1',
    restaurantId: 'rest-1',
    name: 'Truffle Smash Burger',
    description: 'Double beef patties.',
    imageUrl: 'https://example.com/item1.jpg',
    price: 15.99,
    category: 'Burgers',
    isAvailable: true,
  );

  const testRestaurant = RestaurantModel(
    id: 'rest-1',
    name: 'The Burger Studio',
    description: 'Artisanal brioche burgers and craft sides.',
    imageUrl: 'https://example.com/burger.jpg',
    rating: 4.8,
    reviewCount: 342,
    deliveryTime: '20-30 min',
    deliveryFee: 'Free delivery',
    cuisine: 'Gourmet Burgers • American',
    isOpen: true,
    address: '142 S Broadway, New York, NY',
    featuredBadge: 'Featured',
  );

  setUp(() {
    fakeAuthRepository = FakeAuthRepository(initialUser: testUser);
    fakeUserRepository = FakeUserRepository(
      initialUsers: {testUser.id: testUser},
    );
    fakeRestaurantRepository = MockRestaurantRepository(
      restaurants: [testRestaurant],
      foodItems: [testFoodItem],
    );
  });

  tearDown(() {
    fakeAuthRepository.dispose();
    fakeUserRepository.dispose();
  });

  group('Cart Navigation & Route Guard Tests', () {
    testWidgets('tapping Cart icon in HomeAppBar navigates to /cart and displays badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testFoodItem, quantity: 2),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
            userRepositoryProvider.overrideWithValue(fakeUserRepository),
            restaurantRepositoryProvider.overrideWithValue(fakeRestaurantRepository),
            cartControllerProvider.overrideWith((ref) => CartController(initialCart)),
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
        ),
      );
      await tester.pumpAndSettle();

      // Check badge on Home Screen
      expect(find.byKey(const Key('home_cart_button')), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Badge counter

      // Tap cart button
      await tester.tap(find.byKey(const Key('home_cart_button')));
      await tester.pumpAndSettle();

      // Should be on CartScreen
      expect(find.byType(CartScreen), findsOneWidget);
      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Truffle Smash Burger'), findsOneWidget);
      expect(find.text('Proceed to Checkout • \$34.97'), findsOneWidget);
    });

    testWidgets('unauthenticated user attempting to access /cart is redirected to /login', (tester) async {
      await fakeAuthRepository.signOut();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
            userRepositoryProvider.overrideWithValue(fakeUserRepository),
            restaurantRepositoryProvider.overrideWithValue(fakeRestaurantRepository),
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
        ),
      );
      await tester.pumpAndSettle();

      // Guard redirects to /login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.byType(CartScreen), findsNothing);
    });
  });
}
