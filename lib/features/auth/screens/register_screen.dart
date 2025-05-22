import 'package:flutter/material.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each form field
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Function to handle form submission
  void _submitRegister() {
    if (_formKey.currentState!.validate()) {
      // Show a simple snackbar for now
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registering...')),
      );
      Navigator.popAndPushNamed(context, '/dashboard');

      // TODO: Add your API call logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),

      // Center the form vertically and horizontally
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20), // Add padding around the form

          // Constrain width so it's not too wide on large screens
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 400), // Good for tablets/desktops

            // The actual form widget
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Only take as much space as needed
                children: [
                  // Email Input
                  AuthTextField(
                    label: "Email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  AuthTextField(
                    label: "Password",
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Input
                  AuthTextField(
                    label: "Confirm Password",
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  AuthButton(
                    text: "Register",
                    onPressed: _submitRegister,
                  ),

                  // Link to Login screen
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Already have an account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
