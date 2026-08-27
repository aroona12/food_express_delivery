import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/core/theme/app_theme.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_model.dart';
import 'package:foodexpressdelivery/features/cart/presentation/screens/cart_screen.dart';
import 'package:foodexpressdelivery/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:foodexpressdelivery/features/cart/providers/cart_provider.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';

void main() {
  const testDish1 = FoodItemModel(
    id: 'food-1',
    restaurantId: 'rest-1',
    name: 'Truffle Smash Burger',
    description: 'Double beef patty with black truffle aioli.',
    imageUrl: 'https://example.com/burger.jpg',
    price: 15.00,
    category: 'Burgers',
    isAvailable: true,
  );

  const testDish2 = FoodItemModel(
    id: 'food-2',
    restaurantId: 'rest-1',
    name: 'Parmesan Truffle Fries',
    description: 'Crispy skin-on fries with freshly grated parmesan.',
    imageUrl: 'https://example.com/fries.jpg',
    price: 6.00,
    category: 'Sides',
    isAvailable: true,
  );

  Widget createTestWidget({CartModel? initialCart}) {
    return ProviderScope(
      overrides: [
        if (initialCart != null)
          cartControllerProvider.overrideWith(
            (ref) => CartController(initialCart),
          ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CartScreen(),
      ),
    );
  }

  group('CartScreen Widget Tests', () {
    testWidgets('renders empty cart state when no items exist', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.text('Browse Restaurants'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.text('Order Summary'), findsNothing);
      expect(find.text('Proceed to Checkout'), findsNothing);
    });

    testWidgets('renders list of cart items, order summary, and checkout button', (tester) async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 2), // 30.00
          CartItemModel(foodItem: testDish2, quantity: 1), // 6.00
        ],
      );

      await tester.pumpWidget(createTestWidget(initialCart: initialCart));
      await tester.pumpAndSettle();

      // Check header count
      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('3 items'), findsOneWidget);

      // Check cart item tiles
      expect(find.byType(CartItemTile), findsNWidgets(2));
      expect(find.text('Truffle Smash Burger'), findsOneWidget);
      expect(find.text('Parmesan Truffle Fries'), findsOneWidget);
      expect(find.text('\$15.00 each'), findsOneWidget);
      expect(find.text('\$6.00 each'), findsOneWidget);
      expect(find.text('\$30.00'), findsOneWidget); // item 1 subtotal
      expect(find.text('\$6.00'), findsOneWidget); // item 2 subtotal

      // Check order summary
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Subtotal (3 items)'), findsOneWidget);
      expect(find.text('\$36.00'), findsOneWidget); // Cart subtotal
      expect(find.text('Delivery Fee'), findsOneWidget);
      expect(find.text('\$2.99'), findsOneWidget); // Delivery fee
      expect(find.text('Grand Total'), findsOneWidget);
      expect(find.text('\$38.99'), findsOneWidget); // Grand total

      // Check checkout button
      expect(find.text('Proceed to Checkout • \$38.99'), findsOneWidget);
    });

    testWidgets('tapping increment (+) button increases quantity and updates totals reactively', (tester) async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 1), // 15.00
        ],
      );

      await tester.pumpWidget(createTestWidget(initialCart: initialCart));
      await tester.pumpAndSettle();

      expect(find.text('1 item'), findsOneWidget);
      expect(find.text('\$15.00'), findsNWidgets(2)); // item subtotal and summary subtotal
      expect(find.text('\$17.99'), findsOneWidget); // grand total
      expect(find.text('Proceed to Checkout • \$17.99'), findsOneWidget);

      // Tap increment button
      final incrementButton = find.byKey(const Key('increment_food-1'));
      await tester.tap(incrementButton);
      await tester.pumpAndSettle();

      // Quantity should become 2
      expect(find.text('2 items'), findsOneWidget);
      expect(find.text('\$30.00'), findsNWidgets(2)); // item subtotal and summary subtotal
      expect(find.text('\$32.99'), findsOneWidget); // grand total
      expect(find.text('Proceed to Checkout • \$32.99'), findsOneWidget);
    });

    testWidgets('tapping decrement (-) button decreases quantity and removes item when reaching 0', (tester) async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 2), // 30.00
        ],
      );

      await tester.pumpWidget(createTestWidget(initialCart: initialCart));
      await tester.pumpAndSettle();

      // Tap decrement button
      final decrementButton = find.byKey(const Key('decrement_food-1'));
      await tester.tap(decrementButton);
      await tester.pumpAndSettle();

      // Quantity is now 1
      expect(find.text('1 item'), findsOneWidget);
      expect(find.text('\$15.00'), findsNWidgets(2));

      // Tap decrement again (quantity 1 -> 0, item removed)
      await tester.tap(decrementButton);
      await tester.pumpAndSettle();

      // Cart is now empty
      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(find.byType(CartItemTile), findsNothing);
    });

    testWidgets('tapping delete icon removes the item immediately', (tester) async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 1),
          CartItemModel(foodItem: testDish2, quantity: 1),
        ],
      );

      await tester.pumpWidget(createTestWidget(initialCart: initialCart));
      await tester.pumpAndSettle();

      expect(find.byType(CartItemTile), findsNWidgets(2));

      // Delete testDish1
      final deleteBtn = find.byKey(const Key('delete_item_food-1'));
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.byType(CartItemTile), findsNWidgets(1));
      expect(find.text('Truffle Smash Burger'), findsNothing);
      expect(find.text('Parmesan Truffle Fries'), findsOneWidget);
    });

    testWidgets('clearing all items via app bar dialog resets cart to empty state', (tester) async {
      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 1),
        ],
      );

      await tester.pumpWidget(createTestWidget(initialCart: initialCart));
      await tester.pumpAndSettle();

      // Tap clear cart icon in app bar
      final clearCartIcon = find.byTooltip('Clear Cart');
      await tester.tap(clearCartIcon);
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.text('Clear Cart?'), findsOneWidget);
      expect(find.text('Are you sure you want to remove all items from your cart?'), findsOneWidget);

      // Confirm Clear All
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Cart is empty
      expect(find.text('Your Cart is Empty'), findsOneWidget);
    });

    testWidgets('responsive layout on narrow mobile screen width (320px) without overflow', (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 640 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final initialCart = CartModel(
        items: const [
          CartItemModel(foodItem: testDish1, quantity: 4),
          CartItemModel(foodItem: testDish2, quantity: 2),
        ],
      );

      await tester.pumpWidget(createTestWidget(initialCart: initialCart));
      await tester.pumpAndSettle();

      // Verify no RenderFlex overflow exceptions occurred
      expect(tester.takeException(), isNull);
      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Proceed to Checkout • \$74.99'), findsOneWidget);
    });
  });
}
