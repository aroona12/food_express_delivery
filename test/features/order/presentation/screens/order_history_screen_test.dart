import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';
import 'package:foodexpressdelivery/features/order/presentation/screens/order_history_screen.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';

void main() {
  group('OrderHistoryScreen Widget Tests', () {
    const testUser = UserModel(
      id: 'order-test-user',
      email: 'customer@test.com',
      name: 'Test Customer',
      role: UserRole.customer,
    );

    final sampleOrder = OrderModel(
      id: 'ORD-12345',
      userId: 'order-test-user',
      restaurantId: 'rest-1',
      restaurantName: 'The Burger Studio',
      items: const [
        OrderItemModel(
          foodItemId: 'item-1',
          restaurantId: 'rest-1',
          name: 'Truffle Smash Burger',
          imageUrl: 'https://example.com/b.jpg',
          unitPrice: 14.99,
          quantity: 2,
        ),
      ],
      subtotal: 29.98,
      deliveryFee: 2.99,
      total: 32.97,
      status: OrderStatus.delivered,
      createdAt: DateTime(2026, 8, 25, 18, 0),
    );

    Widget createWidgetUnderTest({
      required MockOrderRepository orderRepo,
    }) {
      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(testUser),
          orderRepositoryProvider.overrideWithValue(orderRepo),
        ],
        child: const MaterialApp(
          home: OrderHistoryScreen(),
        ),
      );
    }

    testWidgets('displays empty state when user has no orders', (tester) async {
      final orderRepo = MockOrderRepository(
        initialOrders: {
          'order-test-user': [],
        },
      );

      await tester.pumpWidget(createWidgetUnderTest(orderRepo: orderRepo));
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('No Orders Yet'), findsOneWidget);
      expect(find.text('Browse Restaurants'), findsOneWidget);
    });

    testWidgets('displays order card with restaurant name, status, and total', (tester) async {
      final orderRepo = MockOrderRepository(
        initialOrders: {
          'order-test-user': [sampleOrder],
        },
      );

      await tester.pumpWidget(createWidgetUnderTest(orderRepo: orderRepo));
      await tester.pumpAndSettle();

      expect(find.text('Order History'), findsOneWidget);
      expect(find.text('The Burger Studio'), findsOneWidget);
      expect(find.text('Order ID: #ORD-12345'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('\$32.97'), findsOneWidget);
      expect(find.text('2 items'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });
  });
}
