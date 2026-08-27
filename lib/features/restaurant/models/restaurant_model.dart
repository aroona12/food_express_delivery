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

  factory RestaurantModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return RestaurantModel(
      id: (docId ?? map['id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      imageUrl: (map['imageUrl'] ?? '') as String,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      deliveryTime: (map['deliveryTime'] ?? '') as String,
      deliveryFee: (map['deliveryFee'] ?? '') as String,
      cuisine: (map['cuisine'] ?? '') as String,
      isOpen: (map['isOpen'] as bool?) ?? true,
      address: (map['address'] ?? '') as String,
      featuredBadge: map['featuredBadge'] as String?,
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
