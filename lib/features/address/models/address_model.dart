/// Domain model representing a customer's delivery address.
///
/// Decoupled from Firebase and database SDKs.
class AddressModel {
  const AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.phone,
    this.additionalInstructions,
    this.isDefault = false,
    required this.createdAt,
  });

  /// Unique identifier of the address record.
  final String id;

  /// Customer user identifier who owns this address.
  final String userId;

  /// Label categorization (e.g. 'Home', 'Work', 'Other').
  final String label;

  /// Street address, building name, apartment/suite number.
  final String fullAddress;

  /// City / Municipality name.
  final String city;

  /// Contact phone number for delivery driver.
  final String phone;

  /// Optional delivery instructions (e.g. 'Leave at reception', 'Door code 1234').
  final String? additionalInstructions;

  /// Whether this is the customer's default delivery address.
  final bool isDefault;

  /// Timestamp when the address was created.
  final DateTime createdAt;

  /// Clean single-line formatted address combining street and city.
  String get formattedAddress {
    if (city.isEmpty) return fullAddress;
    return '$fullAddress, $city';
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? fullAddress,
    String? city,
    String? phone,
    String? additionalInstructions,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      additionalInstructions:
          additionalInstructions ?? this.additionalInstructions,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'fullAddress': fullAddress,
      'city': city,
      'phone': phone,
      'additionalInstructions': additionalInstructions,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return AddressModel(
      id: (docId ?? map['id'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      label: (map['label'] ?? 'Home') as String,
      fullAddress: (map['fullAddress'] ?? '') as String,
      city: (map['city'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      additionalInstructions: map['additionalInstructions'] as String?,
      isDefault: (map['isDefault'] as bool?) ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          label == other.label &&
          fullAddress == other.fullAddress &&
          city == other.city &&
          phone == other.phone &&
          additionalInstructions == other.additionalInstructions &&
          isDefault == other.isDefault &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        label,
        fullAddress,
        city,
        phone,
        additionalInstructions,
        isDefault,
        createdAt,
      );

  @override
  String toString() {
    return 'AddressModel(id: $id, userId: $userId, label: $label, fullAddress: $fullAddress, city: $city, isDefault: $isDefault)';
  }
}
