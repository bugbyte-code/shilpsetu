import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../translations.dart';
import 'product_details_screen.dart';

class Product {
  String? id;

  String name;
  String category;
  String description;
  String price;

  // ==========================================================
  // MULTILINGUAL DESCRIPTIONS
  // ==========================================================
  String? nameEn;
  String? nameHi;
  String? nameTe;

  String? descriptionEn;
  String? descriptionHi;
  String? descriptionTe;

  String? categoryEn;
  String? categoryHi;
  String? categoryTe;


  // ==========================================================
  // STORAGE IMAGE PATH
  // ==========================================================

  String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.nameEn,
    this.nameHi,
    this.nameTe,
    this.categoryEn,
    this.categoryHi,
    this.categoryTe,
    this.descriptionEn,
    this.descriptionHi,
    this.descriptionTe,
    this.imagePath,
  });
}

// ============================================================
// SAVED PRODUCTS
// ============================================================

List<Product> savedProducts = [];

// ============================================================
// PRODUCTS SCREEN
// ============================================================

class ProductsScreen extends StatefulWidget {
  final String selectedLanguage;

  const ProductsScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isLoading = true;

  // ==========================================================
  // TRANSLATION
  // ==========================================================

  String t(String key) {
    return AppTranslations.get(
      widget.selectedLanguage,
      key,
    );
  }

  // ==========================================================
  // CATEGORY TRANSLATION
  // ==========================================================

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

  // ==========================================================
  // LOCALIZED DESCRIPTION
  // ==========================================================

