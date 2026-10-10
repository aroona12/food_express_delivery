import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Represents the user's authorization role within FoodExpress.
enum UserRole {
  customer,
  restaurant,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.restaurant:
        return 'Restaurant Owner';
      case UserRole.admin:
        return 'System Admin';
    }
  }

  bool get isCustomer => this == UserRole.customer;
  bool get isRestaurant => this == UserRole.restaurant;
  bool get isAdmin => this == UserRole.admin;

  static UserRole fromString(String? roleStr) {
    if (roleStr == null) return UserRole.customer;
    return UserRole.values.firstWhere(
      (role) => role.name.toLowerCase() == roleStr.toLowerCase(),
      orElse: () => UserRole.customer,
    );
  }
}

/// The core domain user entity for FoodExpress.
///
/// Decoupled from Firebase SDKs so application logic, domain, and UI
/// are clean, testable, and independent of specific backend details.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = UserRole.customer,
    this.restaurantId,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.fcmToken,
    this.createdAt,
  });

  /// Unique identifier matching the Firebase Auth UID.
  final String id;

  /// User's email address.
  final String email;

  /// User's display name or full name.
  final String name;

  /// Authorization role (Customer, Restaurant, or Admin).
  final UserRole role;

  /// Associated restaurant ID if the user is a restaurant owner/staff.
  final String? restaurantId;

  /// Contact phone number for delivery orders and notifications.
  final String? phone;

  /// Primary delivery address for food orders.
  final String? address;

  /// Profile avatar photo URL.
  final String? profileImageUrl;

  /// Firebase Cloud Messaging device registration token for push notifications.
  final String? fcmToken;

  /// Account creation timestamp.
  final DateTime? createdAt;

  /// Creates a [UserModel] from a Firebase [fb.User] instance.
  factory UserModel.fromFirebaseUser(
    fb.User user, {
    UserRole role = UserRole.customer,
    String? restaurantId,
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: name ??
          (user.displayName != null && user.displayName!.isNotEmpty
              ? user.displayName!
              : 'FoodExpress Customer'),
      role: role,
      restaurantId: restaurantId,
      phone: phone ?? user.phoneNumber,
      address: address,
      profileImageUrl: profileImageUrl ?? user.photoURL,
      fcmToken: fcmToken,
      createdAt: createdAt ?? user.metadata.creationTime,
    );
  }

  /// Creates a copy of [UserModel] with updated fields.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? restaurantId,
    String? phone,
    String? address,
    String? profileImageUrl,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      restaurantId: restaurantId ?? this.restaurantId,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts this [UserModel] to a Map representation for Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      if (restaurantId != null) 'restaurantId': restaurantId,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Creates a [UserModel] from a Firestore or generic Map representation.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      restaurantId: map['restaurantId'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      fcmToken: map['fcmToken'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    try {
      final dynamic dynamicVal = value;
      if (dynamicVal.toDate != null && dynamicVal.toDate is Function) {
        return dynamicVal.toDate() as DateTime;
      }
    } catch (_) {}
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          role == other.role &&
          restaurantId == other.restaurantId &&
          phone == other.phone &&
          address == other.address &&
          profileImageUrl == other.profileImageUrl &&
          fcmToken == other.fcmToken &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      role.hashCode ^
      restaurantId.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      profileImageUrl.hashCode ^
      fcmToken.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, name: $name, role: $role, restaurantId: $restaurantId, phone: $phone, address: $address, profileImageUrl: $profileImageUrl, fcmToken: $fcmToken, createdAt: $createdAt)';
}
