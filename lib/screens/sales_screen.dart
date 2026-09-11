import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'products_screen.dart';
import '../translations.dart';

// ============================================================
// SALE MODEL
// ============================================================

class Sale {
  final String? id;
  final Product product;
  final int quantity;
  final double pricePerItem;
  final String customerName;
  final DateTime date;

  Sale({
    this.id,
    required this.product,
    required this.quantity,
    required this.pricePerItem,
    required this.customerName,
    required this.date,
  });

  double get totalAmount => quantity * pricePerItem;
}

// ============================================================
// SAVED SALES
// ============================================================

List<Sale> savedSales = [];

// ============================================================
// SALES SCREEN
// ============================================================

class SalesScreen extends StatefulWidget {
  final String selectedLanguage;

  const SalesScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  static const Color backgroundColor = Color(0xFFFFF8F0);
  static const Color primaryColor = Color(0xFF8B4513);
  static const Color darkTextColor = Color(0xFF5D2E0C);
  static const Color lightTextColor = Color(0xFF6D4C41);

  bool isLoading = true;

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  // ==========================================================
  // LOAD SALES FROM SUPABASE
  // ==========================================================

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('sales')
          .select()
          .eq('user_id', user.id)
          .order('sale_date', ascending: false);

      final List<Sale> loadedSales = [];

