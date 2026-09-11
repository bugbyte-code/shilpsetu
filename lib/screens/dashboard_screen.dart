import 'package:flutter/material.dart';

import '../translations.dart';
import 'add_product_screen.dart';
import 'products_screen.dart';
import 'buyers_screen.dart';
import 'pricing_screen.dart';
import 'sales_screen.dart';
import 'assistant_screen.dart';
import 'my_connections_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String selectedLanguage;

  const DashboardScreen({
    super.key,
    required this.selectedLanguage,
  });

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFFFF8F0);
  static const Color primaryColor = Color(0xFF8B4513);
  static const Color darkTextColor = Color(0xFF5D2E0C);
  static const Color lightTextColor = Color(0xFF6D4C41);

  // ============================================================
  // TRANSLATION
  // ============================================================

  String t(String key) {
    return AppTranslations.get(
      selectedLanguage,
      key,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ShilpSetu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ====================================================
            // GREETING
            // ====================================================

            Text(
              t('namaste'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              t('dashboard_question'),
              style: const TextStyle(
                fontSize: 16,
                color: lightTextColor,
              ),
            ),

            const SizedBox(height: 30),

            // ====================================================
            // ADD PRODUCT
            // ====================================================

            SizedBox(
              width: double.infinity,
              height: 100,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductScreen(
                        selectedLanguage: selectedLanguage,
                      ),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Icon(
                      Icons.camera_alt,
                      size: 35,
                    ),

                    const SizedBox(width: 15),

                    Text(
                      t('add_product'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // PRODUCTS + PRICING
            // ====================================================

            Row(
              children: [

                // ================= PRODUCTS =================

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },

                    child: dashboardCard(
                      Icons.inventory_2,
                      t('products'),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // ================= PRICING =================

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PricingScreen(
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },

                    child: dashboardCard(
                      Icons.currency_rupee,
                      t('pricing'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ====================================================
            // BUYERS + SALES
            // ====================================================

            Row(
              children: [

                // ================= BUYERS =================

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyersScreen(
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },

                    child: dashboardCard(
                      Icons.people,
                      t('buyers'),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // ================= SALES =================

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SalesScreen(
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },

                    child: dashboardCard(
                      Icons.bar_chart,
                      t('sales'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ====================================================
            // MY CONNECTIONS
            // ====================================================

            Center(
              child: SizedBox(
                width: (MediaQuery.of(context).size.width - 55) / 2,
                height: 120,

                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyConnectionsScreen(
                          selectedLanguage: selectedLanguage,
                        ),
                      ),
                    );
                  },

                  child: dashboardCard(
                    Icons.handshake_outlined,
                    t('my_connections'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            // ====================================================
            // SHILPSETU ASSISTANT
            // ====================================================

            Center(
              child: Column(
                children: [

                  Text(
                    t('need_help'),
                    style: const TextStyle(
                      fontSize: 15,
                      color: lightTextColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  FloatingActionButton.extended(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssistantScreen(
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.mic,
                    ),

                    label: Text(
                      t('talk_to_shilpsetu'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DASHBOARD CARD
  // ============================================================

  Widget dashboardCard(
    IconData icon,
    String title,
  ) {
    return Container(
      height: 120,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            size: 38,
            color: primaryColor,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
        ],
      ),
    );
  }
}