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

    test('fromMap parses Firestore map containing "name " (trailing space) instead of "name"', () {
      final mapWithSpace = {
        'name ': 'The Burger Studio Inconsistent',
        'description': 'Delicious burgers with inconsistent keys',
        'imageUrl': 'https://example.com/burger.jpg',
        'rating': 4.5,
        'reviewCount': 50,
        'deliveryTime': '25 min',
        'deliveryFee': 1.99,
        'cuisine': 'Burgers',
        'isOpen': true,
        'address': '123 Burger Lane',
      };

      final restaurant = RestaurantModel.fromMap(mapWithSpace, 'rest-space');
      expect(restaurant.id, 'rest-space');
      expect(restaurant.name, 'The Burger Studio Inconsistent');
    });

    test('fromMap parses Firestore map containing "featureBadge" instead of "featuredBadge"', () {
      final mapWithFeatureBadge = {
        'name': 'The Burger Studio',
        'description': 'Delicious burgers',
        'imageUrl': 'https://example.com/burger.jpg',
        'rating': 4.8,
        'reviewCount': 100,
        'deliveryTime': '20 min',
        'deliveryFee': 0,
        'cuisine': 'Burgers',
        'isOpen': true,
        'address': '123 Burger Lane',
        'featureBadge': 'POPULAR',
      };

      final restaurant = RestaurantModel.fromMap(mapWithFeatureBadge, 'rest-badge');
      expect(restaurant.id, 'rest-badge');
      expect(restaurant.featuredBadge, 'POPULAR');
    });

    test('fromMap prioritizes "name" and "featuredBadge" over legacy keys when both exist', () {
      final mapWithBoth = {
        'name': 'Primary Name',
        'name ': 'Fallback Name',
        'featuredBadge': 'Primary Badge',
        'featureBadge': 'Fallback Badge',
      };

      final restaurant = RestaurantModel.fromMap(mapWithBoth, 'rest-both');
      expect(restaurant.name, 'Primary Name');
      expect(restaurant.featuredBadge, 'Primary Badge');
    });

    test('fromMap correctly handles Firestore numeric types for rating, reviewCount, and deliveryFee', () {
      final firestoreData = {
        'id': 'rest-test-1',
        'name': 'The Burger Studio',
        'description': 'Gourmet smashed burgers, loaded fries, and craft shakes.',
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
        'cuisine': 'Burgers',
        'rating': 4.8,
        'reviewCount': 128,
        'deliveryTime': '20-30 min',
        'deliveryFee': 2.99,
        'isOpen': true,
        'address': '123 Gourmet Ave, Food City',
        'featuredBadge': 'Top Rated',
      };

      final restaurant = RestaurantModel.fromMap(firestoreData, 'rest-test-1');

      expect(restaurant.id, 'rest-test-1');
      expect(restaurant.rating, 4.8);
      expect(restaurant.reviewCount, 128);
      expect(restaurant.deliveryFee, '\$2.99');
      expect(restaurant.isOpen, true);

      final freeDeliveryData = Map<String, dynamic>.from(firestoreData)..['deliveryFee'] = 0;
      final freeRestaurant = RestaurantModel.fromMap(freeDeliveryData);
      expect(freeRestaurant.deliveryFee, 'Free delivery');
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
