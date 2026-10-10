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

      await repository.updateOrderStatus('tracker-user', 'TRACK-1', OrderStatus.confirmed);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await repository.updateOrderStatus('tracker-user', 'TRACK-1', OrderStatus.preparing);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await repository.updateOrderStatus('tracker-user', 'TRACK-1', OrderStatus.outForDelivery);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emittedStatuses, contains(OrderStatus.pending));
      expect(emittedStatuses, contains(OrderStatus.confirmed));
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

    test('updateOrderStatus transitions order from pending to cancelled and notifies streams', () async {
      final pendingOrder = OrderModel(
        id: 'CANCEL-1',
        userId: 'cancel-user',
        restaurantId: 'rest-1',
        restaurantName: 'Test Kitchen',
        items: const [
          OrderItemModel(
            foodItemId: 'item-1',
            restaurantId: 'rest-1',
            name: 'Pizza',
            imageUrl: '',
            unitPrice: 12.0,
            quantity: 1,
          ),
        ],
        subtotal: 12.0,
        deliveryFee: 2.0,
        total: 14.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      await repository.createOrder(pendingOrder);

      final stream = repository.watchOrderById('cancel-user', 'CANCEL-1');
      final statuses = <OrderStatus>[];
      final subscription = stream.listen((order) {
        if (order != null) {
          statuses.add(order.status);
        }
      });

      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Customer cancels pending order
      await repository.updateOrderStatus('cancel-user', 'CANCEL-1', OrderStatus.cancelled);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(statuses, contains(OrderStatus.pending));
      expect(statuses.last, OrderStatus.cancelled);

      final fetched = await repository.getOrderById('cancel-user', 'CANCEL-1');
      expect(fetched?.status, OrderStatus.cancelled);

      await subscription.cancel();
    });

    test('updateOrderStatus rejects cancellation of an already delivered order', () async {
      final deliveredOrder = OrderModel(
        id: 'DELIVERED-1',
        userId: 'del-user',
        restaurantId: 'rest-1',
        restaurantName: 'Test Kitchen',
        items: const [],
        subtotal: 15.0,
        deliveryFee: 2.0,
        total: 17.0,
        status: OrderStatus.delivered,
        createdAt: DateTime.now(),
      );

      await repository.createOrder(deliveredOrder);

      // Attempting to cancel an already delivered order must throw an exception
      expect(
        () => repository.updateOrderStatus('del-user', 'DELIVERED-1', OrderStatus.cancelled),
        throwsA(isA<Exception>()),
      );

      final fetched = await repository.getOrderById('del-user', 'DELIVERED-1');
      expect(fetched?.status, OrderStatus.delivered);
    });

    test('updateOrderStatus rejects cancellation of an out-for-delivery order', () async {
      final outOrder = OrderModel(
        id: 'OUT-1',
        userId: 'out-user',
        restaurantId: 'rest-1',
        restaurantName: 'Test Kitchen',
        items: const [],
        subtotal: 20.0,
        deliveryFee: 2.0,
        total: 22.0,
        status: OrderStatus.outForDelivery,
        createdAt: DateTime.now(),
      );

      await repository.createOrder(outOrder);

      // Attempting to cancel an out-for-delivery order must throw an exception
      expect(
        () => repository.updateOrderStatus('out-user', 'OUT-1', OrderStatus.cancelled),
        throwsA(isA<Exception>()),
      );

      final fetched = await repository.getOrderById('out-user', 'OUT-1');
      expect(fetched?.status, OrderStatus.outForDelivery);
    });

    test('updateOrderStatus strictly preserves protected fields (total, items, restaurantId, userId)', () async {
      final testOrder = OrderModel(
        id: 'IMMUTABLE-1',
        userId: 'user-protect',
        restaurantId: 'rest-protect',
        restaurantName: 'Original Protected Kitchen',
        items: const [
          OrderItemModel(
            foodItemId: 'item-1',
            restaurantId: 'rest-protect',
            name: 'Special Steak',
            imageUrl: '',
            unitPrice: 35.0,
            quantity: 2,
          ),
        ],
        subtotal: 70.0,
        deliveryFee: 5.0,
        total: 75.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: '777 Protected Way',
        paymentMethod: 'Credit Card',
      );

      await repository.createOrder(testOrder);

      // Cancel order
      await repository.updateOrderStatus('user-protect', 'IMMUTABLE-1', OrderStatus.cancelled);

      final updated = await repository.getOrderById('user-protect', 'IMMUTABLE-1');
      expect(updated, isNotNull);
      expect(updated!.status, OrderStatus.cancelled);
      // All protected fields remain unchanged
      expect(updated.userId, 'user-protect');
      expect(updated.restaurantId, 'rest-protect');
      expect(updated.restaurantName, 'Original Protected Kitchen');
      expect(updated.subtotal, 70.0);
      expect(updated.deliveryFee, 5.0);
      expect(updated.total, 75.0);
      expect(updated.items.length, 1);
      expect(updated.items.first.name, 'Special Steak');
      expect(updated.deliveryAddress, '777 Protected Way');
      expect(updated.paymentMethod, 'Credit Card');
      expect(updated.updatedAt, isNotNull);
    });
  });
}
