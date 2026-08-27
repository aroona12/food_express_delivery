import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/order/models/order_item_model.dart';
import 'package:foodexpressdelivery/features/order/models/order_model.dart';

class _FakeTimestamp {
  _FakeTimestamp(this.date);
  final DateTime date;
  DateTime toDate() => date;
}

void main() {
  group('OrderStatus Enum', () {
    test('displayName returns appropriate string for all statuses', () {
      expect(OrderStatus.pending.displayName, 'Pending');
      expect(OrderStatus.confirmed.displayName, 'Confirmed');
      expect(OrderStatus.preparing.displayName, 'Preparing');
      expect(OrderStatus.outForDelivery.displayName, 'Out for Delivery');
      expect(OrderStatus.delivered.displayName, 'Delivered');
      expect(OrderStatus.cancelled.displayName, 'Cancelled');
    });

    test('fromString parses various string inputs correctly', () {
      expect(OrderStatus.fromString('pending'), OrderStatus.pending);
      expect(OrderStatus.fromString('confirmed'), OrderStatus.confirmed);
      expect(OrderStatus.fromString('preparing'), OrderStatus.preparing);
      expect(OrderStatus.fromString('outForDelivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.fromString('out_for_delivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.fromString('out for delivery'), OrderStatus.outForDelivery);
      expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('canceled'), OrderStatus.cancelled);
      expect(OrderStatus.fromString('unknown'), OrderStatus.pending);
      expect(OrderStatus.fromString(null), OrderStatus.pending);
    });

    test('color and containerColor are defined for each status', () {
      for (final status in OrderStatus.values) {
        expect(status.color, isNotNull);
        expect(status.containerColor, isNotNull);
        expect(status.icon, isNotNull);
      }
    });
  });

  group('OrderModel', () {
    final testDate = DateTime(2026, 8, 25, 19, 30);
    const item1 = OrderItemModel(
      foodItemId: 'item-1',
      restaurantId: 'rest-1',
      name: 'Burger',
      imageUrl: 'https://example.com/b.jpg',
      unitPrice: 10.00,
      quantity: 2,
    );
    const item2 = OrderItemModel(
      foodItemId: 'item-2',
      restaurantId: 'rest-1',
      name: 'Fries',
      imageUrl: 'https://example.com/f.jpg',
      unitPrice: 4.50,
      quantity: 1,
    );

    final order = OrderModel(
      id: 'ORD-12345',
      userId: 'user-789',
      restaurantId: 'rest-1',
      restaurantName: 'The Burger Joint',
      items: const [item1, item2],
      subtotal: 24.50,
      deliveryFee: 2.99,
      total: 27.49,
      status: OrderStatus.outForDelivery,
      createdAt: testDate,
      deliveryAddress: '123 Market St, San Francisco, CA',
      orderNotes: 'Extra ketchup please',
      paymentMethod: 'Cash on Delivery',
    );

    test('itemCount sums quantities across all items', () {
      expect(order.itemCount, 3);
    });

    test('formatted price helpers format accurately', () {
      expect(order.formattedSubtotal, '\$24.50');
      expect(order.formattedDeliveryFee, '\$2.99');
      expect(order.formattedTotal, '\$27.49');
    });

    test('formattedDate formats date cleanly with AM/PM', () {
      expect(order.formattedDate, 'Aug 25, 2026 • 7:30 PM');
    });

    test('copyWith creates modified copy correctly', () {
      final modified = order.copyWith(
        status: OrderStatus.delivered,
        total: 28.00,
        deliveryAddress: '456 New St',
      );

      expect(modified.status, OrderStatus.delivered);
      expect(modified.total, 28.00);
      expect(modified.id, 'ORD-12345');
      expect(modified.deliveryAddress, '456 New St');
      expect(modified.restaurantName, 'The Burger Joint');
    });

    test('toMap serializes OrderModel accurately', () {
      final map = order.toMap();

      expect(map['id'], 'ORD-12345');
      expect(map['userId'], 'user-789');
      expect(map['restaurantId'], 'rest-1');
      expect(map['restaurantName'], 'The Burger Joint');
      expect((map['items'] as List).length, 2);
      expect(map['subtotal'], 24.50);
      expect(map['deliveryFee'], 2.99);
      expect(map['total'], 27.49);
      expect(map['status'], 'outForDelivery');
      expect(map['createdAt'], testDate.toIso8601String());
      expect(map['deliveryAddress'], '123 Market St, San Francisco, CA');
      expect(map['orderNotes'], 'Extra ketchup please');
      expect(map['paymentMethod'], 'Cash on Delivery');
    });

    test('fromMap deserializes OrderModel accurately', () {
      final map = {
        'id': 'ORD-12345',
        'userId': 'user-789',
        'restaurantId': 'rest-1',
        'restaurantName': 'The Burger Joint',
        'items': [
          item1.toMap(),
          item2.toMap(),
        ],
        'subtotal': 24.50,
        'deliveryFee': 2.99,
        'total': 27.49,
        'status': 'outForDelivery',
        'createdAt': testDate.toIso8601String(),
        'deliveryAddress': '123 Market St, San Francisco, CA',
        'orderNotes': 'Extra ketchup please',
        'paymentMethod': 'Cash on Delivery',
      };

      final deserialized = OrderModel.fromMap(map);
      expect(deserialized.id, order.id);
      expect(deserialized.userId, order.userId);
      expect(deserialized.items.length, 2);
      expect(deserialized.status, OrderStatus.outForDelivery);
      expect(deserialized.total, 27.49);
      expect(deserialized.deliveryAddress, '123 Market St, San Francisco, CA');
      expect(deserialized.orderNotes, 'Extra ketchup please');
      expect(deserialized.paymentMethod, 'Cash on Delivery');
    });

    test('fromMap handles Timestamp-like object for createdAt', () {
      final map = {
        'id': 'ORD-999',
        'userId': 'user-789',
        'restaurantId': 'rest-1',
        'restaurantName': 'The Burger Joint',
        'items': <dynamic>[],
        'subtotal': 0.0,
        'deliveryFee': 0.0,
        'total': 0.0,
        'status': 'pending',
        'createdAt': _FakeTimestamp(testDate),
      };

      final deserialized = OrderModel.fromMap(map);
      expect(deserialized.createdAt, testDate);
      expect(deserialized.status, OrderStatus.pending);
    });

    test('equality and hashCode match for identical instances', () {
      final order2 = OrderModel(
        id: 'ORD-12345',
        userId: 'user-789',
        restaurantId: 'rest-1',
        restaurantName: 'The Burger Joint',
        items: const [item1, item2],
        subtotal: 24.50,
        deliveryFee: 2.99,
        total: 27.49,
        status: OrderStatus.outForDelivery,
        createdAt: testDate,
        deliveryAddress: '123 Market St, San Francisco, CA',
        orderNotes: 'Extra ketchup please',
        paymentMethod: 'Cash on Delivery',
      );

      expect(order, equals(order2));
      expect(order.hashCode, equals(order2.hashCode));
    });
  });
}
