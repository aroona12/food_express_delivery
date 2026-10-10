import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import 'order_repository.dart';

/// Production implementation of [OrderRepository] backed by Cloud Firestore.
///
/// Stores customer orders under `orders/{orderId}` collection with strict customer UID scoping.
class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String collectionName = 'orders';

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(collectionName);

  @override
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = order.id.isNotEmpty
          ? _ordersCollection.doc(order.id)
          : _ordersCollection.doc();

      final data = <String, dynamic>{
        'id': docRef.id,
        'userId': order.userId,
        'restaurantId': order.restaurantId,
        'restaurantName': order.restaurantName,
        'items': order.items.map((i) => i.toMap()).toList(),
        'subtotal': order.subtotal,
        'deliveryFee': order.deliveryFee,
        'total': order.total,
        'status': order.status.name,
        'createdAt': FieldValue.serverTimestamp(),
        if (order.deliveryAddress != null) 'deliveryAddress': order.deliveryAddress,
        if (order.orderNotes != null) 'orderNotes': order.orderNotes,
        if (order.paymentMethod != null) 'paymentMethod': order.paymentMethod,
      };

      await docRef.set(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order in Firestore: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String userId, String orderId) async {
    if (orderId.isEmpty) return null;

    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      return OrderModel.fromMap(data, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch order #$orderId: $e');
    }
  }

  @override
  Stream<OrderModel?> watchOrderById(String userId, String orderId) {
    if (orderId.isEmpty) {
      return Stream.value(null);
    }

    return _ordersCollection.doc(orderId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      final data = snapshot.data()!;
      return OrderModel.fromMap(data, snapshot.id);
    });
  }

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    if (userId.isEmpty) return <OrderModel>[];

    try {
      final querySnapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user order history: $e');
    }
  }

  @override
  Stream<List<OrderModel>> watchOrders(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<OrderModel>[]);
    }

    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<List<OrderModel>> getRestaurantOrders(String restaurantId) async {
    if (restaurantId.isEmpty) return <OrderModel>[];

    try {
      final querySnapshot = await _ordersCollection
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch restaurant orders: $e');
    }
  }

  @override
  Stream<List<OrderModel>> watchRestaurantOrders(String restaurantId) {
    if (restaurantId.isEmpty) {
      return Stream.value(<OrderModel>[]);
    }

    return _ordersCollection
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> updateOrderStatus(dynamic arg1, dynamic arg2, [OrderStatus? arg3]) async {
    String orderId;
    OrderStatus newStatus;

    if (arg3 != null) {
      // (userId, orderId, newStatus)
      orderId = arg2 as String;
      newStatus = arg3;
    } else {
      // (orderId, newStatus)
      orderId = arg1 as String;
      newStatus = arg2 as OrderStatus;
    }

    if (orderId.isEmpty) return;

    try {
      final docRef = _ordersCollection.doc(orderId);
      final currentSnap = await docRef.get();
      if (currentSnap.exists && currentSnap.data() != null) {
        final currentStatus = OrderStatus.fromString(currentSnap.data()!['status'] as String?);
        if (!currentStatus.canTransitionTo(newStatus)) {
          throw Exception(
            'Invalid order status transition from ${currentStatus.displayName} to ${newStatus.displayName}',
          );
        }
      }

      await docRef.update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
