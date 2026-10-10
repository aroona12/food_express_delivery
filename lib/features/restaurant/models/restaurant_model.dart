/// Domain model representing a Restaurant in the FoodExpress platform.
///
/// Fully decoupled from any database or backend SDK (e.g. Firebase).
class RestaurantModel {
  const RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.cuisine,
    required this.isOpen,
    required this.address,
    this.featuredBadge,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String deliveryFee;
  final String cuisine;
  final bool isOpen;
  final String address;
  final String? featuredBadge;

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? deliveryTime,
    String? deliveryFee,
    String? cuisine,
    bool? isOpen,
    String? address,
    String? featuredBadge,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      cuisine: cuisine ?? this.cuisine,
      isOpen: isOpen ?? this.isOpen,
      address: address ?? this.address,
      featuredBadge: featuredBadge ?? this.featuredBadge,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'cuisine': cuisine,
      'isOpen': isOpen,
      'address': address,
      if (featuredBadge != null) 'featuredBadge': featuredBadge,
    };
  }

  static String _parseDeliveryFee(dynamic value) {
    if (value == null) return '';
    if (value is num) {
      if (value == 0) return 'Free delivery';
      return '\$${value.toStringAsFixed(2)}';
    }
    final str = value.toString();
    final numVal = double.tryParse(str);
    if (numVal != null) {
      if (numVal == 0) return 'Free delivery';
      return '\$${numVal.toStringAsFixed(2)}';
    }
    return str;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
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

  factory RestaurantModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawName = map['name'] ?? map['name '] ?? '';
    final rawBadge = map['featuredBadge'] ?? map['featureBadge'];

    return RestaurantModel(
      id: (docId ?? map['id'] ?? '').toString(),
      name: rawName.toString(),
      description: (map['description'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      rating: _parseDouble(map['rating']),
      reviewCount: _parseInt(map['reviewCount']),
      deliveryTime: (map['deliveryTime'] ?? '').toString(),
      deliveryFee: _parseDeliveryFee(map['deliveryFee']),
      cuisine: (map['cuisine'] ?? '').toString(),
      isOpen: _parseBool(map['isOpen']),
      address: (map['address'] ?? '').toString(),
      featuredBadge: rawBadge?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          rating == other.rating &&
          reviewCount == other.reviewCount &&
          deliveryTime == other.deliveryTime &&
          deliveryFee == other.deliveryFee &&
          cuisine == other.cuisine &&
          isOpen == other.isOpen &&
          address == other.address &&
          featuredBadge == other.featuredBadge;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        imageUrl,
        rating,
        reviewCount,
        deliveryTime,
        deliveryFee,
        cuisine,
        isOpen,
        address,
        featuredBadge,
      );

  @override
  String toString() {
    return 'RestaurantModel(id: $id, name: $name, rating: $rating, cuisine: $cuisine, isOpen: $isOpen)';
  }
}
