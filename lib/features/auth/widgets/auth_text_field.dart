import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';

// A reusable text field widget for authentication forms (e.g., login, signup)
class AuthTextField extends StatelessWidget {
  final String label; // Label for the text field
  final TextEditingController controller; // Controls the text being edited
  final bool obscureText; // Whether to hide the text (for passwords)
  final TextInputType keyboardType; // Type of keyboard to display

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false, // Default: not obscured
    this.keyboardType = TextInputType.text, // Default: text keyboard
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // Connects the field to its controller
      keyboardType: keyboardType, // Sets keyboard type
      obscureText: obscureText, // Hides text if true
      validator:
          Validators.validateNotEmpty, // Validates that field is not empty
      decoration: InputDecoration(
        labelText: label, // Shows label above the field
        border: const OutlineInputBorder(), // Adds a border around the field
      ),
    );
  }
}
