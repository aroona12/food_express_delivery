import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';
import 'package:foodexpressdelivery/features/order/presentation/screens/order_details_screen.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';

void main() {
  group('OrderDetailsScreen Widget Tests', () {
    const testUser = UserModel(
      id: 'details-user-123',
      email: 'customer@test.com',
      name: 'Test Customer',
      role: UserRole.customer,
    );

    final sampleOrder = OrderModel(
      id: 'ORD-55555',
      userId: 'details-user-123',
      restaurantId: 'rest-1',
      restaurantName: 'Napoli Artisan Pizzeria',
      items: const [
        OrderItemModel(
          foodItemId: 'item-10',
          restaurantId: 'rest-1',
          name: 'Margherita D.O.P.',
          imageUrl: 'https://example.com/pizza.jpg',
          unitPrice: 16.50,
          quantity: 2,
        ),
        OrderItemModel(
          foodItemId: 'item-13',
          restaurantId: 'rest-1',
          name: 'Tiramisu',
          imageUrl: 'https://example.com/tiramisu.jpg',
          unitPrice: 7.50,
          quantity: 1,
        ),
      ],
      subtotal: 40.50,
      deliveryFee: 2.99,
      total: 43.49,
      status: OrderStatus.outForDelivery,
      createdAt: DateTime(2026, 8, 25, 19, 0),
    );

    Widget createWidgetUnderTest({
      required MockOrderRepository orderRepo,
      String orderId = 'ORD-55555',
    }) {
      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(testUser),
          orderRepositoryProvider.overrideWithValue(orderRepo),
        ],
        child: MaterialApp(
          home: OrderDetailsScreen(orderId: orderId),
        ),
      );
    }

    testWidgets('displays not found when order does not exist', (tester) async {
      final orderRepo = MockOrderRepository(
        initialOrders: {
          'details-user-123': [],
        },
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          orderRepo: orderRepo,
          orderId: 'NON-EXISTENT',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('Order Not Found'), findsOneWidget);
    });

    testWidgets('displays complete order details, itemized breakdown, and bill summary', (tester) async {
      final orderRepo = MockOrderRepository(
        initialOrders: {
          'details-user-123': [sampleOrder],
        },
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          orderRepo: orderRepo,
          orderId: 'ORD-55555',
        ),
      );
      await tester.pumpAndSettle();

      // Top Header
      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('Status: Out for Delivery'), findsOneWidget);
      expect(find.text('Napoli Artisan Pizzeria'), findsOneWidget);
      expect(find.text('Order ID: #ORD-55555'), findsOneWidget);

      // Items
      expect(find.text('Ordered Items (3)'), findsOneWidget);
      expect(find.text('Margherita D.O.P.'), findsOneWidget);
      expect(find.text('2x @ \$16.50'), findsOneWidget);
      expect(find.text('\$33.00'), findsOneWidget);
      expect(find.text('Tiramisu'), findsOneWidget);
      expect(find.text('1x @ \$7.50'), findsOneWidget);
      expect(find.text('\$7.50'), findsOneWidget);

      // Bill Summary
      expect(find.text('Bill Summary'), findsOneWidget);
      expect(find.text('Item Subtotal'), findsOneWidget);
      expect(find.text('\$40.50'), findsOneWidget);
      expect(find.text('Delivery Fee'), findsOneWidget);
      expect(find.text('\$2.99'), findsOneWidget);
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('\$43.49'), findsOneWidget);

      // Actions
      expect(find.text('Order Again from this Restaurant'), findsOneWidget);
      expect(find.text('Back to Order History'), findsOneWidget);
    });
  });
}
