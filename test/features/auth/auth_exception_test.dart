import 'package:flutter_test/flutter_test.dart';
import 'package:foodexpressdelivery/features/auth/data/auth_exception.dart';

void main() {
  group('AuthException', () {
    test('standard AuthException retains message and code', () {
      const exception = AuthException('Invalid password', code: 'wrong-password');
      expect(exception.message, 'Invalid password');
      expect(exception.code, 'wrong-password');
      expect(exception.toString(), 'Invalid password');
    });
  });
}
