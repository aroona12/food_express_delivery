import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';

void main() {
  group('OrderItemModel', () {
    const item = OrderItemModel(
      foodItemId: 'dish-1',
      restaurantId: 'rest-1',
      name: 'Double Truffle Burger',
      imageUrl: 'https://example.com/truffle.jpg',
      unitPrice: 14.99,
      quantity: 2,
    );

    test('calculates subtotal correctly', () {
      expect(item.subtotal, 29.98);
    });

    test('formats price strings accurately', () {
      expect(item.formattedUnitPrice, '\$14.99');
      expect(item.formattedSubtotal, '\$29.98');
    });

    test('copyWith creates modified copy while preserving other attributes', () {
      final updated = item.copyWith(quantity: 3, unitPrice: 15.00);

      expect(updated.quantity, 3);
      expect(updated.unitPrice, 15.00);
      expect(updated.subtotal, 45.00);
      expect(updated.name, 'Double Truffle Burger');
      expect(updated.foodItemId, 'dish-1');
    });

    test('toMap serializes model correctly', () {
      final map = item.toMap();

      expect(map['foodItemId'], 'dish-1');
      expect(map['restaurantId'], 'rest-1');
      expect(map['name'], 'Double Truffle Burger');
      expect(map['imageUrl'], 'https://example.com/truffle.jpg');
      expect(map['unitPrice'], 14.99);
      expect(map['quantity'], 2);
      expect(map['subtotal'], 29.98);
    });

    test('fromMap deserializes map accurately', () {
      final map = {
        'foodItemId': 'dish-1',
        'restaurantId': 'rest-1',
        'name': 'Double Truffle Burger',
        'imageUrl': 'https://example.com/truffle.jpg',
        'unitPrice': 14.99,
        'quantity': 2,
      };

      final deserialized = OrderItemModel.fromMap(map);
      expect(deserialized, equals(item));
      expect(deserialized.subtotal, 29.98);
    });

    test('equality and hashCode match for identical properties', () {
      const item2 = OrderItemModel(
        foodItemId: 'dish-1',
        restaurantId: 'rest-1',
        name: 'Double Truffle Burger',
        imageUrl: 'https://example.com/truffle.jpg',
        unitPrice: 14.99,
        quantity: 2,
      );

      expect(item, equals(item2));
      expect(item.hashCode, equals(item2.hashCode));
    });

    test('toString contains relevant summary details', () {
      final str = item.toString();
      expect(str, contains('OrderItemModel'));
      expect(str, contains('dish-1'));
      expect(str, contains('Double Truffle Burger'));
      expect(str, contains('29.98'));
    });

    test('asserts when quantity is less than or equal to 0', () {
      expect(
        () => OrderItemModel(
          foodItemId: 'dish-1',
          restaurantId: 'rest-1',
          name: 'Burger',
          imageUrl: '',
          unitPrice: 10.0,
          quantity: 0,
        ),
        throwsAssertionError,
      );
    });
  });
}
