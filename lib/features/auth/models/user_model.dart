import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Represents the user's authorization role within FoodExpress.
enum UserRole {
  customer,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.admin:
        return 'Restaurant Admin';
    }
  }

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
    this.phone,
    this.address,
    this.profileImageUrl,
    this.createdAt,
  });

  /// Unique identifier matching the Firebase Auth UID.
  final String id;

  /// User's email address.
  final String email;

  /// User's display name or full name.
  final String name;

  /// Authorization role (Customer or Admin).
  final UserRole role;

  /// Contact phone number for delivery orders and notifications.
  final String? phone;

  /// Primary delivery address for food orders.
  final String? address;

  /// Profile avatar photo URL.
  final String? profileImageUrl;

  /// Account creation timestamp.
  final DateTime? createdAt;

  /// Creates a [UserModel] from a Firebase [fb.User] instance.
  factory UserModel.fromFirebaseUser(
    fb.User user, {
    UserRole role = UserRole.customer,
    String? name,
    String? phone,
    String? address,
    String? profileImageUrl,
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
      phone: phone ?? user.phoneNumber,
      address: address,
      profileImageUrl: profileImageUrl ?? user.photoURL,
      createdAt: createdAt ?? user.metadata.creationTime,
    );
  }

  /// Creates a copy of [UserModel] with updated fields.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? address,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
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
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
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
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
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
          phone == other.phone &&
          address == other.address &&
          profileImageUrl == other.profileImageUrl &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      role.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      profileImageUrl.hashCode ^
      createdAt.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, name: $name, role: $role, phone: $phone, address: $address, profileImageUrl: $profileImageUrl, createdAt: $createdAt)';
}
