import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? message;

  Future<void> sendResetLink() async {
    setState(() {
      isLoading = true;
      message = null;
    });

    final email = emailController.text.trim();
    try {
      final url =
          Uri.parse('http://localhost:8000/api/accounts/password/reset/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          message = "Check your email for password reset instructions.";
        });
      } else {
        setState(() {
          message = "Failed to send reset email. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        message = "Could not connect to the server.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          message!,
                          style: TextStyle(
                            color: message!.contains("Check your email")
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val != null && val.contains('@')
                          ? null
                          : 'Enter a valid email',
                    ),
                    const SizedBox(height: 24),
                    isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  sendResetLink();
                                }
                              },
                              child: const Text("Send Reset Link"),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
