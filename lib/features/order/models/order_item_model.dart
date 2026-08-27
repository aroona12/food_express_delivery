/// Domain model representing a single food item line entry within a historical customer order.
///
/// Decoupled from Firebase and database SDKs.
class OrderItemModel {
  const OrderItemModel({
    required this.foodItemId,
    required this.restaurantId,
    required this.name,
    required this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  }) : assert(quantity > 0, 'Quantity must be greater than 0');

  /// Unique identifier of the catalog food item.
  final String foodItemId;

  /// Unique identifier of the restaurant preparing this item.
  final String restaurantId;

  /// Display name of the dish.
  final String name;

  /// Thumbnail image URL of the dish.
  final String imageUrl;

  /// Unit price for a single portion of this dish.
  final double unitPrice;

  /// Number of units ordered.
  final int quantity;

  /// Line item subtotal: [unitPrice] * [quantity].
  double get subtotal => double.parse((unitPrice * quantity).toStringAsFixed(2));

  /// Formatted USD unit price string (e.g. "$12.99").
  String get formattedUnitPrice => '\$${unitPrice.toStringAsFixed(2)}';

  /// Formatted USD subtotal string (e.g. "$25.98").
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  OrderItemModel copyWith({
    String? foodItemId,
    String? restaurantId,
    String? name,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
  }) {
    return OrderItemModel(
      foodItemId: foodItemId ?? this.foodItemId,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodItemId': foodItemId,
      'restaurantId': restaurantId,
      'name': name,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      foodItemId: (map['foodItemId'] ?? '') as String,
      restaurantId: (map['restaurantId'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      imageUrl: (map['imageUrl'] ?? '') as String,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemModel &&
          runtimeType == other.runtimeType &&
          foodItemId == other.foodItemId &&
          restaurantId == other.restaurantId &&
          name == other.name &&
          imageUrl == other.imageUrl &&
          unitPrice == other.unitPrice &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(
        foodItemId,
        restaurantId,
        name,
        imageUrl,
        unitPrice,
        quantity,
      );

  @override
  String toString() {
    return 'OrderItemModel(foodItemId: $foodItemId, name: $name, unitPrice: $unitPrice, quantity: $quantity, subtotal: $subtotal)';
  }
}
