import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';
import 'package:foodexpressdelivery/features/order/presentation/screens/order_tracking_screen.dart';
import 'package:foodexpressdelivery/features/order/presentation/widgets/order_tracking_timeline.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';

class _ErrorThrowingOrderRepository extends MockOrderRepository {
  _ErrorThrowingOrderRepository({super.initialOrders});

  @override
  Future<void> updateOrderStatus(dynamic arg1, dynamic arg2, [OrderStatus? arg3]) async {
    throw Exception('Simulated network failure on cancellation');
  }
}

void main() {
  group('OrderTrackingScreen Widget Tests', () {
    const testUser = UserModel(
      id: 'tracking-test-uid',
      email: 'customer@test.com',
      name: 'Tracking Customer',
      role: UserRole.customer,
    );

    final sampleOrder = OrderModel(
      id: 'ORD-TRACK-101',
      userId: 'tracking-test-uid',
      restaurantId: 'rest-1',
      restaurantName: 'The Burger Studio',
      items: const [
        OrderItemModel(
          foodItemId: 'item-1',
          restaurantId: 'rest-1',
          name: 'Truffle Smash Burger',
          imageUrl: '',
          unitPrice: 15.00,
          quantity: 2,
        ),
        OrderItemModel(
          foodItemId: 'item-2',
          restaurantId: 'rest-1',
          name: 'Garlic Fries',
          imageUrl: '',
          unitPrice: 5.00,
          quantity: 1,
        ),
      ],
      subtotal: 35.00,
      deliveryFee: 2.99,
      total: 37.99,
      status: OrderStatus.preparing,
      createdAt: DateTime(2026, 8, 25, 19, 0),
      deliveryAddress: '742 Evergreen Terrace, Springfield',
      orderNotes: 'Please ring bell',
      paymentMethod: 'Cash on Delivery',
    );

    Widget createTestWidget({
      String orderId = 'ORD-TRACK-101',
      OrderRepository? repository,
    }) {
      final mockRepo = repository ??
          MockOrderRepository(
            initialOrders: {
              testUser.id: [sampleOrder],
            },
          );

      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(testUser),
          orderRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: OrderTrackingScreen(orderId: orderId),
        ),
      );
    }

    testWidgets('renders live tracking screen with timeline, restaurant, items, and billing details', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('Status: Preparing'), findsNothing); // Uses rich header and timeline
      expect(find.byType(OrderTrackingTimeline), findsOneWidget);

      expect(find.text('The Burger Studio'), findsOneWidget);
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('742 Evergreen Terrace, Springfield'), findsOneWidget);
      expect(find.text('Notes: Please ring bell'), findsOneWidget);

      expect(find.text('Truffle Smash Burger'), findsOneWidget);
      expect(find.text('Garlic Fries'), findsOneWidget);
      expect(find.text('\$30.00'), findsOneWidget);
      expect(find.text('\$5.00'), findsOneWidget);
      expect(find.text('\$35.00'), findsOneWidget); // subtotal
      expect(find.text('\$37.99'), findsOneWidget); // total
      expect(find.text('Cash on Delivery'), findsOneWidget);
    });

    testWidgets('renders empty state when order does not exist', (tester) async {
      final mockRepo = MockOrderRepository(initialOrders: {});
      await tester.pumpWidget(
        createTestWidget(orderId: 'NON-EXISTENT', repository: mockRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Not Found'), findsOneWidget);
      expect(find.text('View All Orders'), findsOneWidget);
    });

    testWidgets('reacts to real-time status transitions automatically', (tester) async {
      final mockRepo = MockOrderRepository(
        initialOrders: {
          testUser.id: [sampleOrder],
        },
      );

      await tester.pumpWidget(createTestWidget(repository: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Preparing'), findsWidgets);

      // Trigger real-time status update to Out for Delivery
      mockRepo.updateOrderStatus(
        'tracking-test-uid',
        'ORD-TRACK-101',
        OrderStatus.outForDelivery,
      );

      await tester.pumpAndSettle();

      expect(find.text('Out for Delivery'), findsWidgets);
    });

    // ==========================================
    // Customer Cancellation Tests
    // ==========================================

    testWidgets('Test 1: Pending customer order displays Cancel Order button', (tester) async {
      final pendingOrder = sampleOrder.copyWith(
        id: 'ORD-PENDING-1',
        status: OrderStatus.pending,
      );

      final mockRepo = MockOrderRepository(
        initialOrders: {
          testUser.id: [pendingOrder],
        },
      );

      await tester.pumpWidget(
        createTestWidget(orderId: 'ORD-PENDING-1', repository: mockRepo),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cancel_order_button')), findsOneWidget);
      expect(find.text('Cancel Order'), findsOneWidget);
    });

    testWidgets('Test 2: Non-pending orders do NOT display Cancel Order button', (tester) async {
      final nonPendingStatuses = [
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.outForDelivery,
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ];

      for (final status in nonPendingStatuses) {
        final order = sampleOrder.copyWith(
          id: 'ORD-STATUS-${status.name}',
          status: status,
        );

        final mockRepo = MockOrderRepository(
          initialOrders: {
            testUser.id: [order],
          },
        );

        await tester.pumpWidget(
          createTestWidget(orderId: 'ORD-STATUS-${status.name}', repository: mockRepo),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('cancel_order_button')),
          findsNothing,
          reason: 'Cancel Order button must not appear for status: ${status.name}',
        );
        expect(
          find.text('Cancel Order'),
          findsNothing,
          reason: 'Cancel Order text must not appear for status: ${status.name}',
        );
      }
    });

    testWidgets('Test 3: Tapping Cancel Order opens confirmation dialog; Keep Order dismisses without cancelling', (tester) async {
      final pendingOrder = sampleOrder.copyWith(
        id: 'ORD-PENDING-3',
        status: OrderStatus.pending,
      );

      final mockRepo = MockOrderRepository(
        initialOrders: {
          testUser.id: [pendingOrder],
        },
      );

      await tester.pumpWidget(
        createTestWidget(orderId: 'ORD-PENDING-3', repository: mockRepo),
      );
      await tester.pumpAndSettle();

      // Tap Cancel Order
      final cancelBtn = find.byKey(const Key('cancel_order_button'));
      expect(cancelBtn, findsOneWidget);
      await tester.ensureVisible(cancelBtn);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Cancel Order?'), findsOneWidget);
      expect(find.text('Keep Order'), findsOneWidget);
      expect(find.text('Yes, Cancel'), findsOneWidget);

      // Tap "Keep Order"
      await tester.tap(find.text('Keep Order'));
      await tester.pumpAndSettle();

      // Dialog is dismissed and status remains pending
      expect(find.text('Cancel Order?'), findsNothing);
      expect(find.byKey(const Key('cancel_order_button')), findsOneWidget);

      final storedOrder = await mockRepo.getOrderById(testUser.id, 'ORD-PENDING-3');
      expect(storedOrder?.status, OrderStatus.pending);
    });

    testWidgets('Test 4: Confirming cancellation with Yes, Cancel invokes updateOrderStatus and updates status', (tester) async {
      final pendingOrder = sampleOrder.copyWith(
        id: 'ORD-PENDING-4',
        status: OrderStatus.pending,
      );

      final mockRepo = MockOrderRepository(
        initialOrders: {
          testUser.id: [pendingOrder],
        },
      );

      await tester.pumpWidget(
        createTestWidget(orderId: 'ORD-PENDING-4', repository: mockRepo),
      );
      await tester.pumpAndSettle();

      // Tap Cancel Order
      final cancelBtn = find.byKey(const Key('cancel_order_button'));
      await tester.ensureVisible(cancelBtn);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Tap "Yes, Cancel"
      await tester.tap(find.text('Yes, Cancel'));
      await tester.pumpAndSettle();

      // Verify repository was updated
      final storedOrder = await mockRepo.getOrderById(testUser.id, 'ORD-PENDING-4');
      expect(storedOrder?.status, OrderStatus.cancelled);

      // Verify success snackbar
      expect(find.text('Order #ORD-PENDING-4 has been cancelled.'), findsOneWidget);
    });

    testWidgets('Test 5: Successful cancellation naturally transitions UI to Order Cancelled timeline card', (tester) async {
      final pendingOrder = sampleOrder.copyWith(
        id: 'ORD-PENDING-5',
        status: OrderStatus.pending,
      );

      final mockRepo = MockOrderRepository(
        initialOrders: {
          testUser.id: [pendingOrder],
        },
      );

      await tester.pumpWidget(
        createTestWidget(orderId: 'ORD-PENDING-5', repository: mockRepo),
      );
      await tester.pumpAndSettle();

      // Cancel the order
      final cancelBtn = find.byKey(const Key('cancel_order_button'));
      await tester.ensureVisible(cancelBtn);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes, Cancel'));
      await tester.pumpAndSettle();

      // UI should now render the cancelled state from timeline
      expect(find.text('Order Cancelled'), findsOneWidget);
      expect(find.textContaining('This order has been cancelled successfully.'), findsOneWidget);
      expect(find.byKey(const Key('cancel_order_button')), findsNothing);
    });

    testWidgets('Test 6: Failure in repository stops loading, shows error feedback, and order remains pending', (tester) async {
      final pendingOrder = sampleOrder.copyWith(
        id: 'ORD-PENDING-6',
        status: OrderStatus.pending,
      );

      final failingRepo = _ErrorThrowingOrderRepository(
        initialOrders: {
          testUser.id: [pendingOrder],
        },
      );

      await tester.pumpWidget(
        createTestWidget(orderId: 'ORD-PENDING-6', repository: failingRepo),
      );
      await tester.pumpAndSettle();

      // Tap Cancel Order
      final cancelBtn = find.byKey(const Key('cancel_order_button'));
      await tester.ensureVisible(cancelBtn);
      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      // Confirm
      await tester.tap(find.text('Yes, Cancel'));
      await tester.pumpAndSettle();

      // Verify error snackbar appears
      expect(find.textContaining('Failed to cancel order'), findsOneWidget);

      // Verify order is still pending and cancel button is still available
      expect(find.byKey(const Key('cancel_order_button')), findsOneWidget);
      expect(find.text('Order Cancelled'), findsNothing);
    });
  });
}
