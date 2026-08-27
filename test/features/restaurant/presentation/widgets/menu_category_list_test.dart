import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/restaurant/presentation/widgets/menu_category_list.dart';

void main() {
  final categories = ['All', 'Burgers', 'Sides', 'Drinks', 'Desserts'];

  group('MenuCategoryList Widget Tests', () {
    testWidgets('renders all category chips and highlights selected category', (tester) async {
      String selected = 'Burgers';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: MenuCategoryList(
              categories: categories,
              selectedCategory: selected,
              onCategorySelected: (cat) => selected = cat,
            ),
          ),
        ),
      );
      await tester.pump();

      for (final cat in categories) {
        expect(find.text(cat), findsOneWidget);
      }

      await tester.tap(find.text('Sides'));
      await tester.pump();

      expect(selected, 'Sides');
    });
  });
}
