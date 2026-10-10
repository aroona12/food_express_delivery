import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/address/models/address_model.dart';

void main() {
  group('AddressModel Domain Entity Tests', () {
    final testDate = DateTime(2026, 8, 25, 14, 30);
    final model = AddressModel(
      id: 'addr-123',
      userId: 'user-456',
      label: 'Home',
      fullAddress: '742 Evergreen Terrace, Apt 4B',
      city: 'Springfield',
      phone: '+1 (555) 012-3456',
      additionalInstructions: 'Ring buzzer twice',
      isDefault: true,
      createdAt: testDate,
    );

    test('instantiates with all required and optional properties correctly', () {
      expect(model.id, 'addr-123');
      expect(model.userId, 'user-456');
      expect(model.label, 'Home');
      expect(model.fullAddress, '742 Evergreen Terrace, Apt 4B');
      expect(model.city, 'Springfield');
      expect(model.phone, '+1 (555) 012-3456');
      expect(model.additionalInstructions, 'Ring buzzer twice');
      expect(model.isDefault, isTrue);
      expect(model.createdAt, testDate);
    });

    test('formattedAddress concatenates street and city', () {
      expect(
        model.formattedAddress,
        '742 Evergreen Terrace, Apt 4B, Springfield',
      );

      final noCity = model.copyWith(city: '');
      expect(noCity.formattedAddress, '742 Evergreen Terrace, Apt 4B');
    });

    test('copyWith creates modified copy preserving other fields', () {
      final updated = model.copyWith(
        label: 'Work',
        city: 'Shelbyville',
        isDefault: false,
      );

      expect(updated.id, 'addr-123');
      expect(updated.userId, 'user-456');
      expect(updated.label, 'Work');
      expect(updated.fullAddress, '742 Evergreen Terrace, Apt 4B');
      expect(updated.city, 'Shelbyville');
      expect(updated.phone, '+1 (555) 012-3456');
      expect(updated.isDefault, isFalse);
    });

    test('toMap serializes model into Map accurately', () {
      final map = model.toMap();

      expect(map['id'], 'addr-123');
      expect(map['userId'], 'user-456');
      expect(map['label'], 'Home');
      expect(map['fullAddress'], '742 Evergreen Terrace, Apt 4B');
      expect(map['city'], 'Springfield');
      expect(map['phone'], '+1 (555) 012-3456');
      expect(map['additionalInstructions'], 'Ring buzzer twice');
      expect(map['isDefault'], isTrue);
      expect(map['createdAt'], testDate.toIso8601String());
    });

    test('fromMap deserializes map with String createdAt accurately', () {
      final map = {
        'id': 'addr-999',
        'userId': 'user-999',
        'label': 'Office',
        'fullAddress': '500 Tech Blvd',
        'city': 'Metropolis',
        'phone': '+1 (555) 111-2222',
        'additionalInstructions': 'Leave at desk',
        'isDefault': false,
        'createdAt': testDate.toIso8601String(),
      };

      final parsed = AddressModel.fromMap(map, 'doc-999');

      expect(parsed.id, 'doc-999');
      expect(parsed.userId, 'user-999');
      expect(parsed.label, 'Office');
      expect(parsed.fullAddress, '500 Tech Blvd');
      expect(parsed.city, 'Metropolis');
      expect(parsed.phone, '+1 (555) 111-2222');
      expect(parsed.additionalInstructions, 'Leave at desk');
      expect(parsed.isDefault, isFalse);
      expect(parsed.createdAt, testDate);
    });

    test('fromMap deserializes map with DateTime object and defaults missing values', () {
      final map = {
        'id': 'addr-1',
        'userId': 'user-1',
        'fullAddress': '123 Oak St',
        'city': 'Capital City',
        'phone': '555-1234',
        'createdAt': testDate,
      };

      final parsed = AddressModel.fromMap(map);

      expect(parsed.label, 'Home'); // default
      expect(parsed.isDefault, isFalse); // default
      expect(parsed.additionalInstructions, isNull);
    });

    test('fromMap deserializes map with Firestore Timestamp accurately', () {
      final timestamp = Timestamp.fromDate(testDate);
      final map = {
        'id': 'addr-ts',
        'userId': 'user-ts',
        'label': 'Cabin',
        'fullAddress': '456 Forest Rd',
        'city': 'Timberline',
        'phone': '555-7890',
        'isDefault': true,
        'createdAt': timestamp,
      };

      final parsed = AddressModel.fromMap(map, 'doc-ts');

      expect(parsed.id, 'doc-ts');
      expect(parsed.userId, 'user-ts');
      expect(parsed.label, 'Cabin');
      expect(parsed.fullAddress, '456 Forest Rd');
      expect(parsed.city, 'Timberline');
      expect(parsed.phone, '555-7890');
      expect(parsed.isDefault, isTrue);
      expect(parsed.createdAt, testDate);
    });

    test('equality and hashCode verify identical instances', () {
      final model2 = AddressModel(
        id: 'addr-123',
        userId: 'user-456',
        label: 'Home',
        fullAddress: '742 Evergreen Terrace, Apt 4B',
        city: 'Springfield',
        phone: '+1 (555) 012-3456',
        additionalInstructions: 'Ring buzzer twice',
        isDefault: true,
        createdAt: testDate,
      );

      expect(model, equals(model2));
      expect(model.hashCode, equals(model2.hashCode));
    });

    test('equality returns false for different fields', () {
      final different = model.copyWith(id: 'addr-other');
      expect(model, isNot(equals(different)));
    });

    test('toString returns informative debug representation', () {
      final str = model.toString();
      expect(str, contains('AddressModel'));
      expect(str, contains('addr-123'));
      expect(str, contains('Home'));
      expect(str, contains('Springfield'));
    });
  });
}
