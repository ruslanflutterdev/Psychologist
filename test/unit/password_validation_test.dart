import 'package:flutter_test/flutter_test.dart';
import 'package:heros_journey/features/auth_registration/validators/password_validators.dart';

void main() {
  group('Password Validation Unit Tests', () {
    const validPassword = 'StrongPassword123!';

    test('1. Valid password should pass validation', () {
      final result = validateSecurePassword(validPassword);
      expect(result, isNull);
    });

    test('2. Password shorter than 8 characters should fail', () {
      final result = validateSecurePassword('Short1!');
      expect(result, 'Минимум 8 символов');
    });

    test('3. Password without uppercase letter should fail', () {
      final result = validateSecurePassword('password123!');
      expect(result, 'Добавьте заглавную букву');
    });

    test('4. Password without lowercase letter should fail', () {
      final result = validateSecurePassword('PASSWORD123!');
      expect(result, 'Добавьте строчную букву');
    });

    test('5. Password without digit should fail', () {
      final result = validateSecurePassword('Password!');
      expect(result, 'Добавьте цифру');
    });

    test('6. Password without special character should fail', () {
      final result = validateSecurePassword('Password123');
      expect(result, 'Добавьте спецсимвол (!@#\$...)');
    });

    test('7. Empty password should fail with "Введите пароль"', () {
      final result = validateSecurePassword('');
      expect(result, 'Введите пароль');
    });

    test('8. Password with minimal valid criteria should pass', () {
      final result = validateSecurePassword('A1!aaaaa');
      expect(result, isNull);
    });
  });
}
