import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hasad_app/auth/login_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();
        final name = nameController.text.trim();

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
        await FirebaseAuth.instance.currentUser!.reload();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Registration successful! You can now log in.",
            style: TextStyle(color: Color.fromARGB(255, 243, 248, 243)),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12),
        ));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      } finally {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$");
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/login_hasad.png', height: 200),
                const SizedBox(height: 30),
                _textField(nameController, Icons.person, "Enter your name"),
                const SizedBox(height: 10),
                _emailField(),
                const SizedBox(height: 10),
                _passwordField(passwordController, "Enter your password"),
                const SizedBox(height: 10),
                _passwordField(
                    confirmPasswordController, "Confirm your password",
                    confirm: true),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: _isLoading
                      ? const SpinKitThreeBounce(
                          key: ValueKey('bounceLoader'),
                          color: Color.fromARGB(255, 37, 100, 84),
                          size: 30.0,
                        )
                      : ElevatedButton(
                          key: const ValueKey('signupButton'),
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 37, 100, 84),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 140, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ",
                        style: TextStyle(color: Color(0xFF1B3B2F))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 37, 100, 84)),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF7D7D7D)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
            color: Color.fromARGB(255, 37, 100, 84), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.green, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _textField(
      TextEditingController controller, IconData icon, String hint) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
          color: Color(0xFF173F35), fontWeight: FontWeight.w600),
      decoration: _inputDecoration(hint, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "This field can't be empty";
        }
        return null;
      },
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
          color: Color(0xFF173F35), fontWeight: FontWeight.w600),
      decoration: _inputDecoration("Enter your email", Icons.email),
      validator: (value) =>
          value != null && isValidEmail(value) ? null : "Enter a valid email",
    );
  }

  Widget _passwordField(TextEditingController controller, String hint,
      {bool confirm = false}) {
    final isObscured = confirm ? _obscureConfirmPassword : _obscurePassword;

    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      style: const TextStyle(
          color: Color(0xFF173F35), fontWeight: FontWeight.w600),
      decoration: _inputDecoration(
        hint,
        Icons.lock,
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility : Icons.visibility_off,
            color: const Color.fromARGB(255, 37, 100, 84),
          ),
          onPressed: () {
            setState(() {
              if (confirm) {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              } else {
                _obscurePassword = !_obscurePassword;
              }
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        } else if (value.length < 6) {
          return "Password must be at least 6 characters long";
        } else if (confirm && value != passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }
}
