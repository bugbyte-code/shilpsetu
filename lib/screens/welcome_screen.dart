import 'package:flutter/material.dart';
import 'language_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goToLanguageScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // =====================================================
            // ORIGINAL WELCOME IMAGE RATIO
            // =====================================================

            const double imageRatio = 1024 / 1536;

            double imageWidth;
            double imageHeight;

            // =====================================================
            // PORTRAIT / MOBILE
            // =====================================================

            if (screenHeight >= screenWidth) {
              imageWidth = screenWidth;
              imageHeight = imageWidth / imageRatio;

              if (imageHeight > screenHeight) {
                imageHeight = screenHeight;
                imageWidth = imageHeight * imageRatio;
              }
            }

            // =====================================================
            // LANDSCAPE / WEB
            // =====================================================

            else {
              imageHeight = screenHeight;
              imageWidth = imageHeight * imageRatio;

              if (imageWidth > screenWidth) {
                imageWidth = screenWidth;
                imageHeight = imageWidth / imageRatio;
              }
            }

            return Center(
              child: SizedBox(
                width: imageWidth,
                height: imageHeight,
                child: Stack(
                  children: [

                    // =================================================
                    // WELCOME IMAGE
                    // =================================================

                    Positioned.fill(
                      child: IgnorePointer(
                        child: Image.asset(
                          'assets1/images/welcome_enhaced.jpeg',
                          fit: BoxFit.fill,
                          gaplessPlayback: true,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFFFF8F0),

                              child: const Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .image_not_supported_outlined,
                                      size: 60,
                                      color:
                                          Color(0xFF8B4513),
                                    ),

                                    SizedBox(height: 12),

                                    Text(
                                      'Welcome image not found',
                                      style: TextStyle(
                                        color:
                                            Color(0xFF5D2E0C),
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // =================================================
                    // GET STARTED BUTTON
                    // =================================================

                    Positioned(
                      left: imageWidth * 0.20,
                      right: imageWidth * 0.20,
                      top: imageHeight * 0.515,
                      height: imageHeight * 0.085,

                      child: GestureDetector(
                        behavior:
                            HitTestBehavior.opaque,

                        onTap: () {
                          _goToLanguageScreen(context);
                        },

                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}