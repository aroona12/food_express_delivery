import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/address/data/address_repository.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';

void main() {
  group('MockAddressRepository Tests', () {
    late MockAddressRepository repo;
    const testUserId = 'user-test-123';

    setUp(() {
      repo = MockAddressRepository();
    });

    test('getAddresses returns default seed addresses when user history is empty', () async {
      final addresses = await repo.getAddresses(testUserId);

      expect(addresses.length, 2);
      expect(addresses.first.label, 'Home');
      expect(addresses.first.isDefault, isTrue);
      expect(addresses.last.label, 'Work');
      expect(addresses.last.isDefault, isFalse);
    });

    test('getAddresses returns empty list for empty userId string', () async {
      final addresses = await repo.getAddresses('');
      expect(addresses, isEmpty);
    });

    test('getAddressById returns matching address and null for non-existent ID', () async {
      final address = await repo.getAddressById(testUserId, 'addr-1');
      expect(address, isNotNull);
      expect(address!.label, 'Home');

      final notFound = await repo.getAddressById(testUserId, 'addr-nonexistent');
      expect(notFound, isNull);

      final emptyCheck = await repo.getAddressById('', 'addr-1');
      expect(emptyCheck, isNull);
    });

    test('addAddress appends new address to user record', () async {
      final newAddress = AddressModel(
        id: 'addr-new',
        userId: testUserId,
        label: 'Gym',
        fullAddress: '450 Fitness Way',
        city: 'Springfield',
        phone: '+1 (555) 333-4444',
        isDefault: false,
        createdAt: DateTime.now(),
      );

      final created = await repo.addAddress(newAddress);
      expect(created.id, 'addr-new');

      final list = await repo.getAddresses(testUserId);
      expect(list.length, 3);
      expect(list.any((a) => a.id == 'addr-new'), isTrue);
    });

    test('addAddress with isDefault=true resets other addresses to non-default', () async {
      final defaultAddress = AddressModel(
        id: 'addr-new-default',
        userId: testUserId,
        label: 'Beach House',
        fullAddress: '10 Ocean Drive',
        city: 'Shelbyville',
        phone: '+1 (555) 777-8888',
        isDefault: true,
        createdAt: DateTime.now(),
      );

      await repo.addAddress(defaultAddress);

      final list = await repo.getAddresses(testUserId);
      final added = list.firstWhere((a) => a.id == 'addr-new-default');
      final original = list.firstWhere((a) => a.id == 'addr-1');

      expect(added.isDefault, isTrue);
      expect(original.isDefault, isFalse);
    });

    test('updateAddress modifies existing address in place', () async {
      final existing = (await repo.getAddressById(testUserId, 'addr-1'))!;
      final modified = existing.copyWith(
        fullAddress: '744 Evergreen Terrace, Suite 10',
        city: 'Capital City',
      );

      await repo.updateAddress(modified);

      final updated = (await repo.getAddressById(testUserId, 'addr-1'))!;
      expect(updated.fullAddress, '744 Evergreen Terrace, Suite 10');
      expect(updated.city, 'Capital City');
    });

    test('deleteAddress removes specified address and reassigns default if necessary', () async {
      // Default is addr-1
      await repo.deleteAddress(testUserId, 'addr-1');

      final list = await repo.getAddresses(testUserId);
      expect(list.length, 1);
      expect(list.first.id, 'addr-2');
      expect(list.first.isDefault, isTrue); // Reassigned as default
    });

    test('setDefaultAddress sets targeted address as default and unsets others', () async {
      await repo.setDefaultAddress(testUserId, 'addr-2');

      final list = await repo.getAddresses(testUserId);
      final addr1 = list.firstWhere((a) => a.id == 'addr-1');
      final addr2 = list.firstWhere((a) => a.id == 'addr-2');

      expect(addr1.isDefault, isFalse);
      expect(addr2.isDefault, isTrue);
    });
  });
}
