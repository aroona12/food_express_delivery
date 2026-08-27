import '../models/address_model.dart';

/// Abstract contract for customer delivery address operations.
///
/// Decoupled from Firebase Firestore SDKs to enable seamless future integration.
abstract class AddressRepository {
  /// Fetches all saved delivery addresses for a [userId].
  Future<List<AddressModel>> getAddresses(String userId);

  /// Fetches a specific address by its [addressId] for the given [userId].
  Future<AddressModel?> getAddressById(String userId, String addressId);

  /// Adds a new delivery address for the customer.
  Future<AddressModel> addAddress(AddressModel address);

  /// Updates an existing delivery address.
  Future<AddressModel> updateAddress(AddressModel address);

  /// Deletes a delivery address by [addressId].
  Future<void> deleteAddress(String userId, String addressId);

  /// Sets an address as the default delivery address, marking all other user addresses as non-default.
  Future<void> setDefaultAddress(String userId, String addressId);
}

/// In-memory mock implementation of [AddressRepository] for Day 7.
class MockAddressRepository implements AddressRepository {
  MockAddressRepository({
    Map<String, List<AddressModel>>? initialData,
    this.simulatedDelay = Duration.zero,
  }) : _addressesByUserId = initialData != null
            ? initialData.map((k, v) => MapEntry(k, List<AddressModel>.from(v)))
            : <String, List<AddressModel>>{};

  final Map<String, List<AddressModel>> _addressesByUserId;
  final Duration simulatedDelay;

  Future<void> _delayIfNeeded() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
  }

  /// Creates realistic seed addresses for a user when their address list is empty.
  List<AddressModel> _createDefaultAddressesForUser(String userId) {
    return [
      AddressModel(
        id: 'addr-1',
        userId: userId,
        label: 'Home',
        fullAddress: '742 Evergreen Terrace, Apt 4B',
        city: 'Springfield',
        phone: '+1 (555) 012-3456',
        additionalInstructions: 'Ring doorbell twice. Leave on front porch if no answer.',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AddressModel(
        id: 'addr-2',
        userId: userId,
        label: 'Work',
        fullAddress: '100 Industrial Parkway, Floor 3, Suite 300',
        city: 'Springfield',
        phone: '+1 (555) 987-6543',
        additionalInstructions: 'Check in at building security reception desk on ground floor.',
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  @override
  Future<List<AddressModel>> getAddresses(String userId) async {
    await _delayIfNeeded();
    if (userId.isEmpty) return [];

    final list = _addressesByUserId.putIfAbsent(
      userId,
      () => _createDefaultAddressesForUser(userId),
    );

    return List.unmodifiable(list);
  }

  @override
  Future<AddressModel?> getAddressById(String userId, String addressId) async {
    await _delayIfNeeded();
    if (userId.isEmpty || addressId.isEmpty) return null;

    final list = await getAddresses(userId);
    try {
      return list.firstWhere((a) => a.id == addressId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    await _delayIfNeeded();
    final list = _addressesByUserId.putIfAbsent(
      address.userId,
      () => _createDefaultAddressesForUser(address.userId),
    );

    // If this address is set as default, mark all other addresses as non-default
    if (address.isDefault) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].isDefault) {
          list[i] = list[i].copyWith(isDefault: false);
        }
      }
    }

    final newAddress = address.id.isEmpty
        ? address.copyWith(id: 'addr-${DateTime.now().millisecondsSinceEpoch}')
        : address;

    list.add(newAddress);
    return newAddress;
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    await _delayIfNeeded();
    final list = _addressesByUserId.putIfAbsent(
      address.userId,
      () => _createDefaultAddressesForUser(address.userId),
    );

    // If this address is set as default, mark all other addresses as non-default
    if (address.isDefault) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].id != address.id && list[i].isDefault) {
          list[i] = list[i].copyWith(isDefault: false);
        }
      }
    }

    final index = list.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      list[index] = address;
      return address;
    } else {
      list.add(address);
      return address;
    }
  }

  @override
  Future<void> deleteAddress(String userId, String addressId) async {
    await _delayIfNeeded();
    final list = _addressesByUserId.putIfAbsent(
      userId,
      () => _createDefaultAddressesForUser(userId),
    );
    final wasDefault = list.any((a) => a.id == addressId && a.isDefault);
    list.removeWhere((a) => a.id == addressId);

    // If we deleted the default address and there are remaining addresses, make the first one default
    if (wasDefault && list.isNotEmpty) {
      list[0] = list[0].copyWith(isDefault: true);
    }
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    await _delayIfNeeded();
    final list = _addressesByUserId.putIfAbsent(
      userId,
      () => _createDefaultAddressesForUser(userId),
    );

    for (var i = 0; i < list.length; i++) {
      final isTarget = list[i].id == addressId;
      if (list[i].isDefault != isTarget) {
        list[i] = list[i].copyWith(isDefault: isTarget);
      }
    }
  }
}
