import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/address/data/address_repository.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';
import 'package:foodexpressdelivery/features/address/presentation/screens/address_list_screen.dart';
import 'package:foodexpressdelivery/features/address/presentation/widgets/address_card.dart';
import 'package:foodexpressdelivery/features/address/providers/address_provider.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';

void main() {
  const testUser = UserModel(
    id: 'user-addr-test',
    email: 'customer@test.com',
    name: 'Customer Address Test',
    role: UserRole.customer,
  );

  final address1 = AddressModel(
    id: 'addr-1',
    userId: 'user-addr-test',
    label: 'Home',
    fullAddress: '742 Evergreen Terrace, Apt 4B',
    city: 'Springfield',
    phone: '+1 (555) 012-3456',
    isDefault: true,
    createdAt: DateTime(2026, 8, 20),
  );

  final address2 = AddressModel(
    id: 'addr-2',
    userId: 'user-addr-test',
    label: 'Work',
    fullAddress: '100 Industrial Parkway',
    city: 'Springfield',
    phone: '+1 (555) 987-6543',
    isDefault: false,
    createdAt: DateTime(2026, 8, 21),
  );

  Widget createTestWidget({
    List<AddressModel>? initialAddresses,
    bool isSelectMode = false,
    String? selectedAddressId,
  }) {
    final mockRepo = MockAddressRepository(
      initialData: {
        testUser.id: initialAddresses ?? [address1, address2],
      },
    );

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(testUser),
        addressRepositoryProvider.overrideWithValue(mockRepo),
        if (selectedAddressId != null)
          selectedAddressIdProvider.overrideWith((ref) => selectedAddressId),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: AddressListScreen(isSelectMode: isSelectMode),
      ),
    );
  }

  group('AddressListScreen Widget Tests', () {
    testWidgets('renders all saved address cards with details and default badges', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Delivery Addresses'), findsOneWidget);
      expect(find.byType(AddressCard), findsNWidgets(2));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('742 Evergreen Terrace, Apt 4B'), findsOneWidget);
      expect(find.text('100 Industrial Parkway'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('Add New Address'), findsOneWidget);
    });

    testWidgets('renders empty state when customer has no saved addresses', (tester) async {
      await tester.pumpWidget(createTestWidget(initialAddresses: []));
      await tester.pumpAndSettle();

      expect(find.text('No Addresses Saved'), findsOneWidget);
      expect(find.text('Add New Address'), findsOneWidget);
      expect(find.byType(AddressCard), findsNothing);
    });

    testWidgets('renders select mode instructions and selection indicator when isSelectMode=true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isSelectMode: true,
          selectedAddressId: 'addr-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Delivery Address'), findsOneWidget);
      expect(find.text('Tap an address to deliver your order here.'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_off_rounded), findsOneWidget);
    });

    testWidgets('deleting address shows confirmation dialog and removes it on confirm', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open popup menu on first address card
      final menuButtons = find.byTooltip('Address options');
      expect(menuButtons, findsNWidgets(2));

      await tester.tap(menuButtons.first);
      await tester.pumpAndSettle();

      // Tap delete
      final deleteOption = find.text('Delete');
      expect(deleteOption, findsOneWidget);
      await tester.tap(deleteOption);
      await tester.pumpAndSettle();

      // Verify dialog
      expect(find.text('Delete Address?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Card count is now 1
      expect(find.byType(AddressCard), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });
  });
}
