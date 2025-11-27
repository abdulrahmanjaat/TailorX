class Validators {
  Validators._();

  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\\.[^@]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }
}
