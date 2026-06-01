import 'package:flutter_test/flutter_test.dart';
import 'package:edu_app/validators/app_validator.dart';

void main() {
  group('AppValidator.email', () {
    test('returns error for empty value', () {
      expect(AppValidator.email(''), isNotNull);
      expect(AppValidator.email(null), isNotNull);
    });

    test('returns error for invalid email', () {
      expect(AppValidator.email('notanemail'), isNotNull);
      expect(AppValidator.email('missing@'), isNotNull);
      expect(AppValidator.email('@nodomain.com'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(AppValidator.email('user@example.com'), isNull);
      expect(AppValidator.email('test.name+tag@domain.co'), isNull);
    });
  });

  group('AppValidator.password', () {
    test('returns error for empty', () {
      expect(AppValidator.password(''), isNotNull);
      expect(AppValidator.password(null), isNotNull);
    });

    test('returns error for too short', () {
      expect(AppValidator.password('Ab!'), isNotNull);
    });

    test('returns error when no uppercase', () {
      expect(AppValidator.password('abcde!1'), isNotNull);
    });

    test('returns error when no special char', () {
      expect(AppValidator.password('Abcdef1'), isNotNull);
    });

    test('returns null for valid password', () {
      expect(AppValidator.password('Hello@1'), isNull);
      expect(AppValidator.password('Strong#Pass9'), isNull);
    });
  });

  group('AppValidator.confirmPassword', () {
    test('returns error when passwords do not match', () {
      expect(AppValidator.confirmPassword('hello', 'world'), isNotNull);
    });

    test('returns null when passwords match', () {
      expect(AppValidator.confirmPassword('Hello@1', 'Hello@1'), isNull);
    });

    test('returns error for empty confirm', () {
      expect(AppValidator.confirmPassword('', 'Hello@1'), isNotNull);
    });
  });

  group('AppValidator.required', () {
    test('returns error for blank', () {
      expect(AppValidator.required('   '), isNotNull);
      expect(AppValidator.required(null), isNotNull);
    });

    test('returns null for non-blank', () {
      expect(AppValidator.required('hello'), isNull);
    });
  });

  group('AppValidator.getStrength', () {
    test('empty returns empty', () {
      expect(AppValidator.getStrength(''), PasswordStrength.empty);
    });

    test('short simple password is weak', () {
      expect(AppValidator.getStrength('abc'), PasswordStrength.weak);
    });

    test('medium complexity', () {
      expect(AppValidator.getStrength('Abcdef1'), PasswordStrength.medium);
    });

    test('high complexity is strong', () {
      expect(AppValidator.getStrength('Str0ng@Pass!'), PasswordStrength.strong);
    });
  });
}