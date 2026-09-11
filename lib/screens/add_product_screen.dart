import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../translations.dart';
import 'products_screen.dart';

class AddProductScreen extends StatefulWidget {
  final String selectedLanguage;

  const AddProductScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController productNameController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController storyController =
      TextEditingController();

  final TextEditingController tagsController =
      TextEditingController();

  final ImagePicker picker = ImagePicker();

  XFile? productImage;

  Uint8List? enhancedImageBytes;

  String selectedCategory = 'Handicraft';

  String aiPrice = '';

  String nameEn = '';
  String nameHi = '';
  String nameTe = '';

  String descriptionEn = '';
  String descriptionHi = '';
  String descriptionTe = '';

  String categoryEn = '';
  String categoryHi = '';
  String categoryTe = '';

  String storyEn = '';
  String storyHi = '';
  String storyTe = '';

  bool isAnalyzing = false;
  bool isEnhancing = false;
  bool isSaving = false;

  String? uploadedImagePath;

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
  // PICK IMAGE
  // CAMERA + GALLERY / COMPUTER
  // LANGUAGE BASED ON SELECTION
  // ==========================================================

  Future<void> pickProductImage() async {
    // --------------------------------------------------------
    // POPUP TEXT BASED ON SELECTED LANGUAGE
    // --------------------------------------------------------

    String title;
    String subtitle;

    String takePhoto;
    String takePhotoSubtitle;

    String gallery;
    String gallerySubtitle;

    String cancel;

    if (widget.selectedLanguage == 'Hindi') {
      title = 'उत्पाद की तस्वीर जोड़ें';
      subtitle =
          'अपनी उत्पाद की तस्वीर जोड़ने का तरीका चुनें';

      takePhoto = 'तस्वीर लें';
      takePhotoSubtitle = 'अपने कैमरे का उपयोग करें';

      gallery = 'गैलरी से चुनें';
      gallerySubtitle = 'पहले से मौजूद तस्वीर चुनें';

      cancel = 'रद्द करें';
    } else if (widget.selectedLanguage == 'Telugu') {
      title = 'ఉత్పత్తి ఫోటోను జోడించండి';
      subtitle =
          'మీ ఉత్పత్తి ఫోటోను ఎలా జోడించాలో ఎంచుకోండి';

      takePhoto = 'ఫోటో తీయండి';
      takePhotoSubtitle = 'మీ కెమెరాను ఉపయోగించండి';

      gallery = 'గ్యాలరీ నుండి ఎంచుకోండి';
      gallerySubtitle =
          'ఇప్పటికే ఉన్న ఫోటోను ఎంచుకోండి';

      cancel = 'రద్దు చేయండి';
    } else {
      // English
      title = 'Add Product Photo';
      subtitle =
          'Choose how you want to add your product image';

      takePhoto = 'Take Photo';
      takePhotoSubtitle = 'Use your camera';

      gallery = 'Choose from Gallery';
      gallerySubtitle = 'Select an existing image';

      cancel = 'Cancel';
    }

    try {
      // ======================================================
      // SHOW PHOTO SOURCE POPUP
      // ======================================================

      final ImageSource? source =
          await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ------------------------------------------------
                  // TOP HANDLE
                  // ------------------------------------------------

                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ------------------------------------------------
                  // SUBTITLE
                  // ------------------------------------------------

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: lightTextColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // TAKE PHOTO
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      tileColor:
                          const Color(0xFFFFF3E8),

                      leading: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        takePhoto,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),

                      subtitle: Text(
                        takePhotoSubtitle,
                        style: const TextStyle(
                          color: lightTextColor,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: primaryColor,
                      ),

                      onTap: () {
                        Navigator.pop(
                          context,
                          ImageSource.camera,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // GALLERY
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      tileColor:
                          const Color(0xFFFFF3E8),

                      leading: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        gallery,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),

                      subtitle: Text(
                        gallerySubtitle,
                        style: const TextStyle(
                          color: lightTextColor,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: primaryColor,
                      ),

                      onTap: () {
                        Navigator.pop(
                          context,
                          ImageSource.gallery,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // CANCEL
                  // =================================================

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      cancel,
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // User cancelled
      if (source == null) return;

      // ==========================================================
      // OPEN CAMERA OR GALLERY
      // ==========================================================

      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image == null) return;

      uploadedImagePath = null;

      setState(() {
        productImage = image;
        enhancedImageBytes = null;

        productNameController.clear();
        descriptionController.clear();
        storyController.clear();
        tagsController.clear();

        nameEn = '';
        nameHi = '';
        nameTe = '';

        descriptionEn = '';
        descriptionHi = '';
        descriptionTe = '';

        categoryEn = '';
        categoryHi = '';
        categoryTe = '';

        storyEn = '';
        storyHi = '';
        storyTe = '';

        aiPrice = '';
        selectedCategory = 'Handicraft';
      });
    } catch (error) {
      debugPrint(
        'Image picker error: $error',
      );

      if (!mounted) return;

      String errorText;

      if (widget.selectedLanguage == 'Hindi') {
        errorText =
            'कैमरा या गैलरी खोलने में समस्या हुई: $error';
      } else if (widget.selectedLanguage == 'Telugu') {
        errorText =
            'కెమెరా లేదా గ్యాలరీని తెరవడంలో సమస్య వచ్చింది: $error';
      } else {
        errorText =
            'Unable to access camera/gallery: $error';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text(errorText),
        ),
      );
    }
  }

  // ==========================================================
  // UPLOAD IMAGE
  // ==========================================================

  Future<String> uploadImageForAI(
    Uint8List imageBytes,
    String userId,
  ) async {
    final supabase = Supabase.instance.client;

    if (uploadedImagePath != null) {
      return uploadedImagePath!;
    }

    final String fileName =
        'ai-${DateTime.now().millisecondsSinceEpoch}.jpg';

    final String imagePath =
        '$userId/$fileName';

    await supabase.storage
        .from('product-images')
        .uploadBinary(
      imagePath,
      imageBytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: false,
      ),
    );

    uploadedImagePath = imagePath;

    return imagePath;
  }

  // ==========================================================
  // SIGNED URL
  // ==========================================================

  Future<String> createSignedImageUrl(
    String imagePath,
  ) async {
    final String signedUrl =
        await Supabase.instance.client.storage
            .from('product-images')
            .createSignedUrl(
              imagePath,
              600,
            );

    return signedUrl;
  }

  // ==========================================================
  // ANALYZE PRODUCT
  // ==========================================================

  Future<void> analyzeProduct() async {
    if (productImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('please_select_image'),
          ),
        ),
      );
      return;
    }

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('please_login_again'),
          ),
        ),
      );
      return;
    }

    setState(() {
      isAnalyzing = true;
    });

    try {
      // Read image
      final Uint8List imageBytes =
          await productImage!.readAsBytes();

      // Upload image
      final String imagePath =
          await uploadImageForAI(
        imageBytes,
        user.id,
      );

      debugPrint(
        'Uploaded image: $imagePath',
      );

      // Create signed URL
      final String signedUrl =
          await createSignedImageUrl(
        imagePath,
      );

      debugPrint(
        'Signed URL created',
      );

      // Call Supabase Edge Function
      final response =
          await Supabase.instance.client.functions.invoke(
        'generate-product',
        body: {
          'image_url': signedUrl,
          'language': widget.selectedLanguage,
        },
      );

      debugPrint(
        'AI response: ${response.data}',
      );

      final dynamic responseData =
          response.data;

      if (responseData == null) {
        throw Exception(
          'No AI response received.',
        );
      }

      if (responseData is! Map) {
        throw Exception(
          'Invalid AI response format.',
        );
      }

      final Map<String, dynamic> productData =
          Map<String, dynamic>.from(
        responseData,
      );

      // Check if Edge Function returned an error
      if (productData['error'] != null) {
        final String errorMessage =
            productData['error'].toString();

        final String details =
            productData['details']?.toString() ?? '';

        if (details.isNotEmpty) {
          throw Exception(
            '$errorMessage\n$details',
          );
        }

        throw Exception(
          errorMessage,
        );
      }

      // Parse AI result
      parseGroqResult(productData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('ai_listing_created'),
          ),
        ),
      );
    } catch (error) {
      debugPrint(
        'AI analysis error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration:
              const Duration(seconds: 8),
          content: Text(
            '${t('something_wrong')}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
        });
      }
    }
  }

  // ==========================================================
  // PARSE AI RESULT
  // ==========================================================

  void parseGroqResult(
    Map<String, dynamic> data,
  ) {
    nameEn =
        data['product_name_en']?.toString().trim() ?? '';

    nameHi =
        data['product_name_hi']?.toString().trim() ?? '';

    nameTe =
        data['product_name_te']?.toString().trim() ?? '';

    categoryEn =
        data['category']?.toString().trim() ?? '';

    categoryHi =
        data['category_hi']?.toString().trim() ?? '';

    categoryTe =
        data['category_te']?.toString().trim() ?? '';

    descriptionEn =
        data['description_en']?.toString().trim() ?? '';

    descriptionHi =
        data['description_hi']?.toString().trim() ?? '';

    descriptionTe =
        data['description_te']?.toString().trim() ?? '';

    storyEn =
        data['story_en']?.toString().trim() ?? '';

    storyHi =
        data['story_hi']?.toString().trim() ?? '';

    storyTe =
        data['story_te']?.toString().trim() ?? '';

    // --------------------------------------------------------
    // TAGS
    // --------------------------------------------------------

    final dynamic tagsData =
        data['tags'];

    if (tagsData is List) {
      tagsController.text = tagsData
          .map(
            (tag) => tag.toString().trim(),
          )
          .where(
            (tag) => tag.isNotEmpty,
          )
          .join(', ');
    } else if (tagsData is String) {
      tagsController.text =
          tagsData.trim();
    } else {
      tagsController.clear();
    }

    // --------------------------------------------------------
    // PRICE
    // --------------------------------------------------------

    final dynamic priceData =
        data['price'];

    if (priceData != null) {
      aiPrice =
          cleanPrice(priceData.toString());
    } else {
      aiPrice = '';
    }

    // --------------------------------------------------------
    // NAME
    // --------------------------------------------------------

    String selectedName = nameEn;

    if (widget.selectedLanguage == 'Hindi') {
      selectedName = nameHi;
    } else if (widget.selectedLanguage == 'Telugu') {
      selectedName = nameTe;
    }

    if (selectedName.isNotEmpty) {
      productNameController.text =
          selectedName.replaceAll('\n', ' ');
    }

    // --------------------------------------------------------
    // DESCRIPTION
    // --------------------------------------------------------

    if (widget.selectedLanguage == 'Hindi') {
      descriptionController.text =
          descriptionHi;
    } else if (widget.selectedLanguage == 'Telugu') {
      descriptionController.text =
          descriptionTe;
    } else {
      descriptionController.text =
          descriptionEn;
    }

    // --------------------------------------------------------
    // STORY
    // --------------------------------------------------------

    if (widget.selectedLanguage == 'Hindi') {
      storyController.text =
          storyHi;
    } else if (widget.selectedLanguage == 'Telugu') {
      storyController.text =
          storyTe;
    } else {
      storyController.text =
          storyEn;
    }

    // --------------------------------------------------------
    // CATEGORY
    // --------------------------------------------------------

    switch (
        categoryEn.trim().toLowerCase()) {
      case 'handicraft':
        selectedCategory = 'Handicraft';
        break;

      case 'textile':
        selectedCategory = 'Textile';
        break;

      case 'jewellery':
      case 'jewelry':
        selectedCategory = 'Jewellery';
        break;

      case 'pottery':
        selectedCategory = 'Pottery';
        break;

      case 'woodwork':
      case 'woodcraft':
        selectedCategory = 'Woodwork';
        break;

      default:
        selectedCategory = 'Handicraft';
    }

    setState(() {});
  }

  // ==========================================================
  // CLEAN PRICE
  // ==========================================================

  String cleanPrice(String value) {
    return value.replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );
  }

  // ==========================================================
  // ENHANCE PHOTO
  // ==========================================================

  Future<void> enhancePhoto() async {
    if (productImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('please_select_image'),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Image enhancement will be connected separately. Groq is currently used for AI product analysis.',
        ),
      ),
    );
  }

  // ==========================================================
  // SAVE PRODUCT
  // ==========================================================

  Future<void> saveProduct() async {
    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('please_login_again'),
          ),
        ),
      );
      return;
    }

    final String name =
        productNameController.text.trim();

    final String description =
        descriptionController.text.trim();

    final String story =
        storyController.text.trim();

    final String tagsText =
        tagsController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('please_enter_product_name'),
          ),
        ),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('please_enter_description'),
          ),
        ),
      );
      return;
    }

    if (productImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('please_select_image'),
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      Uint8List imageBytes;

      if (enhancedImageBytes != null) {
        imageBytes = enhancedImageBytes!;
      } else {
        imageBytes =
            await productImage!.readAsBytes();
      }

      String imagePath;

      if (uploadedImagePath != null) {
        imagePath = uploadedImagePath!;
      } else {
        final String fileName =
            '${DateTime.now().millisecondsSinceEpoch}.jpg';

        imagePath =
            '${user.id}/$fileName';

        await Supabase.instance.client.storage
            .from('product-images')
            .uploadBinary(
          imagePath,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );
      }

      // --------------------------------------------------------
      // TAGS
      // --------------------------------------------------------

      final List<String> tags =
          tagsText.isEmpty
              ? []
              : tagsText
                  .split(',')
                  .map(
                    (tag) => tag.trim(),
                  )
                  .where(
                    (tag) => tag.isNotEmpty,
                  )
                  .toList();

      // --------------------------------------------------------
      // PRICE
      // --------------------------------------------------------

      double? price;

      if (aiPrice.isNotEmpty) {
        price =
            double.tryParse(aiPrice);
      }

      // --------------------------------------------------------
      // FINAL VALUES
      // --------------------------------------------------------

      final String finalNameEn =
          nameEn.isNotEmpty
              ? nameEn
              : name;

      final String finalNameHi =
          nameHi.isNotEmpty
              ? nameHi
              : name;

      final String finalNameTe =
          nameTe.isNotEmpty
              ? nameTe
              : name;

      final String finalDescriptionEn =
          descriptionEn.isNotEmpty
              ? descriptionEn
              : description;

      final String finalDescriptionHi =
          descriptionHi.isNotEmpty
              ? descriptionHi
              : description;

      final String finalDescriptionTe =
          descriptionTe.isNotEmpty
              ? descriptionTe
              : description;

      final String finalCategoryEn =
          categoryEn.isNotEmpty
              ? categoryEn
              : selectedCategory;

      final String finalCategoryHi =
          categoryHi.isNotEmpty
              ? categoryHi
              : getCategoryTranslation(
                  selectedCategory,
                );

      final String finalCategoryTe =
          categoryTe.isNotEmpty
              ? categoryTe
              : getCategoryTranslation(
                  selectedCategory,
                );

      // --------------------------------------------------------
      // INSERT INTO SUPABASE
      // --------------------------------------------------------

      final inserted =
          await Supabase.instance.client
              .from('products')
              .insert({
        'user_id': user.id,
        'name': name,
        'category': selectedCategory,
        'description': description,

        'name_en': finalNameEn,
        'name_hi': finalNameHi,
        'name_te': finalNameTe,

        'category_en': finalCategoryEn,
        'category_hi': finalCategoryHi,
        'category_te': finalCategoryTe,

        'description_en':
            finalDescriptionEn,
        'description_hi':
            finalDescriptionHi,
        'description_te':
            finalDescriptionTe,

        'story': story.isEmpty
            ? null
            : story,

        'tags': tags,

        'price': price,

        'image_url': imagePath,
      })
              .select()
              .single();

      // --------------------------------------------------------
      // ADD TO LOCAL PRODUCT LIST
      // --------------------------------------------------------

      savedProducts.insert(
        0,
        Product(
          id: inserted['id']?.toString(),
          name: name,
          category: selectedCategory,
          description: description,
          price: price == null
              ? ''
              : '₹${price.toStringAsFixed(0)}',
          imagePath: imagePath,

          nameEn: finalNameEn,
          nameHi: finalNameHi,
          nameTe: finalNameTe,

          descriptionEn:
              finalDescriptionEn,
          descriptionHi:
              finalDescriptionHi,
          descriptionTe:
              finalDescriptionTe,

          categoryEn:
              finalCategoryEn,
          categoryHi:
              finalCategoryHi,
          categoryTe:
              finalCategoryTe,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('product_saved'),
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'Database error: ${error.message}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message,
          ),
        ),
      );
    } on StorageException catch (error) {
      debugPrint(
        'Storage error: ${error.message}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image upload error: ${error.message}',
          ),
        ),
      );
    } catch (error) {
      debugPrint(
        'Save error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${t('something_wrong')}: $error',
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
        elevation: 0,
        title: Text(
          t('add_product'),
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
            Text(
              t('product_photo'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: pickProductImage,

              child: Container(
                width: double.infinity,
                height: 220,

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE8C39E),
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child:
                      _buildImagePreview(),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // ENHANCE PHOTO
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: OutlinedButton.icon(
                onPressed:
                    isEnhancing
                        ? null
                        : enhancePhoto,

                icon: isEnhancing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              primaryColor,
                        ),
                      )
                    : const Icon(
                        Icons.auto_fix_high,
                      ),

                label: Text(
                  isEnhancing
                      ? t('enhancing')
                      : t(
                          'enhance_photo_with_ai',
                        ),
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color:
                        primaryColor,
                  ),
                ),

                style:
                    OutlinedButton.styleFrom(
                  side:
                      const BorderSide(
                    color:
                        primaryColor,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PRODUCT NAME
            // ==================================================

            _sectionTitle(
              t('product_name'),
            ),

            const SizedBox(height: 8),

            _textField(
              controller:
                  productNameController,
              hint:
                  t('product_name_hint'),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CATEGORY
            // ==================================================

            _sectionTitle(
              t('category'),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue:
                  selectedCategory,

              decoration:
                  InputDecoration(
                filled: true,
                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),

              items: [
                'Handicraft',
                'Textile',
                'Jewellery',
                'Pottery',
                'Woodwork',
              ].map(
                (category) {
                  return DropdownMenuItem<String>(
                    value: category,

                    child: Text(
                      getCategoryTranslation(
                        category,
                      ),
                    ),
                  );
                },
              ).toList(),

              onChanged:
                  (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedCategory =
                      value;
                });
              },
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            _sectionTitle(
              t('description'),
            ),

            const SizedBox(height: 8),

            _textField(
              controller:
                  descriptionController,
              hint:
                  t('description_hint'),
              maxLines: 5,
            ),

            const SizedBox(height: 20),

            // ==================================================
            // STORY
            // ==================================================

            _sectionTitle(
              t('product_story'),
            ),

            const SizedBox(height: 8),

            _textField(
              controller:
                  storyController,
              hint:
                  t('product_story_hint'),
              maxLines: 5,
            ),

            const SizedBox(height: 20),

            // ==================================================
            // TAGS
            // ==================================================

            _sectionTitle(
              t('tags_keywords'),
            ),

            const SizedBox(height: 8),

            _textField(
              controller:
                  tagsController,
              hint:
                  t('tags_keywords_hint'),
              maxLines: 2,
            ),

            const SizedBox(height: 20),

            // ==================================================
            // AI PRICE
            // ==================================================

            if (aiPrice.isNotEmpty)
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

                child: Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      color:
                          primaryColor,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            t(
                              'ai_suggested_price',
                            ),
                            style:
                                const TextStyle(
                              fontSize: 14,
                              color:
                                  lightTextColor,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            '₹$aiPrice',
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (aiPrice.isNotEmpty)
              const SizedBox(height: 20),

            // ==================================================
            // ANALYZE BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child:
                  ElevatedButton.icon(
                onPressed:
                    isAnalyzing
                        ? null
                        : analyzeProduct,

                icon: isAnalyzing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome,
                      ),

                label: Text(
                  isAnalyzing
                      ? t('analyzing')
                      : t(
                          'analyze_create_listing',
                        ),
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

                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // SAVE BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child:
                  ElevatedButton.icon(
                onPressed:
                    isSaving
                        ? null
                        : saveProduct,

                icon: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                      ),

                label: Text(
                  isSaving
                      ? t('saving')
                      : t('save_product'),

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

                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: darkTextColor,
      ),
    );
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,

      decoration:
          InputDecoration(
        hintText: hint,

        filled: true,
        fillColor: Colors.white,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  // ==========================================================
  // IMAGE PREVIEW
  // ==========================================================

  Widget _buildImagePreview() {
    // Enhanced image
    if (enhancedImageBytes != null) {
      return Stack(
        fit: StackFit.expand,

        children: [
          Image.memory(
            enhancedImageBytes!,
            fit: BoxFit.cover,
          ),

          Positioned(
            top: 12,
            right: 12,

            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),

              decoration:
                  BoxDecoration(
                color:
                    primaryColor,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Text(
                t('ai_enhanced'),

                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Selected camera/gallery image
    if (productImage != null) {
      return FutureBuilder<Uint8List>(
        future:
            productImage!.readAsBytes(),

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

          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          }

          return const Icon(
            Icons.image_outlined,
            size: 60,
            color:
                primaryColor,
          );
        },
      );
    }

    // Empty state
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        const Icon(
          Icons.add_a_photo_outlined,
          size: 55,
          color: primaryColor,
        ),

        const SizedBox(height: 10),

        Text(
          t('tap_to_add_photo'),

          style:
              const TextStyle(
            color: darkTextColor,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    productNameController.dispose();
    descriptionController.dispose();
    storyController.dispose();
    tagsController.dispose();

    super.dispose();
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