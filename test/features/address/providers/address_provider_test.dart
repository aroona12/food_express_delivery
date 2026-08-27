import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/address/data/address_repository.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';
import 'package:foodexpressdelivery/features/address/providers/address_provider.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';

void main() {
  group('Address Providers & AddressListNotifier Tests', () {
    late MockAddressRepository fakeAddressRepo;

    const testUser = UserModel(
      id: 'addr-user-1',
      email: 'customer@test.com',
      name: 'Test Customer',
      role: UserRole.customer,
    );

    final address1 = AddressModel(
      id: 'addr-1',
      userId: 'addr-user-1',
      label: 'Home',
      fullAddress: '742 Evergreen Terrace',
      city: 'Springfield',
      phone: '+1 (555) 012-3456',
      isDefault: true,
      createdAt: DateTime(2026, 8, 20),
    );

    final address2 = AddressModel(
      id: 'addr-2',
      userId: 'addr-user-1',
      label: 'Work',
      fullAddress: '100 Industrial Parkway',
      city: 'Springfield',
      phone: '+1 (555) 987-6543',
      isDefault: false,
      createdAt: DateTime(2026, 8, 21),
    );

    ProviderContainer createContainer({
      UserModel? currentUser = testUser,
      List<AddressModel>? initialAddresses,
    }) {
      fakeAddressRepo = MockAddressRepository(
        initialData: {
          if (currentUser != null)
            currentUser.id: initialAddresses ?? [address1, address2],
        },
      );

      final container = ProviderContainer(
        overrides: [
          addressRepositoryProvider.overrideWithValue(fakeAddressRepo),
          currentUserProvider.overrideWithValue(currentUser),
        ],
      );

      addTearDown(container.dispose);
      return container;
    }

    test('addressListProvider loads user addresses on initialization', () async {
      final container = createContainer();
      await container.read(addressListProvider.notifier).loadAddresses();

      final state = container.read(addressListProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.length, 2);
      expect(state.value!.first.id, 'addr-1');
    });

    test('defaultAddressProvider resolves the address with isDefault=true', () async {
      final container = createContainer();
      await container.read(addressListProvider.notifier).loadAddresses();

      final defaultAddress = container.read(defaultAddressProvider);
      expect(defaultAddress, isNotNull);
      expect(defaultAddress!.id, 'addr-1');
      expect(defaultAddress.isDefault, isTrue);
    });

    test('selectedAddressProvider returns defaultAddress when no explicit selection is set', () async {
      final container = createContainer();
      await container.read(addressListProvider.notifier).loadAddresses();

      final selected = container.read(selectedAddressProvider);
      expect(selected, isNotNull);
      expect(selected!.id, 'addr-1');
    });

    test('selectedAddressProvider updates reactively when selectedAddressIdProvider changes', () async {
      final container = createContainer();
      await container.read(addressListProvider.notifier).loadAddresses();

      // Change explicit selection to addr-2
      container.read(selectedAddressIdProvider.notifier).state = 'addr-2';

      final selected = container.read(selectedAddressProvider);
      expect(selected, isNotNull);
      expect(selected!.id, 'addr-2');
      expect(selected.label, 'Work');
    });

    test('AddressListNotifier.addAddress adds new address and refreshes list', () async {
      final container = createContainer();
      await container.read(addressListProvider.notifier).loadAddresses();

      final newAddress = AddressModel(
        id: 'addr-3',
        userId: 'addr-user-1',
        label: 'Gym',
        fullAddress: '500 Fitness Blvd',
        city: 'Springfield',
        phone: '555-5555',
        isDefault: false,
        createdAt: DateTime.now(),
      );

      final notifier = container.read(addressListProvider.notifier);
      final created = await notifier.addAddress(newAddress);

      expect(created, isNotNull);
      expect(created!.id, 'addr-3');

      final list = container.read(addressListProvider).value!;
      expect(list.length, 3);
      expect(list.any((a) => a.id == 'addr-3'), isTrue);
    });

    test('AddressListNotifier.updateAddress updates address in state and repo', () async {
      final container = createContainer();
      await container.read(addressListProvider.notifier).loadAddresses();

      final notifier = container.read(addressListProvider.notifier);
      final updated = address1.copyWith(fullAddress: '999 New Evergreen St');
      await notifier.updateAddress(updated);

      final list = container.read(addressListProvider).value!;
      final found = list.firstWhere((a) => a.id == 'addr-1');
      expect(found.fullAddress, '999 New Evergreen St');
    });

    test('AddressListNotifier.deleteAddress removes address from state and repo', () async {
      final container = createContainer();
      await container.read(addressListProvider.notifier).loadAddresses();

      final notifier = container.read(addressListProvider.notifier);
      await notifier.deleteAddress('addr-2');

      final list = container.read(addressListProvider).value!;
      expect(list.length, 1);
      expect(list.any((a) => a.id == 'addr-2'), isFalse);
    });

    test('AddressListNotifier.setDefaultAddress toggles default address in state', () async {
      final container = createContainer();
      await container.read(addressListProvider.notifier).loadAddresses();

      final notifier = container.read(addressListProvider.notifier);
      await notifier.setDefaultAddress('addr-2');

      final defaultAddress = container.read(defaultAddressProvider);
      expect(defaultAddress!.id, 'addr-2');
    });

    test('returns empty list when currentUser is null', () async {
      final container = createContainer(currentUser: null);
      await container.read(addressListProvider.notifier).loadAddresses();

      final list = container.read(addressListProvider).value!;
      expect(list, isEmpty);
      expect(container.read(defaultAddressProvider), isNull);
      expect(container.read(selectedAddressProvider), isNull);
    });
  });
}
