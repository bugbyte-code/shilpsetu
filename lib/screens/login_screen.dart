import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shilpsetu/translations.dart';
import 'package:shilpsetu/screens/signup_screen.dart';
import 'package:shilpsetu/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String selectedLanguage;

  const LoginScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isLoading = false;
  bool isResettingPassword = false;
  bool obscurePassword = true;

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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    // Read the CURRENT values every time Login is pressed.
    final email = emailController.text.trim();

    // IMPORTANT:
    // Do NOT trim passwords.
    // Password must be sent exactly as entered by the user.
    final password = passwordController.text;

    if (email.isEmpty) {
      showMessage(t('please_enter_email'));
      return;
    }

    if (password.isEmpty) {
      showMessage(t('please_enter_password'));
      return;
    }

    // Prevent multiple login requests.
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Make sure Supabase actually returned a user.
      if (response.user == null) {
        throw const AuthException(
          'Login failed. Please try again.',
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            selectedLanguage: widget.selectedLanguage,
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      showMessage(
        error.message.isNotEmpty
            ? error.message
            : t('login_failed'),
      );
    } catch (error) {
      if (!mounted) return;

      debugPrint('LOGIN ERROR: $error');

      showMessage(
        t('login_failed'),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showMessage(
        'Please enter your email address first.',
      );
      return;
    }

    setState(() {
      isResettingPassword = true;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
      );

      if (!mounted) return;

      Navigator.pop(context);

      showMessage(
        'Password reset email sent. Please check your inbox.',
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      Navigator.pop(context);

      showMessage(
        error.message.isNotEmpty
            ? error.message
            : 'Could not send password reset email.',
      );
    } catch (error) {
      if (!mounted) return;

      Navigator.pop(context);

      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isResettingPassword = false;
        });
      }
    }
  }

  // ============================================================
  // FORGOT PASSWORD DIALOG
  // ============================================================

  void showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );

    showDialog(
      context: context,
      barrierDismissible: !isResettingPassword,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: darkTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your registered email address and we will send you a password reset link.',
                    style: TextStyle(
                      color: lightTextColor,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),

              actionsPadding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),

              actions: [
                TextButton(
                  onPressed: isResettingPassword
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: lightTextColor,
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: isResettingPassword
                      ? null
                      : () async {
                          final email =
                              resetEmailController.text.trim();

                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter your email address.',
                                ),
                              ),
                            );
                            return;
                          }

                          emailController.text = email;

                          setDialogState(() {
                            isResettingPassword = true;
                          });

                          try {
                            await Supabase
                                .instance
                                .client
                                .auth
                                .resetPasswordForEmail(
                              email,
                            );

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            showMessage(
                              'Password reset email sent. Please check your inbox.',
                            );
                          } on AuthException catch (error) {
                            if (!mounted) return;

                            setDialogState(() {
                              isResettingPassword = false;
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  error.message.isNotEmpty
                                      ? error.message
                                      : 'Could not send password reset email.',
                                ),
                                backgroundColor: primaryColor,
                              ),
                            );
                          } catch (error) {
                            if (!mounted) return;

                            setDialogState(() {
                              isResettingPassword = false;
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Something went wrong. Please try again.',
                                ),
                                backgroundColor: primaryColor,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isResettingPassword
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Send Link',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: primaryColor,
        ),
      );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 35,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // ==================================================
              // LOGO
              // ==================================================

              Center(
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4CC),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.handyman_outlined,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // TITLE
              // ==================================================

              Center(
                child: Text(
                  t('login_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  t('login_subtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: lightTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ==================================================
              // EMAIL
              // ==================================================

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
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: t('enter_email'),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: primaryColor,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PASSWORD
              // ==================================================

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
                textInputAction: TextInputAction.done,

                // Pressing keyboard Login/Done also performs login.
                onSubmitted: (_) {
                  if (!isLoading) {
                    login();
                  }
                },

                decoration: InputDecoration(
                  hintText: t('enter_password'),

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: primaryColor,
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: primaryColor,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              // ==================================================
              // FORGOT PASSWORD
              // ==================================================

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : showForgotPasswordDialog,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // ==================================================
              // LOGIN BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,

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
                          t('login_button'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // SIGN UP
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Text(
                    t('dont_have_account'),
                    style: const TextStyle(
                      color: lightTextColor,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(
                            selectedLanguage:
                                widget.selectedLanguage,
                          ),
                        ),
                      );
                    },

                    child: Text(
                      t('sign_up'),
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