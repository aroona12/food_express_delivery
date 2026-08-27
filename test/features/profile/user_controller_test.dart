import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/profile/providers/user_provider.dart';
import '../../helpers/fake_user_repository.dart';

void main() {
  late FakeUserRepository fakeUserRepository;
  late ProviderContainer container;

  setUp(() {
    fakeUserRepository = FakeUserRepository(
      initialUsers: {
        'user-1': const UserModel(
          id: 'user-1',
          email: 'test@example.com',
          name: 'Jane Doe',
          phone: '+1 555-1234',
          address: '100 Main St',
        ),
      },
    );

    container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(fakeUserRepository),
      ],
    );
  });

  tearDown(() {
    fakeUserRepository.dispose();
    container.dispose();
  });

  group('UserController', () {
    test('initial state is AsyncValue<void>.data(null)', () {
      final state = container.read(userControllerProvider);
      expect(state, const AsyncValue<void>.data(null));
      expect(state.isLoading, false);
      expect(state.hasError, false);
    });

    test('updateProfile updates user fields in repository and sets state to data(null)', () async {
      final controller = container.read(userControllerProvider.notifier);

      final success = await controller.updateProfile(
        uid: 'user-1',
        name: 'Jane Smith',
        phone: '+1 555-9999',
        address: '200 Oak Ave',
      );

      expect(success, isTrue);
      expect(container.read(userControllerProvider), const AsyncValue<void>.data(null));

      final updatedUser = await fakeUserRepository.getUserProfile('user-1');
      expect(updatedUser?.name, 'Jane Smith');
      expect(updatedUser?.phone, '+1 555-9999');
      expect(updatedUser?.address, '200 Oak Ave');
    });

    test('updateProfile catches errors and updates state to AsyncError', () async {
      final controller = container.read(userControllerProvider.notifier);

      final success = await controller.updateProfile(
        uid: 'error-uid',
        name: 'Error Name',
      );

      expect(success, isFalse);
      final state = container.read(userControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('Simulated Firestore error'));
    });

    test('initializeProfile creates or merges user document', () async {
      final controller = container.read(userControllerProvider.notifier);

      const newUser = UserModel(
        id: 'user-2',
        email: 'new@example.com',
        name: 'New Customer',
        phone: '+1 555-0000',
        address: '300 Pine St',
      );

      final success = await controller.initializeProfile(newUser);

      expect(success, isTrue);
      expect(container.read(userControllerProvider), const AsyncValue<void>.data(null));

      final fetched = await fakeUserRepository.getUserProfile('user-2');
      expect(fetched?.name, 'New Customer');
      expect(fetched?.email, 'new@example.com');
    });

    test('clearError resets error state back to data(null)', () async {
      final controller = container.read(userControllerProvider.notifier);

      await controller.updateProfile(
        uid: 'error-uid',
        name: 'Error Name',
      );
      expect(container.read(userControllerProvider).hasError, isTrue);

      controller.clearError();
      expect(container.read(userControllerProvider).hasError, isFalse);
      expect(container.read(userControllerProvider), const AsyncValue<void>.data(null));
    });
  });
}
