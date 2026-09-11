import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../translations.dart';
import 'products_screen.dart';

class PricingScreen extends StatefulWidget {
  final String selectedLanguage;

  const PricingScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool isLoadingProducts = true;
  String? errorMessage;

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  String getCategoryTranslation(String category) {
    switch (category) {
      case 'Handicraft':
        return t('handicraft');
      case 'Textile':
        return t('textile');
      case 'Jewellery':
        return t('jewellery');
      case 'Pottery':
        return t('pottery');
      case 'Woodwork':
        return t('woodwork');
      default:
        return category;
    }
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // ============================================================
  // LOAD PRODUCTS FROM SUPABASE
  // ============================================================

  Future<void> loadProducts() async {
    setState(() {
      isLoadingProducts = true;
      errorMessage = null;
    });

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoadingProducts = false;
        errorMessage = t('please_login_again');
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final products = (response as List).map((item) {
        return Product(
          id: item['id']?.toString(),
          name: item['name']?.toString() ?? '',
          category: item['category']?.toString() ?? 'Handicraft',
          description: item['description']?.toString() ?? '',
          price: item['price'] == null
              ? ''
              : '₹${item['price'].toString()}',
          imagePath: item['image_url']?.toString(),
        );
      }).toList();

      savedProducts
        ..clear()
        ..addAll(products);

      if (!mounted) return;

      setState(() {
        isLoadingProducts = false;
      });
    } on PostgrestException catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingProducts = false;
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingProducts = false;
        errorMessage = t('something_wrong');
      });
    }
  }

  // ============================================================
  // GET PRIVATE SUPABASE IMAGE URL
  // ============================================================

  Future<String?> getImageUrl(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      return await Supabase.instance.client
          .storage
          .from('product-images')
          .createSignedUrl(
            imagePath,
            3600,
          );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // PRODUCT IMAGE
  // ============================================================

  Widget productImage(Product product) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFFE8C39E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: product.imagePath == null ||
                product.imagePath!.isEmpty
            ? const Icon(
                Icons.handyman,
                size: 32,
                color: primaryColor,
              )
            : FutureBuilder<String?>(
                future: getImageUrl(product.imagePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.isNotEmpty) {
                    return Image.network(
                      snapshot.data!,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.handyman,
                          size: 32,
                          color: primaryColor,
                        );
                      },
                    );
                  }

                  return const Icon(
                    Icons.handyman,
                    size: 32,
                    color: primaryColor,
                  );
                },
              ),
      ),
    );
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
          t('ai_pricing'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoadingProducts
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: primaryColor,
                        ),

                        const SizedBox(height: 15),

                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: darkTextColor,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: loadProducts,
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
                                      15),
                            ),
                          ),
                          child: Text(
                            t('retry'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : savedProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(25),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 70,
                              color: primaryColor,
                            ),

                            const SizedBox(height: 20),

                            Text(
                              t('no_products'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    darkTextColor,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              t(
                                'pricing_no_product_message',
                              ),
                              textAlign:
                                  TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color:
                                    lightTextColor,
                              ),
                            ),

                            const SizedBox(height: 25),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                    context);
                              },
                              style: ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                    primaryColor,
                                foregroundColor:
                                    Colors.white,
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 25,
                                  vertical: 14,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              15),
                                ),
                              ),
                              child: Text(
                                t('go_back'),
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: primaryColor,
                      onRefresh: loadProducts,
                      child: ListView(
                        padding:
                            const EdgeInsets.all(20),
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.all(18),
                            decoration:
                                BoxDecoration(
                              color: cardColor,
                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  size: 35,
                                  color: primaryColor,
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Text(
                                    t(
                                      'pricing_assistant',
                                    ),
                                    style:
                                        const TextStyle(
                                      fontSize: 15,
                                      color:
                                          darkTextColor,
                                      fontWeight:
                                          FontWeight
                                              .w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          Text(
                            t('select_product'),
                            style:
                                const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  darkTextColor,
                            ),
                          ),

                          const SizedBox(height: 15),

                          ...savedProducts.map(
                            (product) =>
                                GestureDetector(
                              onTap: () async {
                                final result =
                                    await Navigator
                                        .push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            PricingInputScreen(
                                      product:
                                          product,
                                      selectedLanguage:
                                          widget
                                              .selectedLanguage,
                                    ),
                                  ),
                                );

                                // Reload from Supabase
                                // after returning.
                                if (result == true &&
                                    mounted) {
                                  await loadProducts();
                                }
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 15,
                                ),
                                padding:
                                    const EdgeInsets
                                        .all(18),
                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              20),
                                  boxShadow:
                                      const [
                                    BoxShadow(
                                      color:
                                          Colors.black12,
                                      blurRadius: 8,
                                      offset:
                                          Offset(
                                              0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    productImage(
                                        product),

                                    const SizedBox(
                                        width: 15),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  18,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  darkTextColor,
                                            ),
                                          ),

                                          const SizedBox(
                                              height: 5),

                                          Text(
                                            getCategoryTranslation(
                                              product
                                                  .category,
                                            ),
                                            style:
                                                const TextStyle(
                                              color:
                                                  lightTextColor,
                                            ),
                                          ),

                                          const SizedBox(
                                              height: 5),

                                          Text(
                                            product.price
                                                    .isEmpty
                                                ? t(
                                                    'price_not_set')
                                                : product
                                                    .price,
                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  16,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Icon(
                                      Icons
                                          .arrow_forward_ios,
                                      size: 18,
                                      color:
                                          primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}


// ============================================================
// PRICING INPUT SCREEN
// ============================================================

class PricingInputScreen extends StatefulWidget {
  final Product product;
  final String selectedLanguage;

  const PricingInputScreen({
    super.key,
    required this.product,
    required this.selectedLanguage,
  });

  @override
  State<PricingInputScreen> createState() =>
      _PricingInputScreenState();
}

class _PricingInputScreenState
    extends State<PricingInputScreen> {
  final TextEditingController materialController =
      TextEditingController();

  final TextEditingController labourController =
      TextEditingController();

  final TextEditingController packagingController =
      TextEditingController();

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  String getCategoryTranslation(String category) {
    switch (category) {
      case 'Handicraft':
        return t('handicraft');
      case 'Textile':
        return t('textile');
      case 'Jewellery':
        return t('jewellery');
      case 'Pottery':
        return t('pottery');
      case 'Woodwork':
        return t('woodwork');
      default:
        return category;
    }
  }

  @override
  void dispose() {
    materialController.dispose();
    labourController.dispose();
    packagingController.dispose();
    super.dispose();
  }

  void calculatePrice() {
    final double material =
        double.tryParse(
              materialController.text.trim(),
            ) ??
            0;

    final double labour =
        double.tryParse(
              labourController.text.trim(),
            ) ??
            0;

    final double packaging =
        double.tryParse(
              packagingController.text.trim(),
            ) ??
            0;

    if (material == 0 &&
        labour == 0 &&
        packaging == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('enter_production_cost'),
          ),
        ),
      );
      return;
    }

    final double totalCost =
        material + labour + packaging;

    // AI pricing logic
    // 30% markup on production cost.
    final double suggestedPrice =
        totalCost * 1.30;

    final double profit =
        suggestedPrice - totalCost;

    final double profitMargin =
        suggestedPrice == 0
            ? 0
            : (profit / suggestedPrice) * 100;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PricingResultScreen(
          product: widget.product,
          material: material,
          labour: labour,
          packaging: packaging,
          totalCost: totalCost,
          suggestedPrice: suggestedPrice,
          profit: profit,
          profitMargin: profitMargin,
          selectedLanguage:
              widget.selectedLanguage,
        ),
      ),
    );
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
          t('enter_production_cost'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Product information
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Product image
                  _productImage(),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('product'),
                          style: const TextStyle(
                            fontSize: 14,
                            color:
                                lightTextColor,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          widget.product.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                darkTextColor,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          getCategoryTranslation(
                            widget.product.category,
                          ),
                          style:
                              const TextStyle(
                            color:
                                lightTextColor,
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
              t('production_costs'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),

            const SizedBox(height: 15),

            _costField(
              controller: materialController,
              label: t('material_cost'),
              hint: t('material_hint'),
              icon: Icons.inventory_2,
            ),

            const SizedBox(height: 15),

            _costField(
              controller: labourController,
              label: t('labour_cost'),
              hint: t('labour_hint'),
              icon: Icons.engineering,
            ),

            const SizedBox(height: 15),

            _costField(
              controller: packagingController,
              label: t('packaging_cost'),
              hint: t('packaging_hint'),
              icon: Icons.card_giftcard,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: calculatePrice,
                icon: const Icon(
                  Icons.auto_awesome,
                ),
                label: Text(
                  t('calculate_ai_price'),
                  style: const TextStyle(
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
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PRODUCT IMAGE IN INPUT SCREEN
  // ==========================================================

  Widget _productImage() {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFFE8C39E),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(15),
        child: widget.product.imagePath ==
                    null ||
                widget.product.imagePath!.isEmpty
            ? const Icon(
                Icons.handyman,
                size: 35,
                color: primaryColor,
              )
            : FutureBuilder<String?>(
                future:
                    _getProductImageUrl(),
                builder:
                    (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            primaryColor,
                      ),
                    );
                  }

                  if (snapshot.hasData &&
                      snapshot.data != null) {
                    return Image.network(
                      snapshot.data!,
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context,
                              error,
                              stackTrace) {
                        return const Icon(
                          Icons.handyman,
                          size: 35,
                          color:
                              primaryColor,
                        );
                      },
                    );
                  }

                  return const Icon(
                    Icons.handyman,
                    size: 35,
                    color: primaryColor,
                  );
                },
              ),
      ),
    );
  }

  Future<String?> _getProductImageUrl() async {
    try {
      return await Supabase.instance.client
          .storage
          .from('product-images')
          .createSignedUrl(
            widget.product.imagePath!,
            3600,
          );
    } catch (_) {
      return null;
    }
  }

  Widget _costField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: primaryColor,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}


