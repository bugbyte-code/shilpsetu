import 'package:flutter/material.dart';
import 'buyer_opportunities_screen.dart';
import '../translations.dart';

class BuyersScreen extends StatefulWidget {
  final String selectedLanguage;

  const BuyersScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<BuyersScreen> createState() => _BuyersScreenState();
}

class _BuyersScreenState extends State<BuyersScreen> {
  bool isLoading = true;

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t('buyers'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= HEADER =================

            Text(
              t('ai_market_match'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D2E0C),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              t('market_match_description'),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6D4C41),
              ),
            ),

            const SizedBox(height: 25),

            // ================= AI ANALYSIS CARD =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4CC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          'SHILPSETU AI',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D2E0C),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          isLoading
                              ? t('analyzing_products')
                              : t('market_analysis_completed'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6D4C41),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= LOADING =================

            if (isLoading)
              Center(
                child: Column(
                  children: [

                    const SizedBox(height: 30),

                    const CircularProgressIndicator(
                      color: Color(0xFF8B4513),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      t('finding_best_markets'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D2E0C),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      t('matching_products_buyers'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6D4C41),
                      ),
                    ),
                  ],
                ),
              )

            // ================= MARKET RESULTS =================

            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    t('best_market_matches'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D2E0C),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // CORPORATE GIFTING

                  marketCard(
                    context: context,
                    icon: Icons.card_giftcard,
                    title: t('corporate_gifting'),
                    score: '92% ${t('match')}',
                    description:
                        t('corporate_gifting_description'),
                    demand:
                        '${t('potential_demand')}: ${t('high')}',
                    originalTitle: 'Corporate Gifting',
                  ),

                  const SizedBox(height: 15),

                  // HOTELS & RESORTS

                  marketCard(
                    context: context,
                    icon: Icons.hotel,
                    title: t('hotels_resorts'),
                    score: '86% ${t('match')}',
                    description:
                        t('hotels_resorts_description'),
                    demand:
                        '${t('potential_demand')}: ${t('medium_high')}',
                    originalTitle: 'Hotels & Resorts',
                  ),

                  const SizedBox(height: 15),

                  // BOUTIQUES & GIFT STORES

                  marketCard(
                    context: context,
                    icon: Icons.storefront,
                    title: t('boutiques_gift_stores'),
                    score: '81% ${t('match')}',
                    description:
                        t('boutiques_description'),
                    demand:
                        '${t('potential_demand')}: ${t('medium')}',
                    originalTitle:
                        'Boutiques & Gift Stores',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MARKET CARD
  // ============================================================

  Widget marketCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String score,
    required String description,
    required String demand,
    required String originalTitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= TITLE ROW =================

          Row(
            children: [

              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4CC),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  icon,
                  color: const Color(0xFF8B4513),
                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D2E0C),
                  ),
                ),
              ),

              Text(
                score,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ================= DESCRIPTION =================

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6D4C41),
            ),
          ),

          const SizedBox(height: 15),

          // ================= DEMAND =================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),

            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E0),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              demand,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ================= VIEW OPPORTUNITIES =================

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BuyerOpportunitiesScreen(
                      marketTitle: originalTitle,
                      marketIcon: icon,

                      // IMPORTANT:
                      // Pass selected language
                      selectedLanguage:
                          widget.selectedLanguage,
                    ),
                  ),
                );
              },

              style: OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xFF8B4513),

                side: const BorderSide(
                  color: Color(0xFF8B4513),
                ),

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 13,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),

              child: Text(
                t('view_opportunities'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}