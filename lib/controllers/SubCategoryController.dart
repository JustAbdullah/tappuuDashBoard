// lib/controllers/SubCategoryController.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';
import '../core/data/model/category.dart';
import '../core/data/model/subcategory_level_one.dart';
import '../core/localization/changelanguage.dart';

enum _SnackType { success, error, info }

class SubCategoryController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
  final translator = GoogleTranslator();

  // حالات وقوائم
  RxList<Category> categoriesList = <Category>[].obs;
  RxBool isLoadingCategories = false.obs;
  RxList<SubcategoryLevelOne> subCategoriesList = <SubcategoryLevelOne>[].obs;
  RxBool isLoadingSubCategories = false.obs;
  RxBool isSaving = false.obs;
  RxBool isDeleting = false.obs;
  // صورة
  Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  RxString uploadedImageUrl = ''.obs;
  final String uploadApiUrl = "https://stayinme.arabiagroup.net/lar_stayInMe/public/api/upload";

  // ======== [صور] ========
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      imageBytes.value = bytes;
      update(['subcategory_image']);
    }
  }

  void removeImage() {
    imageBytes.value = null;
    uploadedImageUrl.value = '';
    update(['subcategory_image']);
  }

  Future<void> uploadImageToServer() async {
    try {
      if (imageBytes.value == null) {
        debugPrint('No image to upload');
        return;
      }
      var req = http.MultipartRequest('POST', Uri.parse(uploadApiUrl));
      req.files.add(http.MultipartFile.fromBytes(
        'images[]',
        imageBytes.value!,
        filename: 'subcat1_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();
      debugPrint('upload status: ${streamed.statusCode}');
      debugPrint('upload body: $body');

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        final j = _safeDecode(body);
        if (j is Map) {
          if (j['image_urls'] != null && j['image_urls'] is List) {
            uploadedImageUrl.value = List<String>.from(j['image_urls']).first;
          } else if (j['image_url'] != null) {
            uploadedImageUrl.value = j['image_url'].toString();
          } else if (j['image'] != null) {
            uploadedImageUrl.value = j['image'].toString();
          } else {
            throw Exception('Unexpected upload response');
          }
        } else {
          throw Exception('Unexpected upload response');
        }
      } else {
        throw Exception('Upload failed: ${streamed.statusCode} -> $body');
      }
    } catch (e) {
      debugPrint('upload error: $e');
      rethrow;
    }
  }

  // ======== [ترجمة] ========
  Future<String> _translateToEnglish(String arabicText) async {
    try {
      final t = await translator.translate(arabicText, from: 'ar', to: 'en');
      return t.text;
    } catch (e) {
      debugPrint('translate error: $e');
      return arabicText;
    }
  }

  // ======== [سناك موثوق] ========
  void _showSnack(String title, String message, _SnackType type, {IconData? icon, int seconds = 3}) {
    try {
      Get.closeAllSnackbars();
    } catch (_) {}
    final LinearGradient gradient;
    final IconData defaultIcon;
    switch (type) {
      case _SnackType.success:
        gradient = LinearGradient(colors: [Colors.green.shade700, Colors.green.shade500]);
        defaultIcon = Icons.check_circle;
        break;
      case _SnackType.error:
        gradient = LinearGradient(colors: [Colors.red.shade900, Colors.red.shade700]);
        defaultIcon = Icons.error_outline;
        break;
      default:
        gradient = LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600]);
        defaultIcon = Icons.info_outline;
    }

    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        messageText: Text(message, style: const TextStyle(color: Colors.white)),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        backgroundGradient: gradient,
        icon: Icon(icon ?? defaultIcon, color: Colors.white),
        duration: Duration(seconds: seconds),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutQuad,
        reverseAnimationCurve: Curves.easeInQuad,
        shouldIconPulse: true,
        maxWidth: 900,
        snackStyle: SnackStyle.FLOATING,
      ),
    );
  }

  // ======== [جلب التصنيفات الرئيسية] ========
  Future<void> fetchCategories(String language) async {
    categoriesList.clear();
    isLoadingCategories.value = true;
    try {
      final res = await http.get(Uri.parse('$_baseUrl/categories/$language'));
      debugPrint('fetchCategories status: ${res.statusCode}');
      debugPrint('fetchCategories body: ${res.body}');
      if (res.statusCode == 200) {
        final decoded = _safeDecode(res.body);
        if (decoded is Map && (decoded['status'] == 'success' || decoded['success'] == true)) {
          final list = decoded['data'] as List<dynamic>;
          categoriesList.value = list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          _showSnack('خطأ', 'فشل جلب التصنيفات', _SnackType.error);
        }
      } else {
        _showSnack('خطأ', 'خطأ في الاتصال (${res.statusCode})', _SnackType.error);
      }
    } catch (e) {
      _showSnack('خطأ', 'حدث خطأ أثناء جلب التصنيفات: $e', _SnackType.error);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ======== [جلب التصنيفات الفرعية] ========
  /// يحاول أولاً المسار: /subcategories/{language}?...
  /// إن فشل (405 أو 500 مع رسالة عن arguments) يقوم بالfallback لاستخدام ?language=...
  Future<void> fetchSubCategories({
    int? categoryId,
    required String language,
    String? searchName,
  }) async {
    subCategoriesList.clear();
    isLoadingSubCategories.value = true;

    final commonParams = <String, String>{
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (searchName != null && searchName.trim().isNotEmpty) 'name': searchName.trim(),
    };

    // try path-based (many projects use /subcategories/{language})
    final pathUri = Uri.parse('$_baseUrl/subcategories/$language').replace(queryParameters: commonParams);
    debugPrint('fetchSubCategories try pathUri: $pathUri');

    try {
      final resPath = await http.get(pathUri, headers: {'Accept': 'application/json'});
      debugPrint('fetchSubCategories path status: ${resPath.statusCode}');
      debugPrint('fetchSubCategories path body: ${resPath.body}');

      if (resPath.statusCode == 200) {
        final decoded = _safeDecode(resPath.body);
        final list = _extractListFromResponse(decoded);
        if (list != null) {
          subCategoriesList.value = list.map((e) => SubcategoryLevelOne.fromJson(e as Map<String, dynamic>)).toList();
          return;
        } else {
          _showSnack('خطأ', 'استجابة غير متوقعة من السيرفر (path)', _SnackType.error);
          return;
        }
      }

      // إذا لم تكن 200، نتحقق إن السبب method not allowed أو خطأ في number of args أو 500
      String serverMessage = 'خطأ في الاتصال (${resPath.statusCode})';
      try {
        final b = json.decode(resPath.body);
        if (b is Map && b['message'] != null) serverMessage = b['message'].toString();
      } catch (_) {}

      // نعمل fallback إلى query param style
      debugPrint('FALLBACK to query param because: $serverMessage');
    } catch (e) {
      debugPrint('fetchSubCategories path error: $e');
      // نكمل إلى fallback
    }

    // fallback: /subcategories?language=ar&...
    final fallbackParams = <String, String>{
      'language': language,
      ...commonParams,
    };
    final queryUri = Uri.parse('$_baseUrl/subcategories').replace(queryParameters: fallbackParams);
    debugPrint('fetchSubCategories try queryUri: $queryUri');

    try {
      final resQuery = await http.get(queryUri, headers: {'Accept': 'application/json'});
      debugPrint('fetchSubCategories query status: ${resQuery.statusCode}');
      debugPrint('fetchSubCategories query body: ${resQuery.body}');

      if (resQuery.statusCode == 200) {
        final decoded = _safeDecode(resQuery.body);
        final list = _extractListFromResponse(decoded);
        if (list != null) {
          subCategoriesList.value = list.map((e) => SubcategoryLevelOne.fromJson(e as Map<String, dynamic>)).toList();
          return;
        } else {
          _showSnack('خطأ', 'استجابة غير متوقعة من السيرفر (query)', _SnackType.error);
        }
      } else {
        String msg = 'خطأ في الاتصال (${resQuery.statusCode})';
        try {
          final b = json.decode(resQuery.body);
          if (b is Map && b['message'] != null) msg = b['message'].toString();
        } catch (_) {}
        _showSnack('خطأ', msg, _SnackType.error);
      }
    } catch (e) {
      _showSnack('خطأ', 'حدث خطأ أثناء جلب التصنيفات الفرعية: $e', _SnackType.error);
    } finally {
      isLoadingSubCategories.value = false;
    }
  }

  // ======== [إنشاء] ========
  Future<void> createSubCategory(int categoryId, String arabicName, {String? arabicDescription}) async {
    if (arabicName.trim().isEmpty) {
      _showSnack('تحذير', 'الرجاء إدخال اسم التصنيف الفرعي', _SnackType.info);
      return;
    }
    isSaving.value = true;
    try {
      final english = await _translateToEnglish(arabicName);
      final slug = english.toLowerCase().replaceAll(' ', '-');

      if (imageBytes.value != null) {
        await uploadImageToServer();
      }

      final payload = {
        "category_id": categoryId,
        "slug": slug,
        "image": uploadedImageUrl.value.isNotEmpty ? uploadedImageUrl.value : null,
        "translations": [
          {"language": "ar", "name": arabicName},
          {"language": "en", "name": english},
        ],
      };

      debugPrint('create payload: ${json.encode(payload)}');
      final res = await http.post(Uri.parse('$_baseUrl/subcategories'),
          headers: {'Content-Type': 'application/json'}, body: json.encode(payload));
      debugPrint('create status: ${res.statusCode}');
      debugPrint('create body: ${res.body}');

      final decoded = _safeDecode(res.body);
      final ok = (res.statusCode == 200 || res.statusCode == 201) &&
          (decoded is Map && (decoded['status'] == 'success' || decoded['success'] == true));

      if (ok) {
        _showSnack('نجاح', 'تم إنشاء التصنيف الفرعي بنجاح', _SnackType.success);
        resetForm();
        String lang = 'ar';
        try {
          lang = Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
        } catch (_) {}
        await fetchSubCategories(categoryId: categoryId, language: lang);
      } else {
        String msg = 'فشل في إنشاء التصنيف الفرعي';
        if (decoded is Map) msg = (decoded['message'] ?? decoded['error'])?.toString() ?? msg;
        _showSnack('خطأ', msg, _SnackType.error);
      }
    } catch (e) {
      _showSnack('خطأ', 'حدث خطأ أثناء الإنشاء: $e', _SnackType.error);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [تحديث] ========
  
  TextEditingController subSlugController = TextEditingController();
TextEditingController subMetaTitleController = TextEditingController();
TextEditingController subMetaDescController = TextEditingController();

  
Future<void> updateSubCategory(SubcategoryLevelOne subCategory, int categoryId, String newArabicName) async {
  if (newArabicName.trim().isEmpty) {
    _showSnack('تحذير', 'الرجاء إدخال اسم التصنيف الفرعي', _SnackType.info);
    return;
  }
  isSaving.value = true;
  try {
    final english = await _translateToEnglish(newArabicName);

    // استخدام slug اليدوي إن وُجد وإلا توليد من العربي
    String slug = subSlugController.text.trim();
    if (slug.isEmpty) {
      slug = newArabicName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'[\s_-]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
    } else {
      slug = slug.trim();
    }

    if (imageBytes.value != null) {
      await uploadImageToServer();
    }

    final Map<String, dynamic> payload = {
      "category_id": categoryId,
      "slug": slug,
      "meta_title": subMetaTitleController.text.trim().isNotEmpty ? subMetaTitleController.text.trim() : null,
      "meta_description": subMetaDescController.text.trim().isNotEmpty ? subMetaDescController.text.trim() : null,
      "translations": [
        {"language": "ar", "name": newArabicName},
        {"language": "en", "name": english},
      ],
    };

    if (uploadedImageUrl.value.isNotEmpty) payload['image'] = uploadedImageUrl.value;

    // إزالة الحقول null قبل الإرسال
    payload.removeWhere((k, v) => v == null);

    debugPrint('update payload: ${json.encode(payload)}');
    final res = await http.put(
      Uri.parse('$_baseUrl/subcategories/${subCategory.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    debugPrint('update status: ${res.statusCode}');
    debugPrint('update body: ${res.body}');

    final decoded = _safeDecode(res.body);
    final ok = (res.statusCode == 200 || res.statusCode == 201) && decoded is Map && (decoded['status'] == 'success' || decoded['success'] == true);

    if (ok) {
      _showSnack('نجاح', 'تم تحديث التصنيف الفرعي بنجاح', _SnackType.success);
      resetForm();
      String lang = 'ar';
      try {
        lang = Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
      } catch (_) {}
      await fetchSubCategories(categoryId: categoryId, language: lang);
    } else if (res.statusCode == 422 && decoded is Map) {
      _showSnack('خطأ', (decoded['errors'] ?? decoded['message']).toString(), _SnackType.error);
    } else {
      String msg = 'فشل في تحديث التصنيف الفرعي';
      if (decoded is Map) msg = (decoded['message'] ?? decoded['error'])?.toString() ?? msg;
      _showSnack('خطأ', msg, _SnackType.error);
    }
  } catch (e) {
    _showSnack('خطأ', 'حدث خطأ أثناء التحديث: $e', _SnackType.error);
  } finally {
    isSaving.value = false;
  }
}

  // ======== [حذف] ========
  Future<void> deleteSubCategory(int id, int categoryId) async {
    isDeleting.value = true;
    try {
      final res = await http.delete(Uri.parse('$_baseUrl/subcategories/$id'));
      debugPrint('delete status: ${res.statusCode}');
      debugPrint('delete body: ${res.body}');

      final decoded = _safeDecode(res.body);
      final ok = res.statusCode == 200 && decoded is Map && (decoded['status'] == 'success' || decoded['success'] == true);

      if (ok) {
        _showSnack('نجاح', 'تم حذف التصنيف الفرعي بنجاح', _SnackType.success);
        resetForm();
        String lang = 'ar';
        try {
          lang = Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
        } catch (_) {}
        await fetchSubCategories(categoryId: categoryId, language: lang);
      } else {
        String msg = 'فشل في حذف التصنيف الفرعي';
        if (decoded is Map) msg = (decoded['message'] ?? decoded['error'])?.toString() ?? msg;
        _showSnack('خطأ', msg, _SnackType.error);
      }
    } catch (e) {
      _showSnack('خطأ', 'حدث خطأ أثناء الحذف: $e', _SnackType.error);
    } finally {
      isDeleting.value = false;
    }
  }

  // ======== [مساعدات] ========
  void resetForm() {
    imageBytes.value = null;
    uploadedImageUrl.value = '';
    update(['subcategory_image']);
  }

  dynamic _safeDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  /// يحاول استخراج لستة من الاستجابة بأنماط متعددة
  List<dynamic>? _extractListFromResponse(dynamic decoded) {
    if (decoded == null) return null;
    if (decoded is List) return decoded;
    if (decoded is Map) {
      if (decoded['data'] is List) return decoded['data'] as List<dynamic>;
      // بعض API ترجع مباشرة داخل مفتاح 'data' أو داخل 'result' أو غيره - يمكن توسيع هنا
      if (decoded['success'] == true && decoded['data'] is List) return decoded['data'] as List<dynamic>;
      // ممكن أن تكون API ترجع بيانات مباشرة في الماب بأسماء مختلفة -> المحاولة محدودة هنا
    }
    return null;
  }

  Future<void> loadImageFromUrl(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        imageBytes.value = res.bodyBytes;
        update(['subcategory_image']);
      }
    } catch (e) {
      debugPrint('loadImage error: $e');
    }
  }
}
