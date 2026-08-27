import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';
import 'package:foodexpressdelivery/features/order/providers/order_provider.dart';

void main() {
  group('Order Providers', () {
    late MockOrderRepository fakeOrderRepo;

    const testUser = UserModel(
      id: 'user-order-123',
      email: 'customer@test.com',
      name: 'Order Customer',
      role: UserRole.customer,
    );

    final sampleOrder = OrderModel(
      id: 'ORD-999',
      userId: 'user-order-123',
      restaurantId: 'rest-1',
      restaurantName: 'Burger Kitchen',
      items: const [
        OrderItemModel(
          foodItemId: 'f-1',
          restaurantId: 'rest-1',
          name: 'Classic Burger',
          imageUrl: '',
          unitPrice: 10.00,
          quantity: 1,
        ),
      ],
      subtotal: 10.00,
      deliveryFee: 2.00,
      total: 12.00,
      status: OrderStatus.preparing,
      createdAt: DateTime(2026, 8, 25, 14, 0),
    );

    ProviderContainer createContainer({
      UserModel? currentUser = testUser,
    }) {
      fakeOrderRepo = MockOrderRepository(
        initialOrders: {
          'user-order-123': [sampleOrder],
        },
      );

      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(fakeOrderRepo),
          currentUserProvider.overrideWithValue(currentUser),
        ],
      );

      addTearDown(container.dispose);
      return container;
    }

    test('orderHistoryProvider fetches orders for current authenticated user', () async {
      final container = createContainer();

      final orders = await container.read(orderHistoryProvider.future);
      expect(orders.length, 1);
      expect(orders.first.id, 'ORD-999');
      expect(orders.first.restaurantName, 'Burger Kitchen');
    });

    test('orderHistoryProvider returns empty when user is not authenticated', () async {
      final container = createContainer(currentUser: null);

      final orders = await container.read(orderHistoryProvider.future);
      expect(orders, isEmpty);
    });

    test('orderByIdProvider fetches specific order for current user', () async {
      final container = createContainer();

      final order = await container.read(orderByIdProvider('ORD-999').future);
      expect(order, isNotNull);
      expect(order!.id, 'ORD-999');
      expect(order.status, OrderStatus.preparing);
    });

    test('orderByIdProvider returns null for non-existent order ID', () async {
      final container = createContainer();

      final order = await container.read(orderByIdProvider('ORD-UNKNOWN').future);
      expect(order, isNull);
    });

    test('watchOrderByIdProvider emits real-time updates for specific order', () async {
      final container = createContainer();

      final initial = await container.read(watchOrderByIdProvider('ORD-999').future);
      expect(initial?.status, OrderStatus.preparing);
    });

    test('orderHistoryStreamProvider emits orders stream for authenticated user', () async {
      final container = createContainer();

      final list = await container.read(orderHistoryStreamProvider.future);
      expect(list.length, 1);
      expect(list.first.id, 'ORD-999');
    });
  });
}
