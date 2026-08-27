import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import '../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late ProviderContainer container;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
      ],
    );
  });

  tearDown(() {
    fakeAuthRepository.dispose();
    container.dispose();
  });

  group('AuthController', () {
    test('initial state is AsyncValue.data(null)', () {
      final state = container.read(authControllerProvider);
      expect(state, const AsyncValue<void>.data(null));
    });

    test('successful signIn updates state and authenticates user', () async {
      final controller = container.read(authControllerProvider.notifier);

      final success = await controller.signIn(
        email: 'customer@foodexpress.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(container.read(authControllerProvider).hasError, isFalse);
      expect(fakeAuthRepository.currentUser?.email, 'customer@foodexpress.com');
    });

    test('failed signIn catches error and updates state to AsyncError', () async {
      final controller = container.read(authControllerProvider.notifier);

      final success = await controller.signIn(
        email: 'customer@foodexpress.com',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('Incorrect email or password'));
    });

    test('successful register creates customer user', () async {
      final controller = container.read(authControllerProvider.notifier);

      final success = await controller.register(
        email: 'newuser@foodexpress.com',
        password: 'password123',
        name: 'New Customer',
      );

      expect(success, isTrue);
      expect(fakeAuthRepository.currentUser?.name, 'New Customer');
    });

    test('signOut clears authenticated user', () async {
      final controller = container.read(authControllerProvider.notifier);

      await controller.signIn(
        email: 'customer@foodexpress.com',
        password: 'password123',
      );
      expect(fakeAuthRepository.currentUser, isNotNull);

      await controller.signOut();
      expect(fakeAuthRepository.currentUser, isNull);
    });

    test('clearError resets error state to data(null)', () async {
      final controller = container.read(authControllerProvider.notifier);

      await controller.signIn(
        email: 'customer@foodexpress.com',
        password: 'wrongpassword',
      );
      expect(container.read(authControllerProvider).hasError, isTrue);

      controller.clearError();
      expect(container.read(authControllerProvider).hasError, isFalse);
    });
  });
}
