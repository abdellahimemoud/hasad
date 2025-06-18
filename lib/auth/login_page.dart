import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasad_app/auth/google_auth_service.dart';
import 'package:hasad_app/pages/home_page.dart';
import 'signup_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isGoogleLoading = false;

  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$");
    return regex.hasMatch(email);
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No user found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        case 'invalid-email':
          message = "Invalid email format.";
          break;
        default:
          message = "Login failed. ${e.message}";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.trim().isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset link sent!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first.")),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => isGoogleLoading = true);
    try {
      final user = await GoogleAuthService.signInWithGoogle();
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Échec de la connexion avec Google: ${e.toString()}")),
      );
    } finally {
      setState(() => isGoogleLoading = false);
    }
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
                _emailField(),
                const SizedBox(height: 10),
                _passwordField(),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: isLoading
                      ? const SpinKitThreeBounce(
                          key: ValueKey('bounceLoader'),
                          color: Color.fromARGB(255, 37, 100, 84),
                          size: 30,
                        )
                      : ElevatedButton(
                          key: const ValueKey('loginButton'),
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 37, 100, 84),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 110, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.login,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                TextButton(
                  onPressed: resetPassword,
                  child: Text(
                    AppLocalizations.of(context)!.forgetPassword,
                    style: TextStyle(color: Color(0xFF1B3B2F)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.or),
                const SizedBox(height: 30),
                _googleSignInButton(),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.haveAccount,
                      style: TextStyle(color: Color(0xFF1B3B2F)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
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

  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
          color: Color(0xFF173F35), fontWeight: FontWeight.w600),
      decoration: _inputDecoration(
          AppLocalizations.of(context)!.emailHint, Icons.email),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Veuillez saisir votre adresse e-mail";
        } else if (!isValidEmail(value.trim())) {
          return "Entrez une adresse e-mail valide";
        }
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(
          color: Color(0xFF173F35), fontWeight: FontWeight.w600),
      decoration: _inputDecoration(
        AppLocalizations.of(context)!.passHint,
        Icons.lock,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: const Color.fromARGB(255, 37, 100, 84),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez entrer votre mot de passe";
        } else if (value.length < 6) {
          return "Password must be at least 6 characters long";
        }
        return null;
      },
    );
  }

  Widget _googleSignInButton() {
    return isGoogleLoading
        ? const Center(
            child: SpinKitThreeBounce(
              color: Color.fromARGB(255, 37, 100, 84),
              size: 40,
            ),
          )
        : GestureDetector(
            onTap: signInWithGoogle,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(40),
                color: const Color.fromARGB(255, 241, 248, 241),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/google_logo.png', height: 24, width: 24),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.continueWithGoogle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
