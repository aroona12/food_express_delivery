import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/firestore_order_repository.dart';
import '../data/order_repository.dart';
import '../models/order_model.dart';

/// Provider exposing the [OrderRepository] singleton for the app session.
/// Defaults to [FirestoreOrderRepository] for production. Can be overridden in tests.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirestoreOrderRepository();
});

/// Stream provider delivering real-time Firestore updates for all orders placed by the current user.
final orderHistoryStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final uid = user?.id;

  if (uid == null || uid.isEmpty) {
    return Stream.value(<OrderModel>[]);
  }

  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchOrders(uid);
});

/// Future provider fetching all historical and active orders for the current authenticated user once.
final orderHistoryProvider = FutureProvider<List<OrderModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final uid = user?.id;

  if (uid == null || uid.isEmpty) {
    return <OrderModel>[];
  }

  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrders(uid);
});

/// Stream provider delivering real-time Firestore updates for a specific order by [orderId].
final watchOrderByIdProvider =
    StreamProvider.family<OrderModel?, String>((ref, orderId) {
  final user = ref.watch(currentUserProvider);
  final uid = user?.id;

  if (uid == null || uid.isEmpty || orderId.isEmpty) {
    return Stream.value(null);
  }

  final repository = ref.watch(orderRepositoryProvider);
  return repository.watchOrderById(uid, orderId);
});

/// Future family provider fetching a specific [OrderModel] by [orderId] for the current authenticated user once.
final orderByIdProvider =
    FutureProvider.family<OrderModel?, String>((ref, orderId) async {
  final user = ref.watch(currentUserProvider);
  final uid = user?.id;

  if (uid == null || uid.isEmpty || orderId.isEmpty) {
    return null;
  }

  final repository = ref.watch(orderRepositoryProvider);
  return repository.getOrderById(uid, orderId);
});
