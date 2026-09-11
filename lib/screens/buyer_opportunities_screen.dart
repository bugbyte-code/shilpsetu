import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../translations.dart';

class BuyerOpportunitiesScreen extends StatefulWidget {
  final String marketTitle;
  final IconData marketIcon;
  final String selectedLanguage;

  const BuyerOpportunitiesScreen({
    super.key,
    required this.marketTitle,
    required this.marketIcon,
    required this.selectedLanguage,
  });

  @override
  State<BuyerOpportunitiesScreen> createState() =>
      _BuyerOpportunitiesScreenState();
}

class _BuyerOpportunitiesScreenState
    extends State<BuyerOpportunitiesScreen> {
  // Stores the buyer currently being connected to.
  // This prevents all three buttons from showing "Connecting..."
  String? connectingBuyer;

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      // ================= APP BAR =================

      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t('buyer_opportunities'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= BODY =================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= MARKET HEADER =================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4CC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      widget.marketIcon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslatedMarketTitle(),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D2E0C),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          t('potential_buyer_opportunities'),
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

            Text(
              t('potential_buyers'),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D2E0C),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              t('connect_businesses'),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6D4C41),
              ),
            ),

            const SizedBox(height: 20),

            // ================= BUYER 1 =================

            buyerCard(
              context: context,
              name: 'ABC Corporate Gifts',
              location: 'Hyderabad',
              lookingFor: t('handmade_gift_items'),
              orderSize: '50–100 ${t('units')}',
            ),

            const SizedBox(height: 15),

            // ================= BUYER 2 =================

            buyerCard(
              context: context,
              name: 'Heritage Hampers',
              location: 'Bengaluru',
              lookingFor: t('indian_handicrafts'),
              orderSize: '25–50 ${t('units')}',
            ),

            const SizedBox(height: 15),

            // ================= BUYER 3 =================

            buyerCard(
              context: context,
              name: 'Craft & Culture Store',
              location: 'Mumbai',
              lookingFor: t('traditional_handmade_products'),
              orderSize: '20–40 ${t('units')}',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRANSLATED MARKET TITLE
  // ============================================================

  String getTranslatedMarketTitle() {
    if (widget.marketTitle == 'Corporate Gifting') {
      return t('corporate_gifting');
    }

    if (widget.marketTitle == 'Hotels & Resorts') {
      return t('hotels_resorts');
    }

    if (widget.marketTitle == 'Boutiques & Gift Stores') {
      return t('boutiques_gift_stores');
    }

    return widget.marketTitle;
  }

  // ============================================================
  // BUYER CARD
  // ============================================================

  Widget buyerCard({
    required BuildContext context,
    required String name,
    required String location,
    required String lookingFor,
    required String orderSize,
  }) {
    final bool isThisBuyerConnecting =
        connectingBuyer == name;

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
          // ================= NAME =================

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  color: Color(0xFF8B4513),
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D2E0C),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ================= LOCATION =================

          infoRow(
            Icons.location_on_outlined,
            t('location'),
            location,
          ),

          const SizedBox(height: 12),

          // ================= LOOKING FOR =================

          infoRow(
            Icons.search,
            t('looking_for'),
            lookingFor,
          ),

          const SizedBox(height: 12),

          // ================= ORDER SIZE =================

          infoRow(
            Icons.inventory_2_outlined,
            t('potential_order'),
            orderSize,
          ),

          const SizedBox(height: 20),

          // ================= CONNECT BUTTON =================

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: connectingBuyer != null
                  ? null
                  : () {
                      connectToBuyer(
                        context,
                        name,
                        location,
                      );
                    },

              icon: isThisBuyerConnecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.handshake_outlined,
                    ),

              label: Text(
                isThisBuyerConnecting
                    ? t('connecting')
                    : t('connect'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF8B4513),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFFB88A6A),
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONNECT TO BUYER
  // ============================================================

  Future<void> connectToBuyer(
    BuildContext context,
    String buyerName,
    String location,
  ) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      showError(
        context,
        t('please_login_again'),
      );
      return;
    }

    setState(() {
      connectingBuyer = buyerName;
    });

    try {
      // ========================================================
      // CHECK IF ALREADY CONNECTED
      // ========================================================

      final existing = await supabase
          .from('connections')
          .select('id')
          .eq('artisan_id', user.id)
          .eq('buyer_name', buyerName)
          .maybeSingle();

      if (existing != null) {
        if (mounted) {
          setState(() {
            connectingBuyer = null;
          });

          showAlreadyConnectedDialog(
            context,
            buyerName,
          );
        }

        return;
      }

      // ========================================================
      // INSERT CONNECTION
      // ========================================================

      await supabase.from('connections').insert({
        'artisan_id': user.id,
        'buyer_name': buyerName,
        'buyer_category': widget.marketTitle,
        'buyer_location': location,
        'status': 'pending',
      });

      if (!mounted) return;

      setState(() {
        connectingBuyer = null;
      });

      // ========================================================
      // SUCCESS
      // ========================================================

      showConnectionDialog(
        context,
        buyerName,
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;

      setState(() {
        connectingBuyer = null;
      });

      showError(
        context,
        error.message,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        connectingBuyer = null;
      });

      showError(
        context,
        t('something_wrong'),
      );
    }
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: const Color(0xFF8B4513),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D2E0C),
                  ),
                ),

                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Color(0xFF6D4C41),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void showConnectionDialog(
    BuildContext context,
    String buyerName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFFFFF8F0),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF8B4513),
                size: 30,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  t('connection_request_sent'),
                  style: const TextStyle(
                    color: Color(0xFF5D2E0C),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: Text(
            '${t('interest_recorded')} $buyerName. '
            '${t('buyer_can_contact')}',
            style: const TextStyle(
              color: Color(0xFF6D4C41),
              height: 1.5,
            ),
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF8B4513),
                foregroundColor:
                    Colors.white,
              ),

              child: Text(
                t('done'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ALREADY CONNECTED DIALOG
  // ============================================================

  void showAlreadyConnectedDialog(
    BuildContext context,
    String buyerName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFFFFF8F0),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF8B4513),
                size: 30,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  t('already_connected'),
                  style: const TextStyle(
                    color: Color(0xFF5D2E0C),
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: Text(
            t('already_connected_message')
                .replaceAll(
              '{buyer}',
              buyerName,
            ),
            style: const TextStyle(
              color: Color(0xFF6D4C41),
              height: 1.5,
            ),
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF8B4513),
                foregroundColor:
                    Colors.white,
              ),

              child: Text(
                t('ok'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            const Color(0xFF8B4513),
      ),
    );
  }
}