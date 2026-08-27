import 'dart:async';
import 'dart:math';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

/// Abstract contract for customer order history, creation, and real-time tracking operations.
///
/// Decoupled from direct Firebase Firestore SDKs to enable test isolation with [MockOrderRepository]
/// and production persistence with [FirestoreOrderRepository].
abstract class OrderRepository {
  /// Fetches all historical and active orders placed by [userId].
  Future<List<OrderModel>> getOrders(String userId);

  /// Fetches a specific order by its [orderId] for the given [userId].
  /// Returns null if not found or if the order belongs to another user.
  Future<OrderModel?> getOrderById(String userId, String orderId);

  /// Persists a new customer order into Firestore and returns the generated/persisted [orderId].
  Future<String> createOrder(OrderModel order);

  /// Streams real-time updates for a single order by [orderId] belonging to [userId].
  Stream<OrderModel?> watchOrderById(String userId, String orderId);

  /// Streams real-time updates for all orders belonging to [userId].
  Stream<List<OrderModel>> watchOrders(String userId);
}

/// In-memory mock implementation of [OrderRepository] for unit/widget testing and simulated environments.
class MockOrderRepository implements OrderRepository {
  MockOrderRepository({
    Map<String, List<OrderModel>>? initialOrders,
    this.simulatedDelay = Duration.zero,
  }) : _ordersByUserId = initialOrders != null
            ? initialOrders.map((k, v) => MapEntry(k, List<OrderModel>.from(v)))
            : <String, List<OrderModel>>{};

  final Map<String, List<OrderModel>> _ordersByUserId;
  final Duration simulatedDelay;

  final Map<String, StreamController<OrderModel?>> _orderControllers = {};
  final Map<String, StreamController<List<OrderModel>>> _userOrdersControllers = {};

  StreamController<OrderModel?> _getOrderController(String orderId) {
    return _orderControllers.putIfAbsent(
      orderId,
      () => StreamController<OrderModel?>.broadcast(),
    );
  }

  StreamController<List<OrderModel>> _getUserOrdersController(String userId) {
    return _userOrdersControllers.putIfAbsent(
      userId,
      () => StreamController<List<OrderModel>>.broadcast(),
    );
  }

