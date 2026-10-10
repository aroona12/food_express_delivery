import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/address_repository.dart';
import '../data/firestore_address_repository.dart';
import '../models/address_model.dart';

/// Provider exposing the [AddressRepository] singleton for the app session.
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return FirestoreAddressRepository();
});

/// State notifier managing the reactive list and mutation lifecycle of customer delivery addresses.
class AddressListNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
  AddressListNotifier({
    required this.repository,
    required this.userId,
  }) : super(const AsyncValue.loading()) {
    if (userId != null && userId!.isNotEmpty) {
      loadAddresses();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  final AddressRepository repository;
  final String? userId;

  /// Loads all addresses for the current user.
  Future<void> loadAddresses() async {
    final uid = userId;
    if (uid == null || uid.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await repository.getAddresses(uid);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Adds a new delivery address and refreshes the local state.
  Future<AddressModel?> addAddress(AddressModel address) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) return null;

    try {
      final savedAddress = await repository.addAddress(address);
      final list = await repository.getAddresses(uid);
      state = AsyncValue.data(list);
      return savedAddress;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Updates an existing delivery address and refreshes the local state.
  Future<AddressModel?> updateAddress(AddressModel address) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) return null;

    try {
      final updated = await repository.updateAddress(address);
      final list = await repository.getAddresses(uid);
      state = AsyncValue.data(list);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Deletes an address and refreshes the local state.
  Future<void> deleteAddress(String addressId) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) return;

    try {
      await repository.deleteAddress(uid, addressId);
      final list = await repository.getAddresses(uid);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Sets an address as the default delivery address.
  Future<void> setDefaultAddress(String addressId) async {
    final uid = userId;
    if (uid == null || uid.isEmpty) return;

    try {
      await repository.setDefaultAddress(uid, addressId);
      final list = await repository.getAddresses(uid);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider managing the customer address list state.
final addressListProvider =
    StateNotifierProvider<AddressListNotifier, AsyncValue<List<AddressModel>>>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return AddressListNotifier(
    repository: repository,
    userId: user?.id,
  );
});

/// Provider resolving the current user's default delivery address.
final defaultAddressProvider = Provider<AddressModel?>((ref) {
  final addressesAsync = ref.watch(addressListProvider);
  return addressesAsync.maybeWhen(
    data: (addresses) {
      if (addresses.isEmpty) return null;
      try {
        return addresses.firstWhere((a) => a.isDefault);
      } catch (_) {
        return addresses.first;
      }
    },
    orElse: () => null,
  );
});

/// State provider storing the explicitly selected address ID for checkout or active delivery.
final selectedAddressIdProvider = StateProvider<String?>((ref) => null);

/// Provider resolving the currently active / selected [AddressModel] for checkout.
/// Falls back to [defaultAddressProvider] if no manual override is active.
final selectedAddressProvider = Provider<AddressModel?>((ref) {
  final explicitId = ref.watch(selectedAddressIdProvider);
  final addressesAsync = ref.watch(addressListProvider);

  return addressesAsync.maybeWhen(
    data: (addresses) {
      if (addresses.isEmpty) return null;

      if (explicitId != null) {
        try {
          return addresses.firstWhere((a) => a.id == explicitId);
        } catch (_) {
          // If explicit ID not found in current list, fallback
        }
      }

      // Fallback to default address
      try {
        return addresses.firstWhere((a) => a.isDefault);
      } catch (_) {
        return addresses.first;
      }
    },
    orElse: () => null,
  );
});
