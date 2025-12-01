class Validators {
  Validators._();

  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Simple email validation for customer emails
  /// Accepts any email as long as it follows basic format:
  /// - Must contain @
  /// - At least 2 characters before @
  /// - At least 2 characters after @
  /// - At least 2 characters after final dot
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional for customers
    }

    final email = value.trim();

    // Must contain @
    if (!email.contains('@')) {
      return 'Email must contain @';
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Invalid email format';
    }

    final localPart = parts[0];
    final domainPart = parts[1];

    // At least 2 characters before @
    if (localPart.length < 2) {
      return 'Email must have at least 2 characters before @';
    }

    // At least 2 characters after @
    if (domainPart.length < 2) {
      return 'Email must have at least 2 characters after @';
    }

    // Must contain at least one dot in domain
    if (!domainPart.contains('.')) {
      return 'Email domain must contain a dot';
    }

    // At least 2 characters after final dot
    final domainParts = domainPart.split('.');
    if (domainParts.length < 2 || domainParts.last.length < 2) {
      return 'Email must have at least 2 characters after final dot';
    }

    return null;
  }

  /// Phone number validation (with country code)
  /// Validates that phone number has at least 10 digits after country code
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove spaces and extract digits
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    // Should have at least country code (1-3 digits) + 10 digits = minimum 11 digits
    // But we'll be lenient and check for at least 10 digits total
    if (digits.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    return null;
  }

  /// Password validation - must be at least 8 characters
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Email validation for auth (required field)
  static String? emailRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    return email(value);
  }
}
