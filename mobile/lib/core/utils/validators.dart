class Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = double.tryParse(value);
    if (n == null) return 'Invalid number';
    if (n < 0) return 'Must be a positive number';
    return null;
  }

  static String? nonNegativeNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = double.tryParse(value);
    if (n == null) return 'Invalid number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }
}
