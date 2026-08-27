import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'order_item_model.dart';

/// Strongly-typed lifecycle status of a food order.
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.secondary;
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.outForDelivery:
        return Colors.deepPurple;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  Color get containerColor {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warningContainer;
      case OrderStatus.confirmed:
        return AppColors.surfaceVariant;
      case OrderStatus.preparing:
        return AppColors.primaryContainer;
      case OrderStatus.outForDelivery:
        return const Color(0xFFEDE7F6); // Soft purple container
      case OrderStatus.delivered:
        return const Color(0xFFE8F5E9); // Soft green container
      case OrderStatus.cancelled:
        return const Color(0xFFFFEBEE); // Soft red container
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.soup_kitchen_rounded;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.task_alt_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static OrderStatus fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'outfordelivery':
      case 'out_for_delivery':
      case 'out for delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

/// Domain entity representing a customer's placed food order in FoodExpress.
///
/// Decoupled from backend storage mechanisms.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.deliveryAddress,
    this.orderNotes,
    this.paymentMethod,
  });

  /// Unique order identifier.
  final String id;

  /// Customer user identifier who placed the order.
  final String userId;

  /// Identifier of the restaurant fulfilling the order.
  final String restaurantId;

  /// Name of the restaurant fulfilling the order.
  final String restaurantName;

  /// Ordered food dishes.
  final List<OrderItemModel> items;

  /// Subtotal sum before delivery fees.
  final double subtotal;

  /// Centralized delivery fee applied to this order.
  final double deliveryFee;

  /// Grand total: [subtotal] + [deliveryFee].
  final double total;

  /// Current order fulfillment status.
  final OrderStatus status;

  /// Timestamp when the order was placed.
  final DateTime createdAt;

  /// Formatted delivery address where the order is dispatched.
  final String? deliveryAddress;

  /// Customer instructions or notes for kitchen / delivery rider.
  final String? orderNotes;

  /// Selected payment method label (e.g. 'Cash on Delivery').
  final String? paymentMethod;

  /// Total count of all individual item units across dishes.
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Cleanly formatted USD subtotal string (e.g. "$25.98").
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  /// Cleanly formatted USD delivery fee string (e.g. "$2.99").
  String get formattedDeliveryFee => '\$${deliveryFee.toStringAsFixed(2)}';

  /// Cleanly formatted USD total string (e.g. "$28.97").
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  /// Formatted date string (e.g. "Aug 25, 2026 • 7:15 PM").
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[createdAt.month - 1];
    final day = createdAt.day;
    final year = createdAt.year;
    final hour24 = createdAt.hour;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final minute = createdAt.minute.toString().padLeft(2, '0');

    return '$month $day, $year • $hour12:$minute $period';
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    List<OrderItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    String? deliveryAddress,
    String? orderNotes,
    String? paymentMethod,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderNotes: orderNotes ?? this.orderNotes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (orderNotes != null) 'orderNotes': orderNotes,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value != null && value is! String) {
        try {
          final dynamic dynVal = value;
          if (dynVal.toDate != null) {
            return dynVal.toDate() as DateTime;
          }
        } catch (_) {}
      }
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return OrderModel(
      id: (docId ?? map['id'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      restaurantId: (map['restaurantId'] ?? '') as String,
      restaurantName: (map['restaurantName'] ?? '') as String,
      items: rawItems
          .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromString(map['status'] as String?),
      createdAt: parseDate(map['createdAt']),
      deliveryAddress: map['deliveryAddress'] as String?,
      orderNotes: map['orderNotes'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          restaurantId == other.restaurantId &&
          restaurantName == other.restaurantName &&
          listEquals(items, other.items) &&
          subtotal == other.subtotal &&
          deliveryFee == other.deliveryFee &&
          total == other.total &&
          status == other.status &&
          createdAt == other.createdAt &&
          deliveryAddress == other.deliveryAddress &&
          orderNotes == other.orderNotes &&
          paymentMethod == other.paymentMethod;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        restaurantId,
        restaurantName,
        Object.hashAll(items),
        subtotal,
        deliveryFee,
        total,
        status,
        createdAt,
        deliveryAddress,
        orderNotes,
        paymentMethod,
      );

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, restaurantName: $restaurantName, itemsCount: ${items.length}, total: $total, status: ${status.name})';
  }
}
