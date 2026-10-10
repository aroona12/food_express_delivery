import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/favorites/models/favorite_model.dart';

void main() {
  group('FavoriteModel', () {
    final testDate = DateTime(2026, 8, 25, 12, 0, 0);
    final model = FavoriteModel(
      restaurantId: 'rest-1',
      userId: 'user-123',
      createdAt: testDate,
    );

    test('instantiates with all required fields', () {
      expect(model.restaurantId, 'rest-1');
      expect(model.userId, 'user-123');
      expect(model.createdAt, testDate);
    });

    test('copyWith modifies specified fields while preserving others', () {
      final updated = model.copyWith(
        restaurantId: 'rest-2',
      );

      expect(updated.restaurantId, 'rest-2');
      expect(updated.userId, 'user-123');
      expect(updated.createdAt, testDate);
    });

    test('toMap serializes model accurately', () {
      final map = model.toMap();

      expect(map['restaurantId'], 'rest-1');
      expect(map['userId'], 'user-123');
      expect(map['createdAt'], testDate.toIso8601String());
    });

    test('fromMap deserializes map with String date accurately', () {
      final map = {
        'restaurantId': 'rest-1',
        'userId': 'user-123',
        'createdAt': testDate.toIso8601String(),
      };

      final fromMapModel = FavoriteModel.fromMap(map);
      expect(fromMapModel.restaurantId, 'rest-1');
      expect(fromMapModel.userId, 'user-123');
      expect(fromMapModel.createdAt, testDate);
    });

    test('fromMap deserializes map with DateTime object accurately', () {
      final map = {
        'restaurantId': 'rest-2',
        'userId': 'user-456',
        'createdAt': testDate,
      };

      final fromMapModel = FavoriteModel.fromMap(map);
      expect(fromMapModel.restaurantId, 'rest-2');
      expect(fromMapModel.userId, 'user-456');
      expect(fromMapModel.createdAt, testDate);
    });

    test('fromMap deserializes map with Firestore Timestamp accurately', () {
      final timestamp = Timestamp.fromDate(testDate);
      final map = {
        'restaurantId': 'rest-3',
        'userId': 'user-789',
        'createdAt': timestamp,
      };

      final fromMapModel = FavoriteModel.fromMap(map);
      expect(fromMapModel.restaurantId, 'rest-3');
      expect(fromMapModel.userId, 'user-789');
      expect(fromMapModel.createdAt, testDate);
    });

    test('fromMap extracts restaurantId from docId when present', () {
      final map = {
        'userId': 'user-789',
        'createdAt': testDate,
      };

      final fromMapModel = FavoriteModel.fromMap(map, 'rest-doc-99');
      expect(fromMapModel.restaurantId, 'rest-doc-99');
      expect(fromMapModel.userId, 'user-789');
      expect(fromMapModel.createdAt, testDate);
    });

    test('equality and hashCode work as expected for identical values', () {
      final model2 = FavoriteModel(
        restaurantId: 'rest-1',
        userId: 'user-123',
        createdAt: testDate,
      );

      expect(model, equals(model2));
      expect(model.hashCode, equals(model2.hashCode));
    });

    test('equality returns false for different fields', () {
      final different = FavoriteModel(
        restaurantId: 'rest-99',
        userId: 'user-123',
        createdAt: testDate,
      );

      expect(model, isNot(equals(different)));
    });

    test('toString returns formatted string representation', () {
      final str = model.toString();
      expect(str, contains('FavoriteModel'));
      expect(str, contains('rest-1'));
      expect(str, contains('user-123'));
    });
  });
}
