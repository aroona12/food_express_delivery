import 'package:flutter/foundation.dart';
import 'cart_item_model.dart';

/// Domain model representing the complete customer shopping cart.
///
/// Contains immutable line items, derived pricing totals, item counts, and centralized delivery fee logic.
class CartModel {
  const CartModel({
    this.items = const [],
    this.restaurantId,
  });

  /// Standard fixed delivery fee applied when the cart is not empty.
  static const double standardDeliveryFee = 2.99;

  /// Centralized calculation helper for delivery fees across the app.
  static double calculateDeliveryFee(double subtotal, {bool isEmpty = false}) {
    if (isEmpty || subtotal <= 0.0) {
      return 0.0;
    }
    return standardDeliveryFee;
  }

  /// List of items currently in the cart.
  final List<CartItemModel> items;

  /// Unique restaurant ID associated with the items in the cart.
  final String? restaurantId;

  /// Effective restaurant ID for this cart. Evaluates to `null` when the cart is empty.
  String? get effectiveRestaurantId {
    if (items.isEmpty) return null;
    return restaurantId ?? items.first.restaurantId;
  }

  /// Total count of all item units in the cart.
  int get totalItemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Total sum of all items in the cart before delivery fee.
  double get subtotal {
    final rawSubtotal =
        items.fold<double>(0.0, (sum, item) => sum + item.subtotal);
    return double.parse(rawSubtotal.toStringAsFixed(2));
  }

  /// Delivery fee for the cart based on centralized rule.
  double get deliveryFee =>
      calculateDeliveryFee(subtotal, isEmpty: items.isEmpty);

  /// Grand total: [subtotal] + [deliveryFee].
  double get total {
    if (items.isEmpty) return 0.0;
    return double.parse((subtotal + deliveryFee).toStringAsFixed(2));
  }

  /// Returns whether the cart contains 0 items.
  bool get isEmpty => items.isEmpty;

  /// Returns whether the cart contains 1 or more items.
  bool get isNotEmpty => items.isNotEmpty;

  /// Cleanly formatted USD subtotal string (e.g. "$25.98").
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  /// Cleanly formatted USD delivery fee string (e.g. "$2.99" or "$0.00").
  String get formattedDeliveryFee => '\$${deliveryFee.toStringAsFixed(2)}';

  /// Cleanly formatted USD grand total string (e.g. "$28.97").
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  CartModel copyWith({
    List<CartItemModel>? items,
    String? restaurantId,
    bool clearRestaurantId = false,
  }) {
    return CartModel(
      items: items ?? this.items,
      restaurantId:
          clearRestaurantId ? null : (restaurantId ?? this.restaurantId),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'restaurantId': effectiveRestaurantId,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    return CartModel(
      items: rawItems
          .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      restaurantId: map['restaurantId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartModel &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items) &&
          effectiveRestaurantId == other.effectiveRestaurantId;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        effectiveRestaurantId,
      );

  @override
  String toString() {
    return 'CartModel(itemsCount: ${items.length}, totalItemCount: $totalItemCount, subtotal: $subtotal, deliveryFee: $deliveryFee, total: $total, restaurantId: $effectiveRestaurantId)';
  }
}
