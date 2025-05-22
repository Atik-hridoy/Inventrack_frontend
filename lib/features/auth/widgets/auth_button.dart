import 'package:flutter/material.dart';

// A reusable button widget for authentication actions (e.g., login, signup)
class AuthButton extends StatelessWidget {
  final String text; // The text displayed on the button
  final VoidCallback onPressed; // Callback function when button is pressed

  const AuthButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Makes the button stretch to full width
      child: ElevatedButton(
        onPressed: onPressed, // Calls the provided function when pressed
        child: Text(text), // Displays the provided text
      ),
    );
  }
}
