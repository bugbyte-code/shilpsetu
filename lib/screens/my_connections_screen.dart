import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../translations.dart';

class MyConnectionsScreen extends StatefulWidget {
  final String selectedLanguage;

  const MyConnectionsScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<MyConnectionsScreen> createState() =>
      _MyConnectionsScreenState();
}

class _MyConnectionsScreenState
    extends State<MyConnectionsScreen> {
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> connections = [];

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  @override
  void initState() {
    super.initState();
    loadConnections();
  }

  // ============================================================
  // LOAD CONNECTIONS
  // ============================================================

  Future<void> loadConnections() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
          errorMessage = t('please_login_again');
        });
        return;
      }

      final response = await supabase
          .from('connections')
          .select()
          .eq('artisan_id', user.id)
          .order(
            'created_at',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {
        connections =
            List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } on PostgrestException catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            t('something_went_wrong_try_again');
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,

        title: Text(
          t('my_connections'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: isLoading
          ? buildLoading()
          : errorMessage != null
              ? buildError()
              : connections.isEmpty
                  ? buildEmpty()
                  : RefreshIndicator(
                      color: const Color(0xFF8B4513),

                      onRefresh: loadConnections,

                      child: ListView.builder(
                        padding:
                            const EdgeInsets.all(20),

                        itemCount:
                            connections.length,

                        itemBuilder:
                            (context, index) {
                          final connection =
                              connections[index];

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 15,
                            ),

                            child: connectionCard(
                              connection,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF8B4513),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget buildEmpty() {
    return RefreshIndicator(
      color: const Color(0xFF8B4513),

      onRefresh: loadConnections,

      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(20),

        children: [

          const SizedBox(height: 100),

          Center(
            child: Container(
              padding: const EdgeInsets.all(25),

              decoration: const BoxDecoration(
                color: Color(0xFFFFE4CC),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.handshake_outlined,
                size: 55,
                color: Color(0xFF8B4513),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Text(
            t('no_connections_yet'),

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D2E0C),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            t('connections_empty_description'),

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF6D4C41),
            ),
          ),

          const SizedBox(height: 25),

          const Icon(
            Icons.arrow_downward,
            size: 28,
            color: Color(0xFF8B4513),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.error_outline,
              size: 55,
              color: Color(0xFF8B4513),
            ),

            const SizedBox(height: 15),

            Text(
              t('unable_to_load_connections'),

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D2E0C),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              errorMessage ?? '',

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Color(0xFF6D4C41),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loadConnections,

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF8B4513),

                foregroundColor: Colors.white,
              ),

              child: Text(
                t('try_again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONNECTION CARD
  // ============================================================

  Widget connectionCard(
    Map<String, dynamic> connection,
  ) {
    final String buyerName =
        connection['buyer_name'] ??
            t('unknown_buyer');

    final String category =
        connection['buyer_category'] ??
            t('business');

    final String location =
        connection['buyer_location'] ??
            t('unknown');

    final String status =
        connection['status'] ?? 'pending';

    final String createdAt =
        formatDate(connection['created_at']);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // ====================================================
          // HEADER
          // ====================================================

          Row(
            children: [

              Container(
                padding:
                    const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFFE4CC),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.business,
                  size: 30,
                  color: Color(0xFF8B4513),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  buyerName,

                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF5D2E0C),
                  ),
                ),
              ),

              statusBadge(status),
            ],
          ),

          const SizedBox(height: 20),

          // ====================================================
          // CATEGORY
          // ====================================================

          infoRow(
            Icons.category_outlined,
            t('category'),
            category,
          ),

          const SizedBox(height: 12),

          // ====================================================
          // LOCATION
          // ====================================================

          infoRow(
            Icons.location_on_outlined,
            t('location'),
            location,
          ),

          const SizedBox(height: 12),

          // ====================================================
          // DATE
          // ====================================================

          infoRow(
            Icons.calendar_today_outlined,
            t('connected'),
            createdAt,
          ),

          const SizedBox(height: 18),

          // ====================================================
          // DIVIDER
          // ====================================================

          const Divider(
            color: Color(0xFFE8D5C4),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // STATUS MESSAGE
          // ====================================================

          Row(
            children: [

              Icon(
                status.toLowerCase() ==
                        'accepted'
                    ? Icons
                        .check_circle_outline
                    : status.toLowerCase() ==
                            'rejected'
                        ? Icons.cancel_outlined
                        : Icons.hourglass_empty,

                size: 20,

                color:
                    const Color(0xFF8B4513),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  getStatusMessage(status),

                  style:
                      const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF6D4C41),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget statusBadge(String status) {
    String displayStatus;

    if (status.toLowerCase() ==
        'accepted') {
      displayStatus = t('accepted');
    } else if (status.toLowerCase() ==
        'rejected') {
      displayStatus = t('rejected');
    } else {
      displayStatus = t('pending');
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFFFE4CC),
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        displayStatus,

        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS MESSAGE
  // ============================================================

  String getStatusMessage(String status) {
    if (status.toLowerCase() ==
        'accepted') {
      return t('connection_accepted');
    }

    if (status.toLowerCase() ==
        'rejected') {
      return t('connection_rejected');
    }

    return t('connection_pending');
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
          size: 20,
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
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF5D2E0C),
                  ),
                ),

                TextSpan(
                  text: value,

                  style: const TextStyle(
                    color:
                        Color(0xFF6D4C41),
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
  // DATE FORMAT
  // ============================================================

  String formatDate(dynamic value) {
    if (value == null) {
      return t('unknown');
    }

    try {
      final date =
          DateTime.parse(
        value.toString(),
      );

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return t('unknown');
    }
  }
}