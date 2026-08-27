import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/providers/auth_provider.dart';
import 'package:foodexpressdelivery/main.dart';
import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('FoodExpressApp mounts successfully and displays Login when unauthenticated', (WidgetTester tester) async {
    final fakeAuthRepo = FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepo),
        ],
        child: const FoodExpressApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify root app and login screen mount
    expect(find.byType(FoodExpressApp), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });
}
