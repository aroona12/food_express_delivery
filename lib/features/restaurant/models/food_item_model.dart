/// Domain model representing an individual food item or menu dish.
///
/// Kept strictly decoupled from backend/Firebase SDKs.
class FoodItemModel {
  const FoodItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.isAvailable = true,
    this.rating,
    this.calories,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final bool isAvailable;
  final double? rating;
  final int? calories;

  /// Returns a cleanly formatted USD price string (e.g. "$12.99").
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  FoodItemModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    String? category,
    bool? isAvailable,
    double? rating,
    int? calories,
  }) {
    return FoodItemModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      calories: calories ?? this.calories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      if (rating != null) 'rating': rating,
      if (calories != null) 'calories': calories,
    };
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double? _parseOptionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = true}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    return defaultValue;
  }

  factory FoodItemModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return FoodItemModel(
      id: (docId ?? map['id'] ?? '').toString(),
      restaurantId: (map['restaurantId'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      price: _parseDouble(map['price']),
      category: (map['category'] ?? '').toString(),
      isAvailable: _parseBool(map['isAvailable']),
      rating: _parseOptionalDouble(map['rating']),
      calories: _parseOptionalInt(map['calories']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          restaurantId == other.restaurantId &&
          name == other.name &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          price == other.price &&
          category == other.category &&
          isAvailable == other.isAvailable &&
          rating == other.rating &&
          calories == other.calories;

  @override
  int get hashCode => Object.hash(
        id,
        restaurantId,
        name,
        description,
        imageUrl,
        price,
        category,
        isAvailable,
        rating,
        calories,
      );

  @override
  String toString() {
    return 'FoodItemModel(id: $id, name: $name, price: $price, category: $category, isAvailable: $isAvailable)';
  }
}
