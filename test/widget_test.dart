import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/main.dart';

void main() {
  testWidgets('FoodExpressApp mounts successfully smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FoodExpressApp(),
      ),
    );

    // Initial frame renders
    expect(find.byType(FoodExpressApp), findsOneWidget);
  });
}
