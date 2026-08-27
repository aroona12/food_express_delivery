import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/address/data/address_repository.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';
import 'package:foodexpressdelivery/features/address/presentation/screens/add_edit_address_screen.dart';
import 'package:foodexpressdelivery/features/address/providers/address_provider.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';

void main() {
  const testUser = UserModel(
    id: 'user-form-test',
    email: 'customer@test.com',
    name: 'Form Tester',
    role: UserRole.customer,
  );

  final existingAddress = AddressModel(
    id: 'addr-existing-1',
    userId: 'user-form-test',
    label: 'Work',
    fullAddress: '200 Business Plaza, Floor 4',
    city: 'Springfield',
    phone: '+1 (555) 321-4567',
    additionalInstructions: 'Call upon arrival',
    isDefault: false,
    createdAt: DateTime(2026, 8, 20),
  );

  Widget createTestWidget({
    String? addressId,
    MockAddressRepository? customRepo,
  }) {
    final repo = customRepo ??
        MockAddressRepository(
          initialData: {
            testUser.id: [existingAddress],
          },
        );

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(testUser),
        addressRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: AddEditAddressScreen(addressId: addressId),
      ),
    );
  }

  group('AddEditAddressScreen Widget Tests', () {
    setUp(() {
      // Setup
    });

    testWidgets('renders add form in creation mode with default values', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Delivery Address'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.byKey(const Key('address_full_field')), findsOneWidget);
      expect(find.byKey(const Key('address_city_field')), findsOneWidget);
      expect(find.byKey(const Key('address_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('address_instructions_field')), findsOneWidget);
      expect(find.text('Save Address'), findsOneWidget);
    });

    testWidgets('validates required fields on submit and prevents saving when empty', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Clear city and submit empty
      await tester.enterText(find.byKey(const Key('address_city_field')), '');
      final saveBtn = find.byKey(const Key('save_address_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Street address is required'), findsOneWidget);
      expect(find.text('City is required'), findsOneWidget);
      expect(find.text('Phone number is required for delivery coordination'), findsOneWidget);
    });

    testWidgets('submitting valid new address saves it and updates repository', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = MockAddressRepository(initialData: {testUser.id: []});

      await tester.pumpWidget(createTestWidget(customRepo: repo));
      await tester.pumpAndSettle();

      // Enter valid fields
      await tester.enterText(
        find.byKey(const Key('address_full_field')),
        '888 Sunset Boulevard, Apt 2C',
      );
      await tester.enterText(
        find.byKey(const Key('address_city_field')),
        'Springfield',
      );
      await tester.enterText(
        find.byKey(const Key('address_phone_field')),
        '+1 (555) 999-0000',
      );

      final saveBtn = find.byKey(const Key('save_address_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final addresses = await repo.getAddresses(testUser.id);
      expect(addresses.any((a) => a.fullAddress.contains('888 Sunset Boulevard')), isTrue);
    });

    testWidgets('renders prefilled form in edit mode and updates address on submit', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = MockAddressRepository(
        initialData: {
          testUser.id: [existingAddress],
        },
      );

      await tester.pumpWidget(
        createTestWidget(
          addressId: 'addr-existing-1',
          customRepo: repo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Address'), findsOneWidget);
      expect(find.text('200 Business Plaza, Floor 4'), findsOneWidget);
      expect(find.text('Update Address'), findsOneWidget);

      // Modify address
      await tester.enterText(
        find.byKey(const Key('address_full_field')),
        '200 Business Plaza, Floor 10 (Penthouse)',
      );

      final saveBtn = find.byKey(const Key('save_address_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final updated = await repo.getAddressById(testUser.id, 'addr-existing-1');
      expect(updated!.fullAddress, '200 Business Plaza, Floor 10 (Penthouse)');
    });
  });
}
