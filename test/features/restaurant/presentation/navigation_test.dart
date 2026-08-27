import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/routing/app_router.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/profile/providers/user_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/presentation/screens/restaurant_details_screen.dart';
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

  const testFoodItem = FoodItemModel(
    id: 'item-1',
    restaurantId: 'rest-1',
    name: 'Truffle Umami Smash Burger',
    description: 'Double Angus beef patties, aged white cheddar.',
    imageUrl: 'https://example.com/item1.jpg',
    price: 15.99,
    category: 'Burgers',
    isAvailable: true,
    rating: 4.9,
    calories: 820,
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

  testWidgets('tapping RestaurantCard on HomeScreen navigates to /restaurant/:id', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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

    // Verify on Home Screen
    expect(find.text('The Burger Studio'), findsOneWidget);
    expect(find.text('Featured Restaurants'), findsOneWidget);

    // Ensure restaurant card is visible and tap it
    final restaurantCard = find.text('The Burger Studio');
    await tester.ensureVisible(restaurantCard);
    await tester.tap(restaurantCard);
    await tester.pumpAndSettle();

    // Verify on RestaurantDetailsScreen
    expect(find.byType(RestaurantDetailsScreen), findsOneWidget);
    expect(find.text('Menu & Categories'), findsOneWidget);
    expect(find.text('Truffle Umami Smash Burger'), findsOneWidget);
  });
}
