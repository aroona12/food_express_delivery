import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import '../../helpers/fake_user_repository.dart';

void main() {
  late FakeUserRepository userRepository;

  setUp(() {
    userRepository = FakeUserRepository();
  });

  tearDown(() {
    userRepository.dispose();
  });

  group('UserRepository Contract & Integration Flow', () {
    test('creates and retrieves customer profile by uid', () async {
      final now = DateTime.now();
      final user = UserModel(
        id: 'cust-101',
        email: 'customer101@foodexpress.com',
        name: 'John Customer',
        role: UserRole.customer,
        phone: '+1 555-0101',
        address: '101 Market St',
        createdAt: now,
      );

      // Create profile
      await userRepository.createUserProfile(user);

      // Retrieve profile
      final retrieved = await userRepository.getUserProfile('cust-101');
      expect(retrieved, isNotNull);
      expect(retrieved?.id, 'cust-101');
      expect(retrieved?.email, 'customer101@foodexpress.com');
      expect(retrieved?.name, 'John Customer');
      expect(retrieved?.role, UserRole.customer);
      expect(retrieved?.phone, '+1 555-0101');
      expect(retrieved?.address, '101 Market St');
      expect(retrieved?.createdAt, now);
    });

    test('watchUserProfile streams real-time updates when profile changes', () async {
      const initialUser = UserModel(
        id: 'cust-102',
        email: 'stream@foodexpress.com',
        name: 'Stream Customer',
      );

      await userRepository.createUserProfile(initialUser);

      final stream = userRepository.watchUserProfile('cust-102');
      final emissions = <UserModel?>[];
      final subscription = stream.listen(emissions.add);

      // Allow initial emission
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Partial update
      await userRepository.updateFields(
        uid: 'cust-102',
        name: 'Stream Customer Updated',
        phone: '+1 555-4321',
        address: '4321 Elm Blvd',
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last?.name, 'Stream Customer Updated');
      expect(emissions.last?.phone, '+1 555-4321');
      expect(emissions.last?.address, '4321 Elm Blvd');

      await subscription.cancel();
    });

    test('updateFields merges partial fields without destroying unchanged properties', () async {
      final now = DateTime(2026, 8, 22);
      final initialUser = UserModel(
        id: 'cust-103',
        email: 'keep@foodexpress.com',
        name: 'Keep Email',
        role: UserRole.customer,
        createdAt: now,
        phone: '+1 555-1111',
      );

      await userRepository.createUserProfile(initialUser);

      // Update only address
      await userRepository.updateFields(
        uid: 'cust-103',
        address: '999 New Address Ave',
      );

      final result = await userRepository.getUserProfile('cust-103');
      expect(result?.id, 'cust-103');
      expect(result?.email, 'keep@foodexpress.com');
      expect(result?.name, 'Keep Email');
      expect(result?.phone, '+1 555-1111');
      expect(result?.address, '999 New Address Ave');
      expect(result?.createdAt, now);
    });
  });
}
