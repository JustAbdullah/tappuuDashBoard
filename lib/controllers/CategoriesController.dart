import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tappuu_dashboard/core/localization/changelanguage.dart';
import 'package:translator/translator.dart';
import '../core/data/model/category.dart';

class CategoriesController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  
  RxList<Category> categoriesList = <Category>[].obs;
  RxBool isLoadingCategories = false.obs;

    final translator = GoogleTranslator();
  RxBool isSaving = false.obs;
  RxBool isDeleting = false.obs;
  Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  RxString uploadedImageUrl = ''.obs;
  final String uploadApiUrl = "https://stayinme.arabiagroup.net/lar_stayInMe/public/api/upload";

  // ======== [دوال معالجة الصور] ========
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      imageBytes.value = bytes;
      update(['category_image']);
    }
  }

  void removeImage() {
    imageBytes.value = null;
    uploadedImageUrl.value = '';
    update(['category_image']);
  }

  Future<void> uploadImageToServer() async {
    try {
      if (imageBytes.value == null) {
        print('لا توجد بيانات صورة لرفعها');
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse(uploadApiUrl));
      request.files.add(
        http.MultipartFile.fromBytes(
          'images[]', 
          imageBytes.value!,
          filename: 'category_${DateTime.now().millisecondsSinceEpoch}.jpg',
        )
      );

      var response = await request.send();
      if (response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        uploadedImageUrl.value = List<String>.from(jsonData['image_urls']).first;
      } else {
        var responseData = await response.stream.bytesToString();
        throw Exception("فشل رفع الصورة: ${response.statusCode}");
      }
    } catch (e) {
      print('تفاصيل الخطأ في رفع الصورة: $e');
      rethrow;
    }
  }

  // ======== [دوال الترجمة] ========
  Future<String> _translateToEnglish(String arabicText) async {
    try {
      final translation = await translator.translate(arabicText, from: 'ar', to: 'en');
      return translation.text;
    } catch (e) {
      print("Translation error: $e");
      return arabicText; // إرجاع النص الأصلي في حال الخطأ
    }
  }

  // ======== [دوال جلب البيانات] ========
  Future<void> fetchCategories({
    required String language,
    String? searchName,  // معامل اختياري
  }) async {
    categoriesList.clear();
    isLoadingCategories.value = true;

    try {
      // بناء الـ URL مع معامل name إن وُجد
      final uri = Uri.parse('$_baseUrl/categories/$language')
          .replace(queryParameters: {
        if (searchName != null && searchName.trim().isNotEmpty)
          'name': searchName.trim(),
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        if (jsonResponse['status'] == 'success') {
          final data = jsonResponse['data'] as List<dynamic>;
          categoriesList.value = data
              .map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب التصنيفات', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب التصنيفات: $e', true);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  
// ======== [إنشاء تصنيف جديد] ========
Future<void> createCategory(String arabicName, String arabicDescription) async {
  if (arabicName.isEmpty) {
    _showSnackbar('تحذير', 'الرجاء إدخال اسم التصنيف', true);
    return;
  }
  
  isSaving.value = true;
  try {
    // 1. ترجمة الاسم والوصف من العربية إلى الإنجليزية
    final englishName = await _translateToEnglish(arabicName);
    final englishDescription = await _translateToEnglish(arabicDescription);
    
    // 2. إنشاء الـ slug من الاسم الإنجليزي
    final slug = englishName.toLowerCase().replaceAll(' ', '-');
    
    // 3. رفع الصورة إذا تم اختيارها
    if (imageBytes.value != null) {
      await uploadImageToServer();
    }
    
    // 4. إنشاء التصنيف في السيرفر مع الترجمات باللغتين
    final response = await http.post(
      Uri.parse('$_baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "slug": slug,
        "image": uploadedImageUrl.value.isNotEmpty ? uploadedImageUrl.value : null,
        "translations": [
          {
            "language": "ar",
            "name": arabicName,
            "description": arabicDescription,
          },
          {
            "language": "en",
            "name": englishName,
            "description": englishDescription,
          },
        ],
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['status'] == 'success') {
      _showSnackbar('نجاح', 'تم إنشاء التصنيف بنجاح', false);
      await fetchCategories(language:  Get.find<ChangeLanguageController>().currentLocale.value.languageCode); // تحديث القائمة
      resetForm(); // إعادة تعيين النموذج
    } else {
      _showSnackbar('خطأ', responseData['message'] ?? 'فشل في إنشاء التصنيف', true);
    }
  } catch (e) {
    _showSnackbar('خطأ', 'حدث خطأ أثناء إنشاء التصنيف: $e', true);
  } finally {
    isSaving.value = false;
  }
}

// ======== [تحديث تصنيف موجود] ========

// داخل الفئة CategoriesController
TextEditingController slugController = TextEditingController();
TextEditingController metaTitleController = TextEditingController();
TextEditingController metaDescController = TextEditingController();
Future<void> updateCategory(Category category, String newArabicName, String newDescription) async {
  if (newArabicName.isEmpty) {
    _showSnackbar('تحذير', 'الرجاء إدخال اسم التصنيف', true);
    return;
  }

  isSaving.value = true;
  try {
    final newEnglishName = await _translateToEnglish(newArabicName);
    final newEnglishDescription = await _translateToEnglish(newDescription);

    String newSlug = slugController.text.trim();
    if (newSlug.isEmpty) {
      newSlug = newArabicName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'[\s_-]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
    } else {
      newSlug = newSlug.replaceAll(RegExp(r'\s+'), '-');
    }

    if (imageBytes.value != null) {
      await uploadImageToServer();
    }

    final Map<String, dynamic> updateData = {
      "slug": newSlug,
      "meta_title": metaTitleController.text.trim().isNotEmpty
          ? metaTitleController.text.trim()
          : newArabicName,
      "meta_description": metaDescController.text.trim().isNotEmpty
          ? metaDescController.text.trim()
          : newDescription,
      "image": uploadedImageUrl.value.isNotEmpty ? uploadedImageUrl.value : category.image,
      "translations": [
        {
          "language": "ar",
          "name": newArabicName,
          "description": newDescription,
        },
        {
          "language": "en",
          "name": newEnglishName,
          "description": newEnglishDescription,
        },
      ],
    };

    updateData.removeWhere((key, value) => value == null);

    // ---- DEBUG: طباعة الباودي والـ URL ----
    final uri = Uri.parse('$_baseUrl/categories/${category.id}');
    debugPrint('➡️ updateCategory PUT $uri');
    debugPrint('➡️ Payload: ${json.encode(updateData)}');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // مهم ليرد السيرفر JSON
        // إذا تستخدم Authorization ضعها هنا:
        // if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateData),
    );

    debugPrint('⬅️ updateCategory status: ${response.statusCode}');
    debugPrint('⬅️ updateCategory body: ${response.body}');

    // محاولة فك الـ JSON بأمان
    dynamic responseData;
    try {
      responseData = json.decode(response.body);
    } catch (e) {
      responseData = null;
    }

    if ((response.statusCode == 200 || response.statusCode == 201) && responseData is Map && responseData['status'] == 'success') {
      _showSnackbar('نجاح', 'تم تحديث التصنيف بنجاح', false);
      await fetchCategories(language: Get.find<ChangeLanguageController>().currentLocale.value.languageCode);
      resetForm();
      return;
    }

    // حالات خطأ مفصّلة لتسهيل تتبّع السبب
    if (response.statusCode == 422 && responseData is Map) {
      final errors = responseData['errors'] ?? responseData;
      _showSnackbar('خطأ في بيانات الإدخال', errors.toString(), true);
      return;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      _showSnackbar('خطأ مصادقة', 'غير مصرح - تأكد من التوكن أو الصلاحيات', true);
      return;
    }

    // إذا الرد ليس JSON أو رسالة خطأ عامة
    String serverMsg = 'فشل في تحديث التصنيف';
    if (responseData is Map && (responseData['message'] != null || responseData['error'] != null)) {
      serverMsg = (responseData['message'] ?? responseData['error']).toString();
    } else if (response.body.trim().isNotEmpty) {
      serverMsg = 'رد غير متوقع من السيرفر: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}';
    } else {
      serverMsg = 'حالة HTTP: ${response.statusCode}';
    }

    _showSnackbar('خطأ', serverMsg, true);
  } catch (e, st) {
    debugPrint('Exception updateCategory: $e\n$st');
    _showSnackbar('خطأ', 'حدث خطأ أثناء تحديث التصنيف: $e', true);
  } finally {
    isSaving.value = false;
  }
}

  // ======== [حذف تصنيف] ========
  Future<void> deleteCategory(int id) async {
    isDeleting.value = true;
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/categories/$id'),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        _showSnackbar('نجاح', 'تم حذف التصنيف بنجاح', false);
       await fetchCategories(language:  Get.find<ChangeLanguageController>().currentLocale.value.languageCode); // تحديث القائمة
      } else {
        _showSnackbar('خطأ', responseData['message'] ?? 'فشل في حذف التصنيف', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء حذف التصنيف: $e', true);
    } finally {
      isDeleting.value = false;
    }
  }

  // ======== [إعادة تعيين النموذج] ========
void resetForm() {
  imageBytes.value = null;
  uploadedImageUrl.value = '';
  slugController.clear();
  metaTitleController.clear();
  metaDescController.clear();
  update(['category_image']);
}


  // ======== [دالة لعرض رسائل احترافية] ========
  void _showSnackbar(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      borderRadius: 10,
      margin: EdgeInsets.all(15),
      duration: Duration(seconds: isError ? 4 : 3),
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // ======== [دالة لتحميل الصورة من الرابط] ========
  Future<void> loadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        imageBytes.value = response.bodyBytes;
        update(['category_image']);
      }
    } catch (e) {
      print('فشل تحميل الصورة: $e');
    }
  }
}