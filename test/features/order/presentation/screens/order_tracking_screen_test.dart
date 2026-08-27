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
      MockOrderRepository? repository,
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
  });
}
