import 'package:flutter/material.dart';
import 'login_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'English';

  static const Color backgroundColor = Color(0xFFFFF8F0);
  static const Color primaryColor = Color(0xFF8B4513);
  static const Color darkTextColor = Color(0xFF5D2E0C);
  static const Color lightTextColor = Color(0xFF6D4C41);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Choose Language',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                const Center(
                  child: Icon(
                    Icons.language,
                    size: 70,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(height: 25),

                const Center(
                  child: Text(
                    'Select your language',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    'Choose the language you are comfortable with',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: lightTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                languageCard(
                  language: 'English',
                  subtitle: 'English',
                ),

                const SizedBox(height: 15),

                languageCard(
                  language: 'Hindi',
                  subtitle: 'हिन्दी',
                ),

                const SizedBox(height: 15),

                languageCard(
                  language: 'Telugu',
                  subtitle: 'తెలుగు',
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget languageCard({
    required String language,
    required String subtitle,
  }) {
    final bool isSelected = selectedLanguage == language;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFE4CC)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4CC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.translate,
                color: primaryColor,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: lightTextColor,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? primaryColor
                  : lightTextColor,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}