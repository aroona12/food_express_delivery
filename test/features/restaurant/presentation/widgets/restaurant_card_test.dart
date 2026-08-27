import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/favorites/data/favorite_repository.dart';
import 'package:foodexpressdelivery/features/favorites/providers/favorite_provider.dart';
import 'package:foodexpressdelivery/features/home/presentation/widgets/restaurant_card.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';

void main() {
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

  const testUser = UserModel(
    id: 'user-123',
    email: 'customer@test.com',
    name: 'Test Customer',
    role: UserRole.customer,
  );

  group('RestaurantCard Widget Tests', () {
    testWidgets('renders restaurant details, rating, delivery info, and badge', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
            favoriteRepositoryProvider.overrideWithValue(MockFavoriteRepository()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: RestaurantCard(
                  restaurant: testRestaurant,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('The Burger Studio'), findsOneWidget);
      expect(find.text('Gourmet Burgers • American'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text(' (342)'), findsOneWidget);
      expect(find.text('20-30 min'), findsOneWidget);
      expect(find.text('Free delivery'), findsOneWidget);
      expect(find.text('OPEN'), findsOneWidget);
      expect(find.text('Featured'), findsOneWidget);

      await tester.tap(find.text('The Burger Studio'));
      expect(tapped, isTrue);
    });

    testWidgets('toggles favorite heart state on tap', (tester) async {
      final favoriteRepo = MockFavoriteRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
            favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: RestaurantCard(
                  restaurant: testRestaurant,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final favoriteBtn = find.byTooltip('Favorite');
      expect(favoriteBtn, findsOneWidget);

      // Initially outlined heart
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      // Tap favorite button
      await tester.tap(favoriteBtn);
      await tester.pumpAndSettle();

      // Now filled heart
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });
  });
}

