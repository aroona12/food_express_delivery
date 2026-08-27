import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/restaurant/data/restaurant_repository.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';
import 'package:foodexpressdelivery/features/restaurant/presentation/screens/restaurant_details_screen.dart';
import 'package:foodexpressdelivery/features/restaurant/presentation/widgets/food_item_card.dart';
import 'package:foodexpressdelivery/features/restaurant/presentation/widgets/menu_category_list.dart';
import 'package:foodexpressdelivery/features/restaurant/providers/restaurant_provider.dart';

void main() {
  late MockRestaurantRepository fakeRepository;

  final sampleRestaurants = [
    const RestaurantModel(
      id: 'rest-1',
      name: 'The Burger Studio',
      description: 'Artisanal brioche burgers and craft sides.',
      imageUrl: 'https://example.com/burger.jpg',
      rating: 4.8,
      reviewCount: 342,
      deliveryTime: '20-30 min',
      deliveryFee: 'Free delivery',
      cuisine: 'Gourmet Burgers • American',
      isOpen: true,
      address: '142 S Broadway, New York, NY',
      featuredBadge: 'Featured',
    ),
  ];

  final sampleFoodItems = [
    const FoodItemModel(
      id: 'item-1',
      restaurantId: 'rest-1',
      name: 'Truffle Umami Smash Burger',
      description: 'Double Angus beef patties, aged white cheddar.',
      imageUrl: 'https://example.com/item1.jpg',
      price: 15.99,
      category: 'Burgers',
      isAvailable: true,
      rating: 4.9,
      calories: 820,
    ),
    const FoodItemModel(
      id: 'item-2',
      restaurantId: 'rest-1',
      name: 'Parmesan Herb Fries',
      description: 'Golden fries tossed in parmesan.',
      imageUrl: 'https://example.com/item2.jpg',
      price: 5.99,
      category: 'Sides',
      isAvailable: true,
      calories: 390,
    ),
  ];

  setUp(() {
    fakeRepository = MockRestaurantRepository(
      restaurants: sampleRestaurants,
      foodItems: sampleFoodItems,
    );
  });

  Widget createWidgetUnderTest(String restaurantId) {
    return ProviderScope(
      overrides: [
        restaurantRepositoryProvider.overrideWithValue(fakeRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: RestaurantDetailsScreen(restaurantId: restaurantId),
      ),
    );
  }

  group('RestaurantDetailsScreen Widget Tests', () {
    testWidgets('renders restaurant header, categories, and food items successfully', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest('rest-1'));
      await tester.pumpAndSettle();

      // Check header info
      expect(find.text('The Burger Studio'), findsOneWidget);
      expect(find.text('Gourmet Burgers • American'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text(' (342)'), findsOneWidget);
      expect(find.text('20-30 min'), findsOneWidget);
      expect(find.text('Free delivery'), findsOneWidget);
      expect(find.text('142 S Broadway, New York, NY'), findsOneWidget);
      expect(find.text('OPEN NOW'), findsOneWidget);

      // Check category chips inside MenuCategoryList
      expect(find.text('Menu & Categories'), findsOneWidget);
      final categoryListFinder = find.byType(MenuCategoryList);
      expect(find.descendant(of: categoryListFinder, matching: find.text('All')), findsOneWidget);
      expect(find.descendant(of: categoryListFinder, matching: find.text('Burgers')), findsOneWidget);
      expect(find.descendant(of: categoryListFinder, matching: find.text('Sides')), findsOneWidget);

      // Check food items
      expect(find.text('Truffle Umami Smash Burger'), findsOneWidget);
      expect(find.text('Parmesan Herb Fries'), findsOneWidget);
      expect(find.byType(FoodItemCard), findsNWidgets(2));
    });

    testWidgets('selecting category chip filters the visible food items list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest('rest-1'));
      await tester.pumpAndSettle();

      // Initially 2 food items are shown
      expect(find.byType(FoodItemCard), findsNWidgets(2));

      // Tap on 'Sides' category chip in the MenuCategoryList
      final sidesCategoryChip = find.descendant(
        of: find.byType(MenuCategoryList),
        matching: find.text('Sides'),
      );
      await tester.tap(sidesCategoryChip);
      await tester.pumpAndSettle();

      // Now only 1 food item (Parmesan Herb Fries) is shown
      expect(find.text('Parmesan Herb Fries'), findsOneWidget);
      expect(find.text('Truffle Umami Smash Burger'), findsNothing);
      expect(find.byType(FoodItemCard), findsOneWidget);
    });

    testWidgets('displays empty state when restaurant ID does not exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest('non-existent-id'));
      await tester.pumpAndSettle();

      expect(find.text('Restaurant Not Found'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });
  });
}
