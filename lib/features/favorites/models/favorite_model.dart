import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain model representing a customer's favorite restaurant.
///
/// Decoupled from Firebase and storage implementations.
class FavoriteModel {
  const FavoriteModel({
    required this.restaurantId,
    required this.userId,
    required this.createdAt,
  });

  /// Unique identifier of the favorited restaurant.
  final String restaurantId;

  /// Unique identifier of the customer who favorited the restaurant.
  final String userId;

  /// Timestamp when the restaurant was favorited.
  final DateTime createdAt;

  FavoriteModel copyWith({
    String? restaurantId,
    String? userId,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return FavoriteModel(
      restaurantId: (docId != null && docId.isNotEmpty
              ? docId
              : (map['restaurantId'] ?? ''))
          as String,
      userId: (map['userId'] ?? '') as String,
      createdAt: parseDate(map['createdAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteModel &&
          runtimeType == other.runtimeType &&
          restaurantId == other.restaurantId &&
          userId == other.userId &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(restaurantId, userId, createdAt);

  @override
  String toString() {
    return 'FavoriteModel(restaurantId: $restaurantId, userId: $userId, createdAt: $createdAt)';
  }
}
