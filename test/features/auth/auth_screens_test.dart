import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:foodexpressdelivery/features/auth/presentation/screens/login_screen.dart';
import 'package:foodexpressdelivery/features/auth/presentation/screens/register_screen.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import '../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository fakeAuthRepository;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
  });

  tearDown(() {
    fakeAuthRepository.dispose();
  });

  Widget createAuthWidgetUnderTest(Widget child) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all fields and labels', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidgetUnderTest(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submission', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidgetUnderTest(const LoginScreen()));
      await tester.pumpAndSettle();

      // Tap Sign In without filling fields
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });
  });

  group('RegisterScreen Widget Tests', () {
    testWidgets('renders full registration form', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidgetUnderTest(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('validates mismatched passwords', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidgetUnderTest(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Enter name & email
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'secret123');
      await tester.enterText(find.byType(TextFormField).at(3), 'mismatched123');

      final createAccountButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('renders forgot password form and validates email', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidgetUnderTest(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);

      final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Link');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address.'), findsOneWidget);
    });

    testWidgets('shows confirmation view on successful submission', (WidgetTester tester) async {
      await tester.pumpWidget(createAuthWidgetUnderTest(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'user@foodexpress.com');

      final sendButton = find.widgetWithText(ElevatedButton, 'Send Reset Link');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(find.text('Check Your Inbox'), findsOneWidget);
      expect(find.text('Return to Sign In'), findsOneWidget);
    });
  });
}
