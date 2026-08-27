import 'package:flutter/foundation.dart';
import '../../address/models/address_model.dart';
import '../../cart/models/cart_item_model.dart';
import '../../restaurant/models/restaurant_model.dart';

/// Domain state representation containing all information required to review and finalize checkout.
///
/// Decoupled from Firebase and storage SDKs. Reads from Cart state + Delivery Address state.
class CheckoutModel {
  const CheckoutModel({
    this.restaurant,
    this.items = const [],
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.total = 0.0,
    this.deliveryAddress,
    this.paymentMethod = 'Cash on Delivery',
    this.orderNotes,
  });

  /// Restaurant fulfilling this delivery order.
  final RestaurantModel? restaurant;

  /// Ordered food dishes and quantities from the shopping cart.
  final List<CartItemModel> items;

  /// Dishes subtotal sum before delivery fees.
  final double subtotal;

  /// Centralized delivery fee.
  final double deliveryFee;

  /// Grand total: [subtotal] + [deliveryFee].
  final double total;

  /// Selected customer delivery address.
  final AddressModel? deliveryAddress;

  /// Selected payment method label (e.g. 'Cash on Delivery').
  final String paymentMethod;

  /// Optional customer notes / special cooking or delivery instructions.
  final String? orderNotes;

  /// Total count of all dish units in the order.
  int get totalItemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Whether the checkout payload satisfies all business requirements:
  /// 1. Cart must contain at least 1 item.
  /// 2. A delivery address must be selected.
  /// 3. The delivery address must have a non-empty full address.
  bool get isValid =>
      items.isNotEmpty &&
      deliveryAddress != null &&
      deliveryAddress!.fullAddress.trim().isNotEmpty;

  /// Formatted USD subtotal string (e.g. "$25.98").
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  /// Formatted USD delivery fee string (e.g. "$2.99").
  String get formattedDeliveryFee => '\$${deliveryFee.toStringAsFixed(2)}';

  /// Formatted USD grand total string (e.g. "$28.97").
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  CheckoutModel copyWith({
    RestaurantModel? restaurant,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    AddressModel? deliveryAddress,
    String? paymentMethod,
    String? orderNotes,
  }) {
    return CheckoutModel(
      restaurant: restaurant ?? this.restaurant,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderNotes: orderNotes ?? this.orderNotes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutModel &&
          runtimeType == other.runtimeType &&
          restaurant == other.restaurant &&
          listEquals(items, other.items) &&
          subtotal == other.subtotal &&
          deliveryFee == other.deliveryFee &&
          total == other.total &&
          deliveryAddress == other.deliveryAddress &&
          paymentMethod == other.paymentMethod &&
          orderNotes == other.orderNotes;

  @override
  int get hashCode => Object.hash(
        restaurant,
        Object.hashAll(items),
        subtotal,
        deliveryFee,
        total,
        deliveryAddress,
        paymentMethod,
        orderNotes,
      );

  @override
  String toString() {
    return 'CheckoutModel(restaurant: ${restaurant?.name}, itemsCount: ${items.length}, total: $total, address: ${deliveryAddress?.label}, payment: $paymentMethod)';
  }
}