      for (final item in response) {
        Product product = Product(
          id: item['product_id'],
          name: item['product_name'] ?? 'Product',
          category: '',
          description: '',
          price: item['selling_price']?.toString() ?? '0',
        );

        loadedSales.add(
          Sale(
            id: item['id'],
            product: product,
            quantity: item['quantity'] ?? 0,
            pricePerItem:
                double.tryParse(
                      item['selling_price']?.toString() ?? '0',
                    ) ??
                    0,
            customerName:
                item['customer_name'] ?? t('walk_in_customer'),
            date: DateTime.tryParse(
                  item['sale_date']?.toString() ?? '',
                ) ??
                DateTime.now(),
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        savedSales = loadedSales;
        isLoading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load sales: ${e.message}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // TOTAL REVENUE
  // ==========================================================

  double get totalRevenue {
    return savedSales.fold(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );
  }

  // ==========================================================
  // TOTAL PRODUCTS SOLD
  // ==========================================================

  int get totalProductsSold {
    return savedSales.fold(
      0,
      (sum, sale) => sum + sale.quantity,
    );
  }

  // ==========================================================
  // REFRESH SALES
  // ==========================================================

  Future<void> refreshSales() async {
    await loadSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t('sales'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : savedSales.isEmpty
              ? _emptySales()
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: refreshSales,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      40,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // SUMMARY CARDS
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.currency_rupee,
                                title: t('revenue'),
                                value:
                                    '₹${totalRevenue.toStringAsFixed(0)}',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.shopping_bag,
                                title: t('products_sold'),
                                value:
                                    '$totalProductsSold',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.receipt_long,
                                title: t('orders'),
                                value:
                                    '${savedSales.length}',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.trending_up,
                                title: t('average_order'),
                                value: savedSales.isEmpty
                                    ? '₹0'
                                    : '₹${(totalRevenue / savedSales.length).toStringAsFixed(0)}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // RECORD SALE BUTTON
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecordSaleScreen(
                                    selectedLanguage:
                                        widget.selectedLanguage,
                                  ),
                                ),
                              );

                              await loadSales();
                            },
                            icon: const Icon(
                              Icons.add_shopping_cart,
                            ),
                            label: Text(
                              t('record_new_sale').toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryColor,
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  16,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // RECENT SALES
                        // ==================================================

                        Text(
                          t('recent_sales'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkTextColor,
                          ),
                        ),

                        const SizedBox(height: 15),

                        ...savedSales.map(
                          (sale) => _saleCard(sale),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

      // ==========================================================
      // FLOATING BUTTON
      // ==========================================================

      floatingActionButton:
          !isLoading && savedSales.isEmpty
              ? FloatingActionButton.extended(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecordSaleScreen(
                          selectedLanguage:
                              widget.selectedLanguage,
                        ),
                      ),
                    );

                    await loadSales();
                  },
                  icon: const Icon(
                    Icons.add_shopping_cart,
                  ),
                  label: Text(
                    t('record_sale'),
                  ),
                )
              : null,
    );
  }

  // ==========================================================
  // EMPTY SALES SCREEN
  // ==========================================================

  Widget _emptySales() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          25,
          40,
          25,
          100,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height - 150,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bar_chart,
                  size: 80,
                  color: primaryColor,
                ),

                const SizedBox(height: 20),

                Text(
                  t('no_sales'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  t('no_sales_description'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: lightTextColor,
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecordSaleScreen(
                          selectedLanguage:
                              widget.selectedLanguage,
                        ),
                      ),
                    );

                    await loadSales();
                  },
                  icon: const Icon(
                    Icons.add_shopping_cart,
                  ),
                  label: Text(
                    t('record_first_sale')
                        .toUpperCase(),
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      height: 115,
      padding: const EdgeInsets.all(12),
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
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: primaryColor,
          ),

          const SizedBox(height: 7),

          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: lightTextColor,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SALE CARD
  // ==========================================================

  Widget _saleCard(Sale sale) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE8C39E),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.shopping_bag,
              size: 30,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  sale.product.name,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${t('customer')}: ${sale.customerName}',
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: lightTextColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${t('quantity')}: ${sale.quantity}',
                  style: const TextStyle(
                    color: lightTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '₹${sale.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RECORD SALE SCREEN
// ============================================================

class RecordSaleScreen extends StatefulWidget {
  final String selectedLanguage;

  const RecordSaleScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<RecordSaleScreen> createState() =>
      _RecordSaleScreenState();
}

class _RecordSaleScreenState
    extends State<RecordSaleScreen> {

  static const Color backgroundColor =
      Color(0xFFFFF8F0);

  static const Color primaryColor =
      Color(0xFF8B4513);

  static const Color darkTextColor =
      Color(0xFF5D2E0C);

  static const Color lightTextColor =
      Color(0xFF6D4C41);

  static const Color cardColor =
      Color(0xFFFFE4CC);

  Product? selectedProduct;

  final TextEditingController
      quantityController =
      TextEditingController(text: '1');

  final TextEditingController
      customerController =
      TextEditingController();

  bool isSaving = false;

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    customerController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SAVE SALE TO SUPABASE
  // ==========================================================

  Future<void> saveSale() async {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('select_product_error'),
          ),
        ),
      );
      return;
    }

    final quantity =
        int.tryParse(
              quantityController.text.trim(),
            ) ??
            0;

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('valid_quantity_error'),
          ),
        ),
      );
      return;
    }

    final price =
        double.tryParse(
              selectedProduct!.price
                  .replaceAll('₹', '')
                  .replaceAll(',', '')
                  .trim(),
            ) ??
            0;

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('set_price_error'),
          ),
        ),
      );
      return;
    }

    String customerName =
        customerController.text.trim();

    if (customerName.isEmpty) {
      customerName =
          t('walk_in_customer');
    }

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login again.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // ========================================================
      // INSERT SALE
      // ========================================================

      await Supabase.instance.client
          .from('sales')
          .insert({
        'user_id': user.id,
        'product_id': selectedProduct!.id,
        'product_name': selectedProduct!.name,
        'customer_name': customerName,
        'quantity': quantity,
        'selling_price': price,
        'total_amount': quantity * price,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('sale_recorded'),
          ),
        ),
      );

      Navigator.pop(context);
    } on PostgrestException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to record sale: ${e.message}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          t('record_sale'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            40,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PRODUCT
              // ==================================================

              Text(
                t('select_product'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 12),

              if (savedProducts.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: Text(
                    t('no_products_available'),
                    style:
                        const TextStyle(
                      color: darkTextColor,
                      fontSize: 15,
                    ),
                  ),
                )
              else
                DropdownButtonFormField<Product>(
                  initialValue: selectedProduct,
                  isExpanded: true,
                  decoration:
                      InputDecoration(
                    filled: true,
                    fillColor:
                        Colors.white,
                    prefixIcon:
                        const Icon(
                      Icons.inventory_2,
                      color:
                          primaryColor,
                    ),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(15),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                  hint: Text(
                    t('choose_product'),
                  ),
                  items:
                      savedProducts.map(
                    (product) {
                      return DropdownMenuItem<
                          Product>(
                        value: product,
                        child: Text(
                          product.name,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged:
                      (product) {
                    setState(() {
                      selectedProduct =
                          product;
                    });
                  },
                ),

              const SizedBox(height: 25),

              // ==================================================
              // QUANTITY
              // ==================================================

              Text(
                t('quantity_sold'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller:
                    quantityController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    InputDecoration(
                  hintText:
                      t('quantity_hint'),
                  filled: true,
                  fillColor:
                      Colors.white,
                  prefixIcon:
                      const Icon(
                    Icons.shopping_cart,
                    color:
                        primaryColor,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(15),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // CUSTOMER
              // ==================================================

              Text(
                t('customer_name'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                  color: darkTextColor,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller:
                    customerController,
                decoration:
                    InputDecoration(
                  hintText:
                      t('customer_name_hint'),
                  filled: true,
                  fillColor:
                      Colors.white,
                  prefixIcon:
                      const Icon(
                    Icons.person,
                    color:
                        primaryColor,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(15),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // PRICE PREVIEW
              // ==================================================

              if (selectedProduct != null)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(18),
                  decoration:
                      BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('selling_price'),
                        style:
                            const TextStyle(
                          color:
                              lightTextColor,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        selectedProduct!
                                .price
                                .isEmpty
                            ? t(
                                'price_not_set',
                              )
                            : selectedProduct!
                                .price,
                        style:
                            const TextStyle(
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              primaryColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (quantityController
                          .text
                          .isNotEmpty)
                        Text(
                          'Total: ₹${_calculateTotal()}',
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                darkTextColor,
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // ==================================================
              // SAVE SALE
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      savedProducts
                                  .isEmpty ||
                              isSaving
                          ? null
                          : saveSale,
                  icon: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle,
                        ),
                  label: Text(
                    isSaving
                        ? 'Saving...'
                        : t('save_sale')
                            .toUpperCase(),
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CALCULATE TOTAL
  // ==========================================================

  String _calculateTotal() {
    if (selectedProduct == null) {
      return '0';
    }

    final quantity =
        int.tryParse(
              quantityController.text,
            ) ??
            0;

    final price =
        double.tryParse(
              selectedProduct!.price
                  .replaceAll('₹', '')
                  .replaceAll(',', '')
                  .trim(),
            ) ??
            0;

    return (quantity * price)
        .toStringAsFixed(0);
  }
}