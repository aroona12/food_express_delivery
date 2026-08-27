import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/checkout/presentation/screens/order_success_screen.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';

void main() {
  group('OrderSuccessScreen Widget Tests', () {
    const testUser = UserModel(
      id: 'success-user-1',
      email: 'customer@test.com',
      name: 'Happy Customer',
      role: UserRole.customer,
    );

    final sampleOrder = OrderModel(
      id: 'ORD-98765',
      userId: 'success-user-1',
      restaurantId: 'rest-1',
      restaurantName: 'The Burger Studio',
      items: const [
        OrderItemModel(
          foodItemId: 'f-1',
          restaurantId: 'rest-1',
          name: 'Truffle Smash Burger',
          imageUrl: '',
          unitPrice: 15.00,
          quantity: 2,
        ),
      ],
      subtotal: 30.00,
      deliveryFee: 2.99,
      total: 32.99,
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 8, 25, 18, 30),
      deliveryAddress: '742 Evergreen Terrace, Springfield',
      paymentMethod: 'Cash on Delivery',
    );

    Widget createTestWidget({
      String orderId = 'ORD-98765',
      OrderModel? order,
      bool nullOrder = false,
    }) {
      final effectiveOrder = nullOrder ? null : (order ?? sampleOrder);
      final mockOrderRepo = MockOrderRepository(
        initialOrders: {
          testUser.id: effectiveOrder != null ? [effectiveOrder] : [],
        },
      );

      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(testUser),
          orderRepositoryProvider.overrideWithValue(mockOrderRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: OrderSuccessScreen(orderId: orderId),
        ),
      );
    }

    testWidgets('renders success heading, order ID, restaurant, and total', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Order Confirmed'), findsOneWidget);
      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.text('Order ID: #ORD-98765'), findsOneWidget);
      expect(find.text('The Burger Studio'), findsOneWidget);
      expect(find.text('\$32.99'), findsOneWidget);
      expect(find.text('742 Evergreen Terrace, Springfield'), findsOneWidget);

      expect(find.byKey(const Key('order_success_track_button')), findsOneWidget);
      expect(find.byKey(const Key('order_success_home_button')), findsOneWidget);
    });

    testWidgets('renders fallback loading placeholder info when order stream is syncing', (tester) async {
      await tester.pumpWidget(createTestWidget(orderId: 'ORD-UNKNOWN', nullOrder: true));
      await tester.pumpAndSettle();

      expect(find.text('Order Confirmed'), findsOneWidget);
      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.text('Order ID: #ORD-UNKNOWN'), findsOneWidget);
      expect(find.text('Pending Confirmation'), findsOneWidget);
      expect(find.text('25-35 minutes'), findsOneWidget);
    });
  });
}