  Future<void> _delayIfNeeded() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
  }

  /// Creates realistic default seed orders for a user when their history is empty.
  List<OrderModel> _createDefaultOrdersForUser(String userId) {
    return [
      OrderModel(
        id: 'ORD-84920',
        userId: userId,
        restaurantId: 'rest-1',
        restaurantName: 'The Burger Studio',
        items: const [
          OrderItemModel(
            foodItemId: 'item-1',
            restaurantId: 'rest-1',
            name: 'Truffle Smash Burger',
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80',
            unitPrice: 14.99,
            quantity: 2,
          ),
          OrderItemModel(
            foodItemId: 'item-4',
            restaurantId: 'rest-1',
            name: 'Rosemary Garlic Fries',
            imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=600&auto=format&fit=crop&q=80',
            unitPrice: 4.99,
            quantity: 1,
          ),
          OrderItemModel(
            foodItemId: 'item-5',
            restaurantId: 'rest-1',
            name: 'Salted Caramel Milkshake',
            imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=600&auto=format&fit=crop&q=80',
            unitPrice: 6.49,
            quantity: 2,
          ),
        ],
        subtotal: 47.95,
        deliveryFee: 2.99,
        total: 50.94,
        status: OrderStatus.outForDelivery,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        deliveryAddress: '123 Market Street, Apt 4B, San Francisco, CA',
        paymentMethod: 'Cash on Delivery',
      ),
      OrderModel(
        id: 'ORD-73105',
        userId: userId,
        restaurantId: 'rest-3',
        restaurantName: 'Napoli Artisan Pizzeria',
        items: const [
          OrderItemModel(
            foodItemId: 'item-10',
            restaurantId: 'rest-3',
            name: 'Margherita D.O.P.',
            imageUrl: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=600&auto=format&fit=crop&q=80',
            unitPrice: 16.50,
            quantity: 1,
          ),
          OrderItemModel(
            foodItemId: 'item-11',
            restaurantId: 'rest-3',
            name: 'Diavola Spicy Salami',
            imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600&auto=format&fit=crop&q=80',
            unitPrice: 18.99,
            quantity: 1,
          ),
          OrderItemModel(
            foodItemId: 'item-13',
            restaurantId: 'rest-3',
            name: 'Traditional Tiramisu',
            imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600&auto=format&fit=crop&q=80',
            unitPrice: 7.99,
            quantity: 1,
          ),
        ],
        subtotal: 43.48,
        deliveryFee: 1.99,
        total: 45.47,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        deliveryAddress: '456 Elm Avenue, Suite 12, San Francisco, CA',
        paymentMethod: 'Cash on Delivery',
      ),
      OrderModel(
        id: 'ORD-61942',
        userId: userId,
        restaurantId: 'rest-4',
        restaurantName: 'Tokyo Ramen & Bowls',
        items: const [
          OrderItemModel(
            foodItemId: 'item-15',
            restaurantId: 'rest-4',
            name: 'Tonkotsu Special Ramen',
            imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=600&auto=format&fit=crop&q=80',
            unitPrice: 15.99,
            quantity: 2,
          ),
          OrderItemModel(
            foodItemId: 'item-17',
            restaurantId: 'rest-4',
            name: 'Crispy Pork Gyoza (6 pcs)',
            imageUrl: 'https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=600&auto=format&fit=crop&q=80',
            unitPrice: 7.49,
            quantity: 1,
          ),
        ],
        subtotal: 39.47,
        deliveryFee: 0.99,
        total: 40.46,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 5)),
        deliveryAddress: '123 Market Street, Apt 4B, San Francisco, CA',
        paymentMethod: 'Cash on Delivery',
      ),
      OrderModel(
        id: 'ORD-50211',
        userId: userId,
        restaurantId: 'rest-2',
        restaurantName: 'Smash Shack',
        items: const [
          OrderItemModel(
            foodItemId: 'item-6',
            restaurantId: 'rest-2',
            name: 'Double Smash Cheeseburger',
            imageUrl: 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=600&auto=format&fit=crop&q=80',
            unitPrice: 11.99,
            quantity: 1,
          ),
        ],
        subtotal: 11.99,
        deliveryFee: 1.49,
        total: 13.48,
        status: OrderStatus.cancelled,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        deliveryAddress: '123 Market Street, Apt 4B, San Francisco, CA',
        paymentMethod: 'Cash on Delivery',
      ),
    ];
  }

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    await _delayIfNeeded();
    if (userId.isEmpty) return [];

    final userOrders = _ordersByUserId.putIfAbsent(
      userId,
      () => _createDefaultOrdersForUser(userId),
    );

    final sorted = List<OrderModel>.from(userOrders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  Future<OrderModel?> getOrderById(String userId, String orderId) async {
    await _delayIfNeeded();
    if (userId.isEmpty || orderId.isEmpty) return null;

    final userOrders = _ordersByUserId.putIfAbsent(
      userId,
      () => _createDefaultOrdersForUser(userId),
    );

    try {
      return userOrders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> createOrder(OrderModel order) async {
    await _delayIfNeeded();
    if (order.userId == 'error-user') {
      throw Exception('Simulated Firestore order creation failure');
    }

    final finalOrderId = order.id.isNotEmpty
        ? order.id
        : 'ORD-${10000 + Random().nextInt(90000)}';

    final createdOrder = order.copyWith(id: finalOrderId);

    final userOrders = _ordersByUserId.putIfAbsent(
      order.userId,
      () => _createDefaultOrdersForUser(order.userId),
    );

    userOrders.insert(0, createdOrder);

    // Notify single-order stream and user-orders stream
    _getOrderController(finalOrderId).add(createdOrder);
    _getUserOrdersController(order.userId).add(List.unmodifiable(userOrders));

    return finalOrderId;
  }

  @override
  Stream<OrderModel?> watchOrderById(String userId, String orderId) async* {
    final initial = await getOrderById(userId, orderId);
    yield initial;
    yield* _getOrderController(orderId).stream;
  }

  @override
  Stream<List<OrderModel>> watchOrders(String userId) async* {
    final initial = await getOrders(userId);
    yield initial;
    yield* _getUserOrdersController(userId).stream;
  }

  /// Helper to mutate order status in-memory for testing progress transitions.
  void updateOrderStatus(String userId, String orderId, OrderStatus newStatus) {
    final list = _ordersByUserId[userId];
    if (list != null) {
      final index = list.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final updated = list[index].copyWith(status: newStatus);
        list[index] = updated;
        _getOrderController(orderId).add(updated);
        _getUserOrdersController(userId).add(List.unmodifiable(list));
      }
    }
  }

  void dispose() {
    for (final controller in _orderControllers.values) {
      controller.close();
    }
    for (final controller in _userOrdersControllers.values) {
      controller.close();
    }
  }
}
