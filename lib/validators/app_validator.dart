/// Centralised, reusable validation logic — completely decoupled from UI.
class AppValidator {
  AppValidator._(); // prevent instantiation

  // ── Email ─────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final regex = RegExp(r'^[\w.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~;\'']')
        .hasMatch(value)) {
      return 'Password must contain at least 1 special character';
    }
    return null;
  }

  // ── Confirm password ──────────────────────────────────────────────────────
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ── Required (non-empty) ──────────────────────────────────────────────────
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // ── Name ──────────────────────────────────────────────────────────────────
  static String? name(String? value, {String fieldName = 'Name'}) {
    final base = required(value, fieldName: fieldName);
    if (base != null) return base;
    if (value!.trim().length < 2) return '$fieldName must be at least 2 characters';
    return null;
  }

  // ── Password strength description (for UI hints) ──────────────────────────
  static PasswordStrength getStrength(String value) {
    if (value.isEmpty) return PasswordStrength.empty;
    int score = 0;
    if (value.length >= 6) score++;
    if (value.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~;\'']').hasMatch(value)) score++;
    if (score <= 1) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

enum PasswordStrength { empty, weak, medium, strong }