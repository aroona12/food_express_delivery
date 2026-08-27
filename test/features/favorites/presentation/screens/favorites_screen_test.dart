import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/favorites/data/favorite_repository.dart';
import 'package:foodexpressdelivery/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:foodexpressdelivery/features/favorites/providers/favorite_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/providers/restaurant_provider.dart';

void main() {
  group('FavoritesScreen Widget Tests', () {
    const testUser = UserModel(
      id: 'user-123',
      email: 'customer@test.com',
      name: 'Test Customer',
      role: UserRole.customer,
    );

    const testRestaurant1 = RestaurantModel(
      id: 'rest-1',
      name: 'The Burger Studio',
      description: 'Artisanal brioche burgers',
      imageUrl: 'https://example.com/burger.jpg',
      rating: 4.8,
      reviewCount: 342,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free delivery',
      cuisine: 'Gourmet Burgers',
      isOpen: true,
      address: '142 S Broadway',
    );

    Widget createWidgetUnderTest({
      required MockFavoriteRepository favoriteRepo,
      required MockRestaurantRepository restaurantRepo,
    }) {
      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(testUser),
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
          restaurantRepositoryProvider.overrideWithValue(restaurantRepo),
        ],
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
    }

    testWidgets('displays empty state when user has no favorites', (tester) async {
      final favoriteRepo = MockFavoriteRepository();
      final restaurantRepo = MockRestaurantRepository(restaurants: [testRestaurant1]);

      await tester.pumpWidget(
        createWidgetUnderTest(
          favoriteRepo: favoriteRepo,
          restaurantRepo: restaurantRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('No Favorites Yet'), findsOneWidget);
      expect(find.text('Explore Restaurants'), findsOneWidget);
    });

    testWidgets('displays restaurant cards when favorites exist', (tester) async {
      final favoriteRepo = MockFavoriteRepository();
      await favoriteRepo.addFavorite(testUser.id, 'rest-1');

      final restaurantRepo = MockRestaurantRepository(restaurants: [testRestaurant1]);

      await tester.pumpWidget(
        createWidgetUnderTest(
          favoriteRepo: favoriteRepo,
          restaurantRepo: restaurantRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('The Burger Studio'), findsOneWidget);
      expect(find.text('Gourmet Burgers'), findsOneWidget);
      expect(find.text('20-30 min'), findsOneWidget);
    });

    testWidgets('unfavoriting removes item and displays empty state', (tester) async {
      final favoriteRepo = MockFavoriteRepository();
      await favoriteRepo.addFavorite(testUser.id, 'rest-1');

      final restaurantRepo = MockRestaurantRepository(restaurants: [testRestaurant1]);

      await tester.pumpWidget(
        createWidgetUnderTest(
          favoriteRepo: favoriteRepo,
          restaurantRepo: restaurantRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('The Burger Studio'), findsOneWidget);

      // Tap favorite button to unfavorite
      final favButton = find.byKey(const Key('favorite_button_rest-1'));
      expect(favButton, findsOneWidget);

      await tester.tap(favButton);
      await tester.pumpAndSettle();

      // Now empty state should appear
      expect(find.text('No Favorites Yet'), findsOneWidget);
    });
  });
}
