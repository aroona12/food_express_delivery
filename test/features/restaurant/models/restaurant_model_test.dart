import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/restaurant/models/restaurant_model.dart';

void main() {
  const testRestaurant = RestaurantModel(
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
  );

  group('RestaurantModel Tests', () {
    test('toMap converts model into valid map', () {
      final map = testRestaurant.toMap();

      expect(map['id'], 'rest-1');
      expect(map['name'], 'The Burger Studio');
      expect(map['description'], 'Artisanal brioche burgers and craft sides.');
      expect(map['imageUrl'], 'https://example.com/burger.jpg');
      expect(map['rating'], 4.8);
      expect(map['reviewCount'], 342);
      expect(map['deliveryTime'], '20-30 min');
      expect(map['deliveryFee'], 'Free delivery');
      expect(map['cuisine'], 'Gourmet Burgers • American');
      expect(map['isOpen'], true);
      expect(map['address'], '142 S Broadway, New York, NY');
      expect(map['featuredBadge'], 'Featured');
    });

    test('fromMap correctly parses map and optional docId', () {
      final map = {
        'name': 'Smash Shack',
        'description': 'Crispy smashed burgers',
        'imageUrl': 'https://example.com/smash.jpg',
        'rating': 4.7,
        'reviewCount': 215,
        'deliveryTime': '15-25 min',
        'deliveryFee': '\$1.49 Delivery',
        'cuisine': 'Fast Casual • Burgers',
        'isOpen': false,
        'address': '89 Main St, Brooklyn, NY',
        'featuredBadge': 'Hot',
      };

      final restaurant = RestaurantModel.fromMap(map, 'rest-2');

      expect(restaurant.id, 'rest-2');
      expect(restaurant.name, 'Smash Shack');
      expect(restaurant.isOpen, false);
      expect(restaurant.featuredBadge, 'Hot');
    });

    test('copyWith modifies specified fields only', () {
      final updated = testRestaurant.copyWith(
        name: 'The Burger Studio Premium',
        isOpen: false,
        rating: 4.9,
      );

      expect(updated.id, 'rest-1');
      expect(updated.name, 'The Burger Studio Premium');
      expect(updated.isOpen, false);
      expect(updated.rating, 4.9);
      expect(updated.reviewCount, 342);
      expect(updated.address, testRestaurant.address);
    });

    test('equality and hashCode verify identical properties', () {
      const duplicate = RestaurantModel(
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
      );

      expect(testRestaurant, equals(duplicate));
      expect(testRestaurant.hashCode, equals(duplicate.hashCode));
      expect(testRestaurant.toString(), contains('The Burger Studio'));
    });
  });
}
