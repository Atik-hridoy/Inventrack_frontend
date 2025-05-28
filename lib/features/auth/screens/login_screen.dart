import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/services/api_service.dart'; // Import your API service
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final result = await AuthApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        Navigator.popAndPushNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Login failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 16,
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Animate(
                              effects: [
                                FadeEffect(duration: 600.ms),
                                ScaleEffect()
                              ],
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.blue[100],
                                child: Icon(
                                  FontAwesomeIcons.userLarge,
                                  color: Colors.blue[800],
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              "Welcome Back",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                                letterSpacing: 1.2,
                              ),
                            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(),
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon:
                                    const Icon(FontAwesomeIcons.envelope),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (val) =>
                                  val != null && val.contains('@')
                                      ? null
                                      : 'Enter a valid email',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              style: GoogleFonts.poppins(),
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(FontAwesomeIcons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (val) => val != null && val.length >= 6
                                  ? null
                                  : 'Password too short',
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                    FontAwesomeIcons.arrowRightToBracket,
                                    size: 18),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.blue[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: _submitLogin,
                                label: Text(
                                  "Login",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FontAwesomeIcons.userPlus,
                                    size: 16, color: Colors.blueGrey),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: Text(
                                    "Don't have an account? Register",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FontAwesomeIcons.key,
                                    size: 16, color: Colors.blueGrey),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/forgot-password');
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