  String getLocalizedDescription(Product product) {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        if (product.descriptionHi != null &&
            product.descriptionHi!.trim().isNotEmpty) {
          return product.descriptionHi!;
        }

        return product.description;

      case 'Telugu':
        if (product.descriptionTe != null &&
            product.descriptionTe!.trim().isNotEmpty) {
          return product.descriptionTe!;
        }

        return product.description;

      case 'English':
      default:
        if (product.descriptionEn != null &&
            product.descriptionEn!.trim().isNotEmpty) {
          return product.descriptionEn!;
        }

        return product.description;
    }
  }

  // ==========================================================
  // LOAD PRODUCTS FROM SUPABASE
  // ==========================================================

  Future<void> loadProducts() async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {
      final response =
          await Supabase.instance.client
              .from('products')
              .select()
              .eq('user_id', user.id)
              .order(
                'created_at',
                ascending: false,
              );

      final List<Product> products =
          response.map<Product>((item) {
        return Product(
          id: item['id']?.toString(),

          // ==================================================
          // PRODUCT NAME
          // ==================================================

          name:
              item['name']?.toString() ?? '',

          // ==================================================
          // CATEGORY
          // ==================================================

          category:
              item['category']?.toString() ??
                  'Handicraft',

          // ==================================================
          // ORIGINAL DESCRIPTION
          // ==================================================

          description:
              item['description']?.toString() ??
                  '',

          // ==================================================
          // ENGLISH DESCRIPTION
          // ==================================================

          descriptionEn:
              item['description_en']?.toString(),

          // ==================================================
          // HINDI DESCRIPTION
          // ==================================================

          descriptionHi:
              item['description_hi']?.toString(),

          // ==================================================
          // TELUGU DESCRIPTION
          // ==================================================

          descriptionTe:
              item['description_te']?.toString(),

          // ==================================================
          // PRICE
          // ==================================================

          price:
              formatPrice(item['price']),

          // ==================================================
          // IMAGE PATH
          // ==================================================

          imagePath:
              item['image_url']?.toString(),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        savedProducts = products;
        isLoading = false;
      });
    }

    // ========================================================
    // DATABASE ERROR
    // ========================================================

    on PostgrestException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load products: ${e.message}',
          ),
        ),
      );
    }

    // ========================================================
    // OTHER ERROR
    // ========================================================

    catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong while loading products.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // FORMAT PRICE
  // ==========================================================

  String formatPrice(dynamic price) {
    if (price == null) {
      return '₹0';
    }

    final double? value =
        double.tryParse(
      price.toString(),
    );

    if (value == null) {
      return '₹$price';
    }

    if (value == value.roundToDouble()) {
      return '₹${value.toInt()}';
    }

    return '₹${value.toStringAsFixed(2)}';
  }

  // ==========================================================
  // CREATE SIGNED IMAGE URL
  // ==========================================================

  Future<String?> getImageUrl(
    String? imagePath,
  ) async {
    if (imagePath == null ||
        imagePath.trim().isEmpty) {
      return null;
    }

    try {
      final String signedUrl =
          await Supabase.instance.client
              .storage
              .from('product-images')
              .createSignedUrl(
                imagePath,
                3600,
              );

      return signedUrl;
    } catch (e) {
      return null;
    }
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  // ==========================================================
  // PRODUCT IMAGE
  // ==========================================================

  Widget buildProductImage(
    Product product,
  ) {
    // ========================================================
    // NO IMAGE
    // ========================================================

    if (product.imagePath == null ||
        product.imagePath!.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color:
              const Color(0xFFE8C39E),
          borderRadius:
              BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.handyman,
          size: 35,
          color:
              Color(0xFF8B4513),
        ),
      );
    }

    // ========================================================
    // SIGNED IMAGE URL
    // ========================================================

    return FutureBuilder<String?>(
      future: getImageUrl(
        product.imagePath,
      ),

      builder: (
        context,
        snapshot,
      ) {
        // ====================================================
        // LOADING
        // ====================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFE8C39E),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Center(
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color:
                    Color(0xFF8B4513),
              ),
            ),
          );
        }

        // ====================================================
        // IMAGE FAILED
        // ====================================================

        if (!snapshot.hasData ||
            snapshot.data == null) {
          return Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFE8C39E),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.image_not_supported,
              size: 32,
              color:
                  Color(0xFF8B4513),
            ),
          );
        }

        // ====================================================
        // ACTUAL IMAGE
        // ====================================================

        return ClipRRect(
          borderRadius:
              BorderRadius.circular(15),

          child: Image.network(
            snapshot.data!,
            width: 70,
            height: 70,
            fit: BoxFit.cover,

            errorBuilder:
                (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                width: 70,
                height: 70,
                color:
                    const Color(0xFFE8C39E),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 32,
                  color:
                      Color(0xFF8B4513),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8F0),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF8B4513),

        foregroundColor:
            Colors.white,

        title: Text(
          t('my_products'),

          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: isLoading

          // --------------------------------------------------
          // LOADING
          // --------------------------------------------------

          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF8B4513),
              ),
            )

          // --------------------------------------------------
          // EMPTY
          // --------------------------------------------------

          : savedProducts.isEmpty
              ? Center(
                  child: Text(
                    t('no_products'),

                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF5D2E0C),
                    ),
                  ),
                )

              // ------------------------------------------------
              // PRODUCTS
              // ------------------------------------------------

              : RefreshIndicator(
                  color:
                      const Color(0xFF8B4513),

                  onRefresh:
                      loadProducts,

                  child:
                      ListView.builder(
                    padding:
                        const EdgeInsets.all(20),

                    itemCount:
                        savedProducts.length,

                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final product =
                          savedProducts[index];

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                context,
                              ) =>
                                  ProductDetailsScreen(
                                product:
                                    product,
                                selectedLanguage:
                                    widget.selectedLanguage,
                              ),
                            ),
                          );

                          await loadProducts();
                        },

                        child: Container(
                          margin:
                              const EdgeInsets.only(
                            bottom: 15,
                          ),

                          padding:
                              const EdgeInsets.all(
                            18,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),

                            boxShadow:
                                const [
                              BoxShadow(
                                color:
                                    Colors.black12,
                                blurRadius:
                                    8,
                                offset:
                                    Offset(
                                  0,
                                  3,
                                ),
                              ),
                            ],
                          ),

                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              // --------------------------------
                              // PRODUCT IMAGE
                              // --------------------------------

                              buildProductImage(
                                product,
                              ),

                              const SizedBox(
                                width: 15,
                              ),

                              // --------------------------------
                              // PRODUCT DETAILS
                              // --------------------------------

                              Expanded(
                                child:
                                    Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    // ==========================
                                    // NAME
                                    // ==========================

                                    Text(
                                      product.name,

                                      maxLines:
                                          2,

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
                                            Color(
                                          0xFF5D2E0C,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    // ==========================
                                    // CATEGORY
                                    // ==========================

                                    Text(
                                      getCategoryTranslation(
                                        product.category,
                                      ),

                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF6D4C41,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    // ==========================
                                    // DESCRIPTION
                                    // ==========================

                                    Text(
                                      getLocalizedDescription(
                                        product,
                                      ),

                                      maxLines:
                                          2,

                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            13,
                                        color:
                                            Color(
                                          0xFF6D4C41,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    // ==========================
                                    // PRICE
                                    // ==========================

                                    Text(
                                      product.price,

                                      style:
                                          const TextStyle(
                                        fontSize:
                                            17,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        color:
                                            Color(
                                          0xFF8B4513,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              // --------------------------------
                              // ARROW
                              // --------------------------------

                              const Padding(
                                padding:
                                    EdgeInsets.only(
                                  top: 25,
                                ),

                                child: Icon(
                                  Icons
                                      .arrow_forward_ios,
                                  size: 18,
                                  color:
                                      Color(
                                    0xFF8B4513,
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