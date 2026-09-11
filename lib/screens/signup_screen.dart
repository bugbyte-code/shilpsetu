import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shilpsetu/screens/dashboard_screen.dart';
import 'package:shilpsetu/translations.dart';


class SignupScreen extends StatefulWidget {
  final String selectedLanguage;

  const SignupScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  static const Color backgroundColor = Color(0xFFFFF8F0);
  static const Color primaryColor = Color(0xFF8B4513);
  static const Color darkTextColor = Color(0xFF5D2E0C);
  static const Color lightTextColor = Color(0xFF6D4C41);

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword =
        confirmPasswordController.text.trim();

    if (name.isEmpty) {
      showMessage(t('please_enter_name'));
      return;
    }

    if (email.isEmpty) {
      showMessage(t('please_enter_email'));
      return;
    }

    if (password.isEmpty) {
      showMessage(t('please_enter_password'));
      return;
    }

    if (password != confirmPassword) {
      showMessage(t('passwords_do_not_match'));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'language': widget.selectedLanguage,
        },
      );

      if (!mounted) return;

      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              selectedLanguage: widget.selectedLanguage,
            ),
          ),
        );
      } else {
        showMessage(t('signup_failed'));
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      showMessage(
        error.message.isNotEmpty
            ? error.message
            : t('signup_failed'),
      );
    } catch (_) {
      if (!mounted) return;

      showMessage(t('signup_failed'));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
      ),
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: primaryColor,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  height: 85,
                  width: 85,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4CC),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_outlined,
                    size: 45,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  t('signup_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  t('signup_subtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: lightTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Text(
                t('name'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                decoration: inputDecoration(
                  hint: t('enter_name'),
                  icon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                t('email'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: inputDecoration(
                  hint: t('enter_email'),
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                t('password'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: inputDecoration(
                  hint: t('enter_password'),
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword =
                            !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                t('confirm_password'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: inputDecoration(
                  hint: t('enter_confirm_password'),
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                            !obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          t('signup_button'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t('already_have_account'),
                    style: const TextStyle(
                      color: lightTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      t('login'),
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}