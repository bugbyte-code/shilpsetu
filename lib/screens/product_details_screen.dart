import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'products_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String selectedLanguage;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.selectedLanguage,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isDeleting = false;
  bool isEditing = false;
  bool isSaving = false;

  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;

  // ------------------------------------------------------------
  // LOCALIZED PRODUCT DATA
  // ------------------------------------------------------------

  String getLocalizedName() {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        if (widget.product.nameHi != null &&
            widget.product.nameHi!.trim().isNotEmpty) {
          return widget.product.nameHi!;
        }
        return widget.product.name;

      case 'Telugu':
        if (widget.product.nameTe != null &&
            widget.product.nameTe!.trim().isNotEmpty) {
          return widget.product.nameTe!;
        }
        return widget.product.name;

      case 'English':
      default:
        if (widget.product.nameEn != null &&
            widget.product.nameEn!.trim().isNotEmpty) {
          return widget.product.nameEn!;
        }
        return widget.product.name;
    }
  }

  String getLocalizedDescription() {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        if (widget.product.descriptionHi != null &&
            widget.product.descriptionHi!.trim().isNotEmpty) {
          return widget.product.descriptionHi!;
        }
        return widget.product.description;

      case 'Telugu':
        if (widget.product.descriptionTe != null &&
            widget.product.descriptionTe!.trim().isNotEmpty) {
          return widget.product.descriptionTe!;
        }
        return widget.product.description;

      case 'English':
      default:
        if (widget.product.descriptionEn != null &&
            widget.product.descriptionEn!.trim().isNotEmpty) {
          return widget.product.descriptionEn!;
        }
        return widget.product.description;
    }
  }

  String getLocalizedCategory() {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        if (widget.product.categoryHi != null &&
            widget.product.categoryHi!.trim().isNotEmpty) {
          return widget.product.categoryHi!;
        }
        return widget.product.category;

      case 'Telugu':
        if (widget.product.categoryTe != null &&
            widget.product.categoryTe!.trim().isNotEmpty) {
          return widget.product.categoryTe!;
        }
        return widget.product.category;

      case 'English':
      default:
        if (widget.product.categoryEn != null &&
            widget.product.categoryEn!.trim().isNotEmpty) {
          return widget.product.categoryEn!;
        }
        return widget.product.category;
    }
  }

  // ------------------------------------------------------------
  // TRANSLATED UI LABELS
  // ------------------------------------------------------------

  String get pageTitle {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'उत्पाद विवरण';
      case 'Telugu':
        return 'ఉత్పత్తి వివరాలు';
      default:
        return 'Product Details';
    }
  }

  String get priceLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'कीमत';
      case 'Telugu':
        return 'ధర';
      default:
        return 'Price';
    }
  }

  String get descriptionLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'विवरण';
      case 'Telugu':
        return 'వివరణ';
      default:
        return 'Description';
    }
  }

  String get editProductLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'उत्पाद संपादित करें';
      case 'Telugu':
        return 'ఉత్పత్తిని సవరించండి';
      default:
        return 'Edit Product';
    }
  }

  String get deleteProductLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'उत्पाद हटाएं';
      case 'Telugu':
        return 'ఉత్పత్తిని తొలగించండి';
      default:
        return 'Delete Product';
    }
  }

  String get deleteTitle {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'उत्पाद हटाएं?';
      case 'Telugu':
        return 'ఉత్పత్తిని తొలగించాలా?';
      default:
        return 'Delete Product?';
    }
  }

  String get deleteMessage {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'क्या आप वाकई इस उत्पाद को हटाना चाहते हैं? '
            'यह कार्रवाई पूर्ववत नहीं की जा सकती।';

      case 'Telugu':
        return 'మీరు ఈ ఉత్పత్తిని ఖచ్చితంగా తొలగించాలనుకుంటున్నారా? '
            'ఈ చర్యను రద్దు చేయడం సాధ్యం కాదు.';

      default:
        return 'Are you sure you want to delete this product? '
            'This action cannot be undone.';
    }
  }

  String get cancelLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'रद्द करें';
      case 'Telugu':
        return 'రద్దు';
      default:
        return 'Cancel';
    }
  }

  String get deleteLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'हटाएं';
      case 'Telugu':
        return 'తొలగించు';
      default:
        return 'Delete';
    }
  }

  String get saveChangesLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'परिवर्तन सहेजें';
      case 'Telugu':
        return 'మార్పులను సేవ్ చేయండి';
      default:
        return 'Save Changes';
    }
  }

  String get productNameLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'उत्पाद का नाम';
      case 'Telugu':
        return 'ఉత్పత్తి పేరు';
      default:
        return 'Product Name';
    }
  }

  String get categoryLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'श्रेणी';
      case 'Telugu':
        return 'వర్గం';
      default:
        return 'Category';
    }
  }

  String get noDescriptionLabel {
    switch (widget.selectedLanguage) {
      case 'Hindi':
        return 'कोई विवरण उपलब्ध नहीं है।';
      case 'Telugu':
        return 'వివరణ అందుబాటులో లేదు.';
      default:
        return 'No description available.';
    }
  }

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: getLocalizedName(),
    );

    categoryController = TextEditingController(
      text: getLocalizedCategory(),
    );

    descriptionController = TextEditingController(
      text: getLocalizedDescription(),
    );

    priceController = TextEditingController(
      text: widget.product.price,
    );
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    priceController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // GET SIGNED IMAGE URL
  // ------------------------------------------------------------

  Future<String?> getImageUrl() async {
    if (widget.product.imagePath == null ||
        widget.product.imagePath!.isEmpty) {
      return null;
    }

    try {
      final url = await Supabase.instance.client
          .storage
          .from('product-images')
          .createSignedUrl(
            widget.product.imagePath!,
            3600,
          );

      return url;
    } catch (e) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // EDIT PRODUCT
  // ------------------------------------------------------------

  void editProduct() {
    setState(() {
      isEditing = true;

      nameController.text = getLocalizedName();
      categoryController.text = getLocalizedCategory();
      descriptionController.text = getLocalizedDescription();
      priceController.text = widget.product.price;
    });
  }

  // ------------------------------------------------------------
  // SAVE EDITED PRODUCT
  // ------------------------------------------------------------

  Future<void> saveEditedProduct() async {
    if (widget.product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product ID not found'),
        ),
      );
      return;
    }

    final name = nameController.text.trim();
    final category = categoryController.text.trim();
    final description = descriptionController.text.trim();
    final priceText = priceController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$productNameLabel cannot be empty'),
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);

    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final Map<String, dynamic> updateData = {
        'price': price,
      };

      // --------------------------------------------------------
      // UPDATE CORRESPONDING LANGUAGE FIELD
      // --------------------------------------------------------

      if (widget.selectedLanguage == 'Hindi') {
        updateData['name_hi'] = name;
        updateData['category_hi'] = category;
        updateData['description_hi'] = description;
      } else if (widget.selectedLanguage == 'Telugu') {
        updateData['name_te'] = name;
        updateData['category_te'] = category;
        updateData['description_te'] = description;
      } else {
        updateData['name_en'] = name;
        updateData['category_en'] = category;
        updateData['description_en'] = description;
      }

      // Keep original fields updated as well
      updateData['name'] = name;
      updateData['category'] = category;
      updateData['description'] = description;

      await Supabase.instance.client
          .from('products')
          .update(updateData)
          .eq('id', widget.product.id!);

      // --------------------------------------------------------
      // UPDATE LOCAL PRODUCT
      // --------------------------------------------------------

      widget.product.name = name;
      widget.product.category = category;
      widget.product.description = description;
      widget.product.price = price.toStringAsFixed(0);

      if (widget.selectedLanguage == 'Hindi') {
        widget.product.nameHi = name;
        widget.product.categoryHi = category;
        widget.product.descriptionHi = description;
      } else if (widget.selectedLanguage == 'Telugu') {
        widget.product.nameTe = name;
        widget.product.categoryTe = category;
        widget.product.descriptionTe = description;
      } else {
        widget.product.nameEn = name;
        widget.product.categoryEn = category;
        widget.product.descriptionEn = description;
      }

      if (!mounted) return;

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully'),
        ),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: ${e.message}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
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

  // ------------------------------------------------------------
  // DELETE PRODUCT
  // ------------------------------------------------------------

  Future<void> deleteProduct() async {
    if (widget.product.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product ID not found'),
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            deleteTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D2E0C),
            ),
          ),
          content: Text(deleteMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                cancelLabel,
                style: const TextStyle(
                  color: Color(0xFF8B4513),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(deleteLabel),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      isDeleting = true;
    });

    try {
      // --------------------------------------------------------
      // DELETE IMAGE
      // --------------------------------------------------------

      if (widget.product.imagePath != null &&
          widget.product.imagePath!.isNotEmpty) {
        try {
          await Supabase.instance.client
              .storage
              .from('product-images')
              .remove([
            widget.product.imagePath!,
          ]);
        } catch (e) {
          // Continue deleting database record
        }
      }

      // --------------------------------------------------------
      // DELETE DATABASE RECORD
      // --------------------------------------------------------

      await Supabase.instance.client
          .from('products')
          .delete()
          .eq('id', widget.product.id!);

      // --------------------------------------------------------
      // REMOVE LOCAL PRODUCT
      // --------------------------------------------------------

      savedProducts.removeWhere(
        (product) => product.id == widget.product.id,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
        ),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: ${e.message}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // PRODUCT IMAGE
  // ------------------------------------------------------------

  Widget buildProductImage() {
    if (widget.product.imagePath == null ||
        widget.product.imagePath!.isEmpty) {
      return Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE8C39E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.image_outlined,
          size: 70,
          color: Color(0xFF8B4513),
        ),
      );
    }

    return FutureBuilder<String?>(
      future: getImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8C39E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B4513),
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null) {
          return Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8C39E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 60,
              color: Color(0xFF8B4513),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            snapshot.data!,
            height: 230,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) {
              return Container(
                height: 230,
                width: double.infinity,
                color: const Color(0xFFE8C39E),
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 60,
                  color: Color(0xFF8B4513),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // EDIT FIELD
  // ------------------------------------------------------------

  Widget buildEditField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF8B4513),
          ),
          filled: true,
          fillColor: const Color(0xFFFFF8F0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE8C39E),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF8B4513),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,

        title: Text(
          pageTitle,
          style: const TextStyle(
            color: Color(0xFF5D2E0C),
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xFF5D2E0C),
        ),

        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
              ),
              onPressed: editProduct,
            ),

          if (!isEditing)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed:
                  isDeleting ? null : deleteProduct,
            ),
        ],
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ----------------------------------------------------
            // IMAGE
            // ----------------------------------------------------

            buildProductImage(),

            const SizedBox(height: 24),

            // ----------------------------------------------------
            // EDIT MODE
            // ----------------------------------------------------

            if (isEditing) ...[
              buildEditField(
                productNameLabel,
                nameController,
              ),

              buildEditField(
                categoryLabel,
                categoryController,
              ),

              buildEditField(
                priceLabel,
                priceController,
                keyboardType:
                    TextInputType.number,
              ),

              buildEditField(
                descriptionLabel,
                descriptionController,
                maxLines: 5,
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  // CANCEL
                  Expanded(
                    child: OutlinedButton(
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(
                                0xFF8B4513),
                        side:
                            const BorderSide(
                          color:
                              Color(0xFF8B4513),
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      14),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () {
                              setState(() {
                                isEditing =
                                    false;

                                nameController
                                        .text =
                                    getLocalizedName();

                                categoryController
                                        .text =
                                    getLocalizedCategory();

                                descriptionController
                                        .text =
                                    getLocalizedDescription();

                                priceController
                                        .text =
                                    widget.product
                                        .price;
                              });
                            },
                      child: Text(
                        cancelLabel,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // SAVE
                  Expanded(
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF8B4513),
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      14),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : saveEditedProduct,
                      child: isSaving
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
                          : Text(
                              saveChangesLabel,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ]

            // ----------------------------------------------------
            // NORMAL MODE
            // ----------------------------------------------------

            else ...[
              // PRODUCT NAME
              Text(
                getLocalizedName(),
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D2E0C),
                ),
              ),

              const SizedBox(height: 10),

              // CATEGORY
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFFE4CC),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  getLocalizedCategory(),
                  style: const TextStyle(
                    color:
                        Color(0xFF8B4513),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // PRICE CARD
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(
                              12),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                                0xFFFFE4CC),
                        borderRadius:
                            BorderRadius
                                .circular(12),
                      ),
                      child: const Icon(
                        Icons.currency_rupee,
                        color:
                            Color(0xFF8B4513),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          priceLabel,
                          style:
                              const TextStyle(
                            color:
                                Color(
                                    0xFF6D4C41),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          '₹${widget.product.price}',
                          style:
                              const TextStyle(
                            fontSize: 23,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                Color(
                                    0xFF5D2E0C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // DESCRIPTION
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      descriptionLabel,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF5D2E0C),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      getLocalizedDescription()
                              .isEmpty
                          ? noDescriptionLabel
                          : getLocalizedDescription(),
                      style:
                          const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color:
                            Color(0xFF6D4C41),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ------------------------------------------------
              // EDIT BUTTON
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                            0xFF8B4513),
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 15,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(14),
                    ),
                  ),
                  onPressed: editProduct,
                  icon:
                      const Icon(Icons.edit),
                  label: Text(
                    editProductLabel,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // DELETE BUTTON
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                child:
                    OutlinedButton.icon(
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        Colors.red,
                    side:
                        const BorderSide(
                      color: Colors.red,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 15,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(14),
                    ),
                  ),
                  onPressed: isDeleting
                      ? null
                      : deleteProduct,

                  icon: isDeleting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : const Icon(
                          Icons
                              .delete_outline,
                        ),

                  label: Text(
                    deleteProductLabel,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}