// ============================================================
// PRICING RESULT SCREEN
// ============================================================

class PricingResultScreen
    extends StatefulWidget {
  final Product product;

  final double material;
  final double labour;
  final double packaging;

  final double totalCost;
  final double suggestedPrice;
  final double profit;
  final double profitMargin;

  final String selectedLanguage;

  const PricingResultScreen({
    super.key,
    required this.product,
    required this.material,
    required this.labour,
    required this.packaging,
    required this.totalCost,
    required this.suggestedPrice,
    required this.profit,
    required this.profitMargin,
    required this.selectedLanguage,
  });

  @override
  State<PricingResultScreen> createState() =>
      _PricingResultScreenState();
}

class _PricingResultScreenState
    extends State<PricingResultScreen> {
  bool isSaving = false;

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  // ==========================================================
  // SAVE AI PRICE TO SUPABASE
  // ==========================================================

  Future<void> savePrice() async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(t('please_login_again')),
        ),
      );

      return;
    }

    if (widget.product.id == null ||
        widget.product.id!.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(t('something_wrong')),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final double price =
          double.parse(
        widget.suggestedPrice
            .toStringAsFixed(2),
      );

      // SAVE TO SUPABASE
      await Supabase.instance.client
          .from('products')
          .update({
        'price': price,
      })
          .eq('id', widget.product.id!)
          .eq('user_id', user.id);

      // UPDATE LOCAL PRODUCT
      widget.product.price =
          '₹${price.toStringAsFixed(0)}';

      // UPDATE GLOBAL PRODUCT LIST
      final index =
          savedProducts.indexWhere(
        (item) =>
            item.id == widget.product.id,
      );

      if (index != -1) {
        savedProducts[index].price =
            '₹${price.toStringAsFixed(0)}';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            t('price_saved'),
          ),
          duration:
              const Duration(seconds: 2),
        ),
      );

      // Tell PricingScreen that the price
      // was successfully saved.
      Navigator.pop(context, true);
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(t('something_wrong')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t('ai_price_result'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),

            const SizedBox(height: 20),

            // Product image
            _resultProductImage(),

            const SizedBox(height: 20),

            // Recommended price
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius:
                    BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    t('recommended_price'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '₹${widget.suggestedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Breakdown
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
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
                  Text(
                    t('price_breakdown'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _breakdownRow(
                    t('material_cost'),
                    widget.material,
                  ),

                  _breakdownRow(
                    t('labour_cost'),
                    widget.labour,
                  ),

                  _breakdownRow(
                    t('packaging_cost'),
                    widget.packaging,
                  ),

                  const Divider(
                    height: 25,
                  ),

                  _breakdownRow(
                    t('total_production_cost'),
                    widget.totalCost,
                    bold: true,
                  ),

                  const SizedBox(height: 10),

                  _breakdownRow(
                    t('expected_profit'),
                    widget.profit,
                    bold: true,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Text(
                        t('profit_margin'),
                        style:
                            const TextStyle(
                          fontSize: 16,
                          color:
                              lightTextColor,
                        ),
                      ),

                      Text(
                        '${widget.profitMargin.toStringAsFixed(1)}%',
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // AI explanation
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: primaryColor,
                    size: 28,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      t('pricing_explanation'),
                      style:
                          const TextStyle(
                        color: darkTextColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Save
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed:
                    isSaving ? null : savePrice,
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isSaving
                      ? t('saving')
                      : t('save_price'),
                  style: const TextStyle(
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
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: isSaving
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: Text(
                t('change_costs'),
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // RESULT PRODUCT IMAGE
  // ==========================================================

  Widget _resultProductImage() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFE8C39E),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(20),
        child: widget.product.imagePath ==
                    null ||
                widget.product.imagePath!.isEmpty
            ? const Icon(
                Icons.handyman,
                size: 60,
                color: primaryColor,
              )
            : FutureBuilder<String?>(
                future:
                    _getResultImageUrl(),
                builder:
                    (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            primaryColor,
                      ),
                    );
                  }

                  if (snapshot.hasData &&
                      snapshot.data != null) {
                    return Image.network(
                      snapshot.data!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context,
                              error,
                              stackTrace) {
                        return const Icon(
                          Icons.handyman,
                          size: 60,
                          color:
                              primaryColor,
                        );
                      },
                    );
                  }

                  return const Icon(
                    Icons.handyman,
                    size: 60,
                    color: primaryColor,
                  );
                },
              ),
      ),
    );
  }

  Future<String?> _getResultImageUrl() async {
    try {
      return await Supabase.instance.client
          .storage
          .from('product-images')
          .createSignedUrl(
            widget.product.imagePath!,
            3600,
          );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // BREAKDOWN ROW
  // ==========================================================

  Widget _breakdownRow(
    String title,
    double amount, {
    bool bold = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: bold
                  ? darkTextColor
                  : lightTextColor,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// COLORS
// ============================================================

const Color backgroundColor =
    Color(0xFFFFF8F0);

const Color primaryColor =
    Color(0xFF8B4513);

const Color darkTextColor =
    Color(0xFF5D2E0C);

const Color lightTextColor =
    Color(0xFF6D4C41);

const Color cardColor =
    Color(0xFFFFE4CC);