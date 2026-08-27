import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/routing/app_router.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/favorites/data/favorite_repository.dart';
import 'package:foodexpressdelivery/features/favorites/providers/favorite_provider.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';
import 'package:foodexpressdelivery/features/order/presentation/screens/order_tracking_screen.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';
import 'package:foodexpressdelivery/features/profile/providers/user_provider.dart';
import '../../../../test/helpers/fake_auth_repository.dart';
import '../../../../test/helpers/fake_user_repository.dart';

void main() {
  group('Favorites & Order Navigation & Route Guard Tests', () {
    const testUser = UserModel(
      id: 'nav-test-uid',
      email: 'customer@test.com',
      name: 'Nav Customer',
      role: UserRole.customer,
      phone: '+1234567890',
      address: '100 Main St',
    );

    final sampleOrder = OrderModel(
      id: 'ORD-NAV-1',
      userId: 'nav-test-uid',
      restaurantId: 'rest-1',
      restaurantName: 'Burger Kitchen',
      items: const [
        OrderItemModel(
          foodItemId: 'item-1',
          restaurantId: 'rest-1',
          name: 'Cheese Burger',
          imageUrl: '',
          unitPrice: 12.00,
          quantity: 1,
        ),
      ],
      subtotal: 12.00,
      deliveryFee: 2.00,
      total: 14.00,
      status: OrderStatus.preparing,
      createdAt: DateTime(2026, 8, 25, 12, 0),
    );

    Widget createTestApp({
      required FakeAuthRepository authRepo,
      required FakeUserRepository userRepo,
      required MockFavoriteRepository favoriteRepo,
      required MockOrderRepository orderRepo,
    }) {
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          userRepositoryProvider.overrideWithValue(userRepo),
          favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
          orderRepositoryProvider.overrideWithValue(orderRepo),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      );
    }

    testWidgets('tapping Favorites in Profile navigates to /favorites', (tester) async {
      final authRepo = FakeAuthRepository(initialUser: testUser);
      final userRepo = FakeUserRepository(initialUsers: {testUser.id: testUser});
      final favoriteRepo = MockFavoriteRepository();
      final orderRepo = MockOrderRepository();

      await tester.pumpWidget(
        createTestApp(
          authRepo: authRepo,
          userRepo: userRepo,
          favoriteRepo: favoriteRepo,
          orderRepo: orderRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Open Profile from home app bar menu
      final accountBtn = find.byTooltip('Account');
      expect(accountBtn, findsOneWidget);
      await tester.tap(accountBtn);
      await tester.pumpAndSettle();

      final profileOption = find.text('View Profile');
      await tester.tap(profileOption);
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);

      // Tap "My Favorites"
      final favoritesTile = find.text('My Favorites');
      expect(favoritesTile, findsOneWidget);
      await tester.ensureVisible(favoritesTile);
      await tester.tap(favoritesTile);
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('No Favorites Yet'), findsOneWidget);
    });

    testWidgets('tapping Order History in Profile navigates to /orders and to /orders/:orderId', (tester) async {
      final authRepo = FakeAuthRepository(initialUser: testUser);
      final userRepo = FakeUserRepository(initialUsers: {testUser.id: testUser});
      final favoriteRepo = MockFavoriteRepository();
      final orderRepo = MockOrderRepository(
        initialOrders: {
          'nav-test-uid': [sampleOrder],
        },
      );

      await tester.pumpWidget(
        createTestApp(
          authRepo: authRepo,
          userRepo: userRepo,
          favoriteRepo: favoriteRepo,
          orderRepo: orderRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Open Profile from popup menu
      final accountBtn = find.byTooltip('Account');
      await tester.tap(accountBtn);
      await tester.pumpAndSettle();

      final profileOption = find.text('View Profile');
      await tester.tap(profileOption);
      await tester.pumpAndSettle();

      // Tap "Order History"
      final ordersTile = find.text('Order History');
      expect(ordersTile, findsOneWidget);
      await tester.ensureVisible(ordersTile);
      await tester.tap(ordersTile);
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('Burger Kitchen'), findsOneWidget);
      expect(find.text('Order ID: #ORD-NAV-1'), findsOneWidget);

      // Tap View Details
      final viewDetailsBtn = find.text('View Details');
      expect(viewDetailsBtn, findsOneWidget);
      await tester.tap(viewDetailsBtn);
      await tester.pumpAndSettle();

      expect(find.byType(OrderTrackingScreen), findsOneWidget);
      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('Live Order Progress'), findsOneWidget);
      expect(find.text('Cheese Burger'), findsOneWidget);
      expect(find.text('\$14.00'), findsWidgets);
    });

    testWidgets('unauthenticated access redirects to /login', (tester) async {
      final authRepo = FakeAuthRepository(initialUser: null);
      final userRepo = FakeUserRepository();
      final favoriteRepo = MockFavoriteRepository();
      final orderRepo = MockOrderRepository();

      await tester.pumpWidget(
        createTestApp(
          authRepo: authRepo,
          userRepo: userRepo,
          favoriteRepo: favoriteRepo,
          orderRepo: orderRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
    });
  });
}
