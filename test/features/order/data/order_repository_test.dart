import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/order/data/order_repository.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';

void main() {
  group('MockOrderRepository', () {
    late MockOrderRepository repository;

    setUp(() {
      repository = MockOrderRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('getOrders returns realistic orders sorted by most recent date first', () async {
      final orders = await repository.getOrders('user-1');

      expect(orders, isNotEmpty);
      expect(orders.length, greaterThanOrEqualTo(3));

      // Verify descending date sort order
      for (int i = 0; i < orders.length - 1; i++) {
        expect(
          orders[i].createdAt.isAfter(orders[i + 1].createdAt) ||
              orders[i].createdAt.isAtSameMomentAs(orders[i + 1].createdAt),
          isTrue,
        );
      }
    });

    test('getOrderById finds order by its ID for the user', () async {
      final orders = await repository.getOrders('user-1');
      final targetId = orders.first.id;

      final found = await repository.getOrderById('user-1', targetId);
      expect(found, isNotNull);
      expect(found!.id, targetId);
      expect(found.userId, 'user-1');
    });

    test('getOrderById returns null when order does not exist', () async {
      final notFound = await repository.getOrderById('user-1', 'NON-EXISTENT-ID');
      expect(notFound, isNull);
    });

    test('getOrders returns empty when userId is empty string', () async {
      final emptyResult = await repository.getOrders('');
      expect(emptyResult, isEmpty);
    });

    test('createOrder inserts order and returns generated ID', () async {
      final newOrder = OrderModel(
        id: '',
        userId: 'test-user',
        restaurantId: 'rest-1',
        restaurantName: 'Test Diner',
        items: const [
          OrderItemModel(
            foodItemId: 'item-1',
            restaurantId: 'rest-1',
            name: 'Pizza',
            imageUrl: '',
            unitPrice: 15.0,
            quantity: 1,
          ),
        ],
        subtotal: 15.0,
        deliveryFee: 2.0,
        total: 17.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: '123 Test St',
      );

      final orderId = await repository.createOrder(newOrder);
      expect(orderId, isNotEmpty);
      expect(orderId.startsWith('ORD-'), isTrue);

      final userOrders = await repository.getOrders('test-user');
      expect(userOrders.first.id, orderId);
      expect(userOrders.first.status, OrderStatus.pending);
      expect(userOrders.first.deliveryAddress, '123 Test St');
    });

    test('watchOrderById emits initial and updated states on status change', () async {
      final newOrder = OrderModel(
        id: 'TRACK-1',
        userId: 'tracker-user',
        restaurantId: 'rest-1',
        restaurantName: 'Tracking Diner',
        items: const [
          OrderItemModel(
            foodItemId: 'item-1',
            restaurantId: 'rest-1',
            name: 'Burger',
            imageUrl: '',
            unitPrice: 10.0,
            quantity: 1,
          ),
        ],
        subtotal: 10.0,
        deliveryFee: 2.0,
        total: 12.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      await repository.createOrder(newOrder);

      final stream = repository.watchOrderById('tracker-user', 'TRACK-1');

      final emittedStatuses = <OrderStatus>[];
      final subscription = stream.listen((order) {
        if (order != null) {
          emittedStatuses.add(order.status);
        }
      });

      await Future<void>.delayed(const Duration(milliseconds: 10));

      repository.updateOrderStatus('tracker-user', 'TRACK-1', OrderStatus.preparing);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      repository.updateOrderStatus('tracker-user', 'TRACK-1', OrderStatus.outForDelivery);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emittedStatuses, contains(OrderStatus.pending));
      expect(emittedStatuses, contains(OrderStatus.preparing));
      expect(emittedStatuses, contains(OrderStatus.outForDelivery));

      await subscription.cancel();
    });

    test('watchOrders emits updated order list upon new order creation', () async {
      final stream = repository.watchOrders('stream-user');

      final listLengths = <int>[];
      final subscription = stream.listen((orders) {
        listLengths.add(orders.length);
      });

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final newOrder = OrderModel(
        id: 'S-1',
        userId: 'stream-user',
        restaurantId: 'r-1',
        restaurantName: 'Stream Rest',
        items: const [],
        subtotal: 10.0,
        deliveryFee: 1.0,
        total: 11.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      await repository.createOrder(newOrder);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(listLengths, isNotEmpty);
      expect(listLengths.last, greaterThan(0));

      await subscription.cancel();
    });

    test('orders can be pre-seeded and isolated per user', () async {
      final customOrder = OrderModel(
        id: 'CUSTOM-1',
        userId: 'custom-user',
        restaurantId: 'rest-custom',
        restaurantName: 'Custom Eatery',
        items: const [
          OrderItemModel(
            foodItemId: 'c-1',
            restaurantId: 'rest-custom',
            name: 'Custom Salad',
            imageUrl: '',
            unitPrice: 12.00,
            quantity: 1,
          ),
        ],
        subtotal: 12.00,
        deliveryFee: 2.00,
        total: 14.00,
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
      );

      final customRepo = MockOrderRepository(
        initialOrders: {
          'custom-user': [customOrder],
        },
      );

      final userOrders = await customRepo.getOrders('custom-user');
      expect(userOrders.length, 1);
      expect(userOrders.first.id, 'CUSTOM-1');
      expect(userOrders.first.restaurantName, 'Custom Eatery');
    });
  });
}
