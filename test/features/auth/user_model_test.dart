import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('creates UserModel with default Customer role and optional fields', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'usr-1',
        email: 'alex@example.com',
        name: 'Alex Johnson',
        phone: '+1 555-0199',
        address: '123 Main St, Springfield',
        profileImageUrl: 'https://example.com/avatar.png',
        createdAt: now,
      );

      expect(user.id, 'usr-1');
      expect(user.email, 'alex@example.com');
      expect(user.name, 'Alex Johnson');
      expect(user.role, UserRole.customer);
      expect(user.role.displayName, 'Customer');
      expect(user.phone, '+1 555-0199');
      expect(user.address, '123 Main St, Springfield');
      expect(user.profileImageUrl, 'https://example.com/avatar.png');
      expect(user.createdAt, now);
    });

    test('serializes to and from map correctly with ISO string dates and restaurantId', () {
      final date = DateTime(2026, 8, 22, 12, 30);
      final user = UserModel(
        id: 'usr-2',
        email: 'owner@foodexpress.com',
        name: 'Burger Studio Owner',
        role: UserRole.restaurant,
        restaurantId: 'rest-1',
        phone: '+1 555-9988',
        address: '456 Market St',
        profileImageUrl: 'https://example.com/admin.jpg',
        createdAt: date,
      );

      final map = user.toMap();
      final restoredUser = UserModel.fromMap(map);

      expect(restoredUser.id, user.id);
      expect(restoredUser.email, user.email);
      expect(restoredUser.name, user.name);
      expect(restoredUser.role, UserRole.restaurant);
      expect(restoredUser.restaurantId, 'rest-1');
      expect(restoredUser.role.displayName, 'Restaurant Owner');
      expect(restoredUser.role.isRestaurant, isTrue);
      expect(restoredUser.role.isCustomer, isFalse);
      expect(restoredUser.role.isAdmin, isFalse);
      expect(restoredUser.phone, user.phone);
      expect(restoredUser.address, user.address);
      expect(restoredUser.profileImageUrl, user.profileImageUrl);
      expect(restoredUser.createdAt, date);
    });

    test('parses fromMap with epoch milliseconds and null fields safely', () {
      final map = {
        'id': 'usr-3',
        'email': 'customer@foodexpress.com',
        'name': 'Sample Customer',
        'createdAt': 1700000000000,
      };

      final user = UserModel.fromMap(map);

      expect(user.id, 'usr-3');
      expect(user.email, 'customer@foodexpress.com');
      expect(user.name, 'Sample Customer');
      expect(user.role, UserRole.customer);
      expect(user.phone, isNull);
      expect(user.address, isNull);
      expect(user.createdAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
    });

    test('copyWith modifies specified fields only', () {
      const original = UserModel(
        id: 'usr-4',
        email: 'test@example.com',
        name: 'Original Name',
        phone: '111',
        address: 'Original Address',
      );

      final updated = original.copyWith(
        name: 'Updated Name',
        phone: '222',
        address: 'New Address',
        role: UserRole.admin,
        restaurantId: 'rest-9',
      );

      expect(updated.id, 'usr-4');
      expect(updated.email, 'test@example.com');
      expect(updated.name, 'Updated Name');
      expect(updated.phone, '222');
      expect(updated.address, 'New Address');
      expect(updated.role, UserRole.admin);
      expect(updated.role.isAdmin, isTrue);
      expect(updated.restaurantId, 'rest-9');
    });

    test('UserRole fromString parses accurately with fallback', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
      expect(UserRole.fromString('restaurant'), UserRole.restaurant);
      expect(UserRole.fromString('RESTAURANT'), UserRole.restaurant);
      expect(UserRole.fromString('customer'), UserRole.customer);
      expect(UserRole.fromString('unknown'), UserRole.customer);
      expect(UserRole.fromString(null), UserRole.customer);
    });
  });
}
