import '../../restaurant/models/food_item_model.dart';

/// Domain model representing an individual food item selected by the customer in their shopping cart.
///
/// Uses composition with [FoodItemModel] to avoid duplicating catalog attributes while exposing
/// clean, direct getters for pricing, item identity, and subtotal calculations.
class CartItemModel {
  const CartItemModel({
    required this.foodItem,
    this.quantity = 1,
  }) : assert(quantity > 0, 'Quantity must be greater than 0');

  final FoodItemModel foodItem;
  final int quantity;

  /// Unique food item ID.
  String get id => foodItem.id;

  /// Alias for unique food item ID.
  String get foodItemId => foodItem.id;

  /// Identity of the restaurant that prepares this food dish.
  String get restaurantId => foodItem.restaurantId;

  /// Display title of the dish.
  String get name => foodItem.name;

  /// Thumbnail image URL for the dish.
  String get imageUrl => foodItem.imageUrl;

  /// Price per single unit of the dish.
  double get unitPrice => foodItem.price;

  /// Total price for this cart line item: [unitPrice] * [quantity].
  double get subtotal => unitPrice * quantity;

  /// Cleanly formatted USD unit price string (e.g. "$12.99").
  String get formattedUnitPrice => foodItem.formattedPrice;

  /// Cleanly formatted USD line item subtotal string (e.g. "$25.98").
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  CartItemModel copyWith({
    FoodItemModel? foodItem,
    int? quantity,
  }) {
    return CartItemModel(
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodItem': foodItem.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      foodItem: FoodItemModel.fromMap(
        (map['foodItem'] as Map<String, dynamic>?) ?? map,
      ),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          foodItem == other.foodItem &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(foodItem, quantity);

  @override
  String toString() {
    return 'CartItemModel(foodItemId: $id, name: $name, unitPrice: $unitPrice, quantity: $quantity, subtotal: $subtotal)';
  }
}
