import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';
import 'package:foodexpressdelivery/features/cart/models/cart_item_model.dart';
import 'package:foodexpressdelivery/features/checkout/models/checkout_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/food_item_model.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';

void main() {
  group('CheckoutModel Tests', () {
    const testRestaurant = RestaurantModel(
      id: 'rest-1',
      name: 'The Burger Studio',
      description: 'Gourmet burgers',
      imageUrl: 'https://example.com/rest.jpg',
      rating: 4.9,
      reviewCount: 200,
      deliveryTime: '25 min',
      deliveryFee: '\$2.99',
      cuisine: 'Burgers',
      isOpen: true,
      address: '100 Broadway',
    );

    const testDish = FoodItemModel(
      id: 'food-1',
      restaurantId: 'rest-1',
      name: 'Smash Burger',
      description: 'Double beef patty',
      imageUrl: 'https://example.com/dish.jpg',
      price: 12.50,
      category: 'Burgers',
      isAvailable: true,
    );

    final testAddress = AddressModel(
      id: 'addr-1',
      userId: 'user-1',
      label: 'Home',
      fullAddress: '742 Evergreen Terrace',
      city: 'Springfield',
      phone: '+1 (555) 012-3456',
      isDefault: true,
      createdAt: DateTime(2026, 8, 20),
    );

    test('calculates computed properties accurately', () {
      final model = CheckoutModel(
        restaurant: testRestaurant,
        items: const [
          CartItemModel(foodItem: testDish, quantity: 2),
        ],
        subtotal: 25.00,
        deliveryFee: 2.99,
        total: 27.99,
        deliveryAddress: testAddress,
        paymentMethod: 'Cash on Delivery',
        orderNotes: 'Leave at door',
      );

      expect(model.totalItemCount, 2);
      expect(model.formattedSubtotal, '\$25.00');
      expect(model.formattedDeliveryFee, '\$2.99');
      expect(model.formattedTotal, '\$27.99');
      expect(model.isValid, isTrue);
    });

    test('isValid returns false when items are empty', () {
      final emptyCartModel = CheckoutModel(
        restaurant: testRestaurant,
        items: const [],
        subtotal: 0.0,
        deliveryFee: 2.99,
        total: 2.99,
        deliveryAddress: testAddress,
      );

      expect(emptyCartModel.isValid, isFalse);
    });

    test('isValid returns false when deliveryAddress is null or empty', () {
      final noAddressModel = CheckoutModel(
        restaurant: testRestaurant,
        items: const [
          CartItemModel(foodItem: testDish, quantity: 1),
        ],
        subtotal: 12.50,
        deliveryFee: 2.99,
        total: 15.49,
        deliveryAddress: null,
      );

      expect(noAddressModel.isValid, isFalse);

      final emptyAddressModel = noAddressModel.copyWith(
        deliveryAddress: testAddress.copyWith(fullAddress: '   '),
      );
      expect(emptyAddressModel.isValid, isFalse);
    });

    test('copyWith and value equality work accurately', () {
      final model1 = CheckoutModel(
        restaurant: testRestaurant,
        items: const [
          CartItemModel(foodItem: testDish, quantity: 1),
        ],
        subtotal: 12.50,
        deliveryFee: 2.99,
        total: 15.49,
        deliveryAddress: testAddress,
      );

      final model2 = model1.copyWith(
        paymentMethod: 'Credit Card',
      );

      expect(model2.paymentMethod, 'Credit Card');
      expect(model2.total, 15.49);
      expect(model1, isNot(equals(model2)));

      final model3 = model1.copyWith();
      expect(model1, equals(model3));
      expect(model1.hashCode, equals(model3.hashCode));
    });
  });
}
