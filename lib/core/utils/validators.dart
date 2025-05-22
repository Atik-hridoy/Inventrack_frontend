class Validators {
  static String? validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field cannot be empty';
    }
    return null;
  }
}
