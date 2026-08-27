import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/core/widgets/app_button.dart';
import 'package:foodexpressdelivery/features/auth/models/user_model.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/features/profile/presentation/screens/profile_screen.dart';
import 'package:foodexpressdelivery/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:foodexpressdelivery/features/profile/providers/user_provider.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_user_repository.dart';

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late FakeUserRepository fakeUserRepository;

  final testUser = UserModel(
    id: 'test-uid-1',
    email: 'customer@foodexpress.com',
    name: 'Emily Watson',
    role: UserRole.customer,
    phone: '+1 555-0123',
    address: '742 Evergreen Terrace',
    createdAt: DateTime(2026, 8, 22),
  );

  setUp(() {
    fakeAuthRepository = FakeAuthRepository(initialUser: testUser);
    fakeUserRepository = FakeUserRepository(
      initialUsers: {testUser.id: testUser},
    );
  });

  tearDown(() {
    fakeAuthRepository.dispose();
    fakeUserRepository.dispose();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        userRepositoryProvider.overrideWithValue(fakeUserRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('renders all profile header and info fields accurately', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check header details
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Emily Watson'), findsAtLeastNWidgets(1));
      expect(find.text('customer@foodexpress.com'), findsAtLeastNWidgets(1));
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('EW'), findsOneWidget); // Initials
      expect(find.text('Member since Aug 2026'), findsOneWidget);

      // Check personal information section
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('+1 555-0123'), findsOneWidget);
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('742 Evergreen Terrace'), findsOneWidget);

      // Check actions
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Edit Profile Details'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('tapping Edit Profile opens EditProfileSheet with prefilled values', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap edit button in the app bar
      final editIcon = find.byTooltip('Edit Profile');
      expect(editIcon, findsOneWidget);
      await tester.tap(editIcon);
      await tester.pumpAndSettle();

      // Verify bottom sheet is open
      expect(find.byType(EditProfileSheet), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('editing profile and saving updates user profile and reflects in UI', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Open edit sheet
      await tester.tap(find.byTooltip('Edit Profile'));
      await tester.pumpAndSettle();

      // Find text fields
      final nameField = find.widgetWithText(TextFormField, 'Emily Watson');
      expect(nameField, findsOneWidget);

      // Clear and enter new name
      await tester.enterText(nameField, 'Emily Clark');

      // Tap Save Changes
      await tester.tap(find.widgetWithText(AppButton, 'Save Changes'));
      await tester.pumpAndSettle();

      // Verify bottom sheet closed and new name is reflected
      expect(find.byType(EditProfileSheet), findsNothing);
      expect(find.text('Emily Clark'), findsAtLeastNWidgets(1));
      expect(find.text('EC'), findsOneWidget); // Updated initials
    });

    testWidgets('tapping Log Out shows confirmation dialog', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap Log Out button
      final logoutButton = find.widgetWithText(AppButton, 'Log Out');
      expect(logoutButton, findsOneWidget);
      await tester.ensureVisible(logoutButton);
      await tester.pumpAndSettle();
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Are you sure you want to log out of your FoodExpress account?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
