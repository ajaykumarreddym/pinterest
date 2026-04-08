/// Email validator
class EmailValidator {
  EmailValidator._();

  /// Email regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validate email format
  static bool isValid(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Get validation error message
  static String? validate(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    if (!isValid(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}

/// Password validator with configurable rules
class PasswordValidator {
  PasswordValidator._();

  /// Minimum password length
  static const int minLength = 8;

  /// Maximum password length
  static const int maxLength = 128;

  /// Validate password meets all requirements
  static bool isValid(
    String password, {
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecialChar = true,
  }) {
    if (password.isEmpty) return false;
    if (password.length < minLength || password.length > maxLength) {
      return false;
    }

    if (requireUppercase && !hasUppercase(password)) return false;
    if (requireLowercase && !hasLowercase(password)) return false;
    if (requireDigit && !hasDigit(password)) return false;
    if (requireSpecialChar && !hasSpecialChar(password)) return false;

    return true;
  }

  static bool hasUppercase(String password) =>
      password.contains(RegExp(r'[A-Z]'));

  static bool hasLowercase(String password) =>
      password.contains(RegExp(r'[a-z]'));

  static bool hasDigit(String password) =>
      password.contains(RegExp(r'[0-9]'));

  static bool hasSpecialChar(String password) =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  /// Get password strength (0.0 to 1.0)
  static double getStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    if (password.length >= minLength) strength += 0.1;
    if (password.length >= 12) strength += 0.1;
    if (password.length >= 16) strength += 0.1;

    if (hasUppercase(password)) strength += 0.1;
    if (hasLowercase(password)) strength += 0.1;
    if (hasDigit(password)) strength += 0.1;
    if (hasSpecialChar(password)) strength += 0.1;

    if (password.length >= 20) strength += 0.1;
    if (RegExp(r'[A-Z].*[A-Z]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[!@#$%^&*].*[!@#$%^&*]').hasMatch(password)) {
      strength += 0.1;
    }

    return strength.clamp(0.0, 1.0);
  }

  /// Get validation error message
  static String? validate(
    String? password, {
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecialChar = true,
  }) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (password.length > maxLength) {
      return 'Password must not exceed $maxLength characters';
    }

    if (requireUppercase && !hasUppercase(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (requireLowercase && !hasLowercase(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (requireDigit && !hasDigit(password)) {
      return 'Password must contain at least one number';
    }

    if (requireSpecialChar && !hasSpecialChar(password)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate password confirmation matches
  static String? validateConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null;
  }
}

/// Input validation utilities.
class Validators {
  const Validators._();

  /// Email regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone regex pattern (international format)
  static final RegExp _phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');

  /// Validate email
  static String? email(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return errorMessage ?? 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  static String? password(
    String? value, {
    int minLength = 6,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Password is required';
    }
    if (value.length < minLength) {
      return errorMessage ??
          'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validate required field
  static String? notEmpty(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number
  static String? phone(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) {
      return errorMessage ?? 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(
    String? value,
    int length, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value == null || value.length < length) {
      return errorMessage ??
          '${fieldName ?? 'This field'} must be at least $length characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(
    String? value,
    int length, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value != null && value.length > length) {
      return errorMessage ??
          '${fieldName ?? 'This field'} must be at most $length characters';
    }
    return null;
  }

  /// Validate confirm password
  static String? confirmPassword(
    String? value,
    String? password, {
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Please confirm your password';
    }
    if (value != password) {
      return errorMessage ?? 'Passwords do not match';
    }
    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
