import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_model.dart';
import 'package:foodexpressdelivery/features/cart/providers/cart_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/presentation/widgets/food_item_card.dart';

void main() {
  const availableItem = FoodItemModel(
    id: 'item-1',
    restaurantId: 'rest-1',
    name: 'Truffle Smash Burger',
    description: 'Double beef patties with black truffle garlic aioli.',
    imageUrl: 'https://example.com/burger.jpg',
    price: 15.99,
    category: 'Burgers',
    isAvailable: true,
    rating: 4.9,
    calories: 820,
  );

  const unavailableItem = FoodItemModel(
    id: 'item-2',
    restaurantId: 'rest-1',
    name: 'Smoked BBQ Burger',
    description: 'Crispy fried onion strings and smoked gouda.',
    imageUrl: 'https://example.com/bbq.jpg',
    price: 14.49,
    category: 'Burgers',
    isAvailable: false,
    calories: 780,
  );

  const differentRestaurantItem = FoodItemModel(
    id: 'item-3',
    restaurantId: 'rest-2',
    name: 'Wood-fired Pizza',
    description: 'San Marzano tomatoes and mozzarella.',
    imageUrl: 'https://example.com/pizza.jpg',
    price: 18.00,
    category: 'Pizza',
    isAvailable: true,
  );

  group('FoodItemCard Widget Tests', () {
    testWidgets('renders available food item details, price, calories, rating, and Add button', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: FoodItemCard(
                item: availableItem,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Truffle Smash Burger'), findsOneWidget);
      expect(find.text('Double beef patties with black truffle garlic aioli.'), findsOneWidget);
      expect(find.text('\$15.99'), findsOneWidget);
      expect(find.text('820 kcal'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('Burgers'), findsOneWidget);
      expect(find.text('Unavailable'), findsNothing);
      expect(find.text('Add'), findsOneWidget);

      await tester.tap(find.byType(FoodItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders unavailable visual indicators and prevents tap interaction', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: FoodItemCard(
                item: unavailableItem,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Smoked BBQ Burger'), findsOneWidget);
      expect(find.text('\$14.49'), findsOneWidget);
      expect(find.text('Sold Out'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('Add'), findsNothing);

      await tester.tap(find.byType(FoodItemCard));
      expect(tapped, isFalse);
    });

    testWidgets('tapping Add button updates CartController and shows SnackBar feedback', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: FoodItemCard(item: availableItem),
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap Add button
      final addBtn = find.byKey(const Key('add_button_item-1'));
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Verify cart in container has 1 item
      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.foodItemId, 'item-1');
      expect(find.text('Added Truffle Smash Burger to cart'), findsOneWidget);
      expect(find.text('View Cart'), findsOneWidget);
    });

    testWidgets('adding item from different restaurant shows confirmation dialog', (tester) async {
      final container = ProviderContainer(
        overrides: [
          cartControllerProvider.overrideWith(
            (ref) => CartController(
              const CartModel(
                items: [CartItemModel(foodItem: availableItem, quantity: 1)],
                restaurantId: 'rest-1',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: FoodItemCard(item: differentRestaurantItem),
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap Add button on rest-2 item
      final addBtn = find.byKey(const Key('add_button_item-3'));
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Different Restaurant'), findsOneWidget);
      expect(find.text('Your cart contains items from another restaurant. Clear cart and add this item?'), findsOneWidget);

      // Confirm Clear & Add
      await tester.tap(find.text('Clear & Add'));
      await tester.pumpAndSettle();

      // Verify cart now has rest-2 item
      final cart = container.read(cartProvider);
      expect(cart.items.length, 1);
      expect(cart.items.first.foodItemId, 'item-3');
      expect(cart.effectiveRestaurantId, 'rest-2');
    });
  });
}
