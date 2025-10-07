import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:translator/translator.dart';

import '../core/data/model/category.dart';
import '../core/data/model/subcategory_level_one.dart';
import '../core/data/model/subcategory_level_two.dart';
import '../core/localization/changelanguage.dart';

enum _SnackType { success, error, info }

class SubCategoryLevelTwoController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
  final String uploadApiUrl = "https://stayinme.arabiagroup.net/lar_stayInMe/public/api/upload";
  final translator = GoogleTranslator();

  // القوائم والحالات
  RxList<Category> categoriesList = <Category>[].obs;
  RxBool isLoadingCategories = false.obs;

  RxList<SubcategoryLevelTwo> subCategoriesLevelTwoList = <SubcategoryLevelTwo>[].obs;
  RxList<SubcategoryLevelOne> parentSubCategoriesList = <SubcategoryLevelOne>[].obs;
  RxBool isLoadingSubCategoriesLevelTwo = false.obs;
  RxBool isLoadingParentSubCategories = false.obs;

  RxBool isSaving = false.obs;
  RxBool isDeleting = false.obs;

  // صورة (بايت + اسم/مسار)
  Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  RxString imageFileName = ''.obs; // اسم الملف الأصلي إذا متاح
  RxString imageFilePath = ''.obs; // المسار (قد يكون فارغ على الويب)
  RxString uploadedImageUrl = ''.obs;

  // ======== [اختيار ملف - يدعم SVG ويحافظ على الامتداد] ========
  Future<void> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'],
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      // إذا أرجع bytes، نستخدمها مباشرة (أسلم)
      if (file.bytes != null) {
        imageBytes.value = file.bytes!;
      } else if (file.path != null && file.path!.isNotEmpty) {
        // fallback لقراءة الملف من المسار
        final bytes = await File(file.path!).readAsBytes();
        imageBytes.value = bytes;
      } else {
        // لا يمكن الحصول على البايتات
      //  _showSnackbar('خطأ', 'لم أستطع قراءة الملف المختار', _SnackType.error);
        return;
      }

      imageFileName.value = file.name ?? 'image_${DateTime.now().millisecondsSinceEpoch}';
      imageFilePath.value = file.path ?? '';
      update(['subcategory_level_two_image']);
    } catch (e) {
      debugPrint('pickImage error: $e');
     // _showSnackbar('خطأ', 'حدث خطأ عند اختيار الصورة: $e', _SnackType.error);
    }
  }

  void removeImage() {
    imageBytes.value = null;
    imageFileName.value = '';
    imageFilePath.value = '';
    uploadedImageUrl.value = '';
    update(['subcategory_level_two_image']);
  }

  // ======== [رفع الصورة للخادم مع الحفاظ على الامتداد والمحتوى] ========
  Future<void> uploadImageToServer() async {
    try {
      if (imageBytes.value == null) {
        debugPrint('uploadImageToServer: no image bytes');
        return;
      }

      // محاولة اكتشاف MIME Type من البايتات أو من الاسم/المسار
      String? mimeType = lookupMimeType(imageFilePath.value, headerBytes: imageBytes.value) ??
          lookupMimeType(imageFileName.value, headerBytes: imageBytes.value);

      // حدّ افتراضي للامتداد وmime إذا لم تُكتشف
      String extension = 'jpg';
      if (imageFileName.value.isNotEmpty) {
        final ext = p.extension(imageFileName.value).replaceFirst('.', '').toLowerCase();
        if (ext.isNotEmpty) extension = ext;
      }

      if (mimeType != null && mimeType.contains('/')) {
        final sub = mimeType.split('/')[1];
        extension = sub.split('+').first.toLowerCase();
      } else {
        // خريطة بسيطة في حالة عدم وجود mime
        final guessed = extension;
        switch (guessed) {
          case 'png':
          case 'gif':
          case 'webp':
          case 'svg':
            extension = guessed;
            break;
          default:
            extension = 'jpg';
        }
      }

      // بناء contentType دقيق (يمكن أن يكون svg+xml)
      String mimeMain = 'image';
      String mimeSub = 'jpeg';
      if (mimeType != null && mimeType.contains('/')) {
        final parts = mimeType.split('/');
        mimeMain = parts[0];
        mimeSub = parts[1];
      } else {
        // fallback based on extension
        switch (extension) {
          case 'png':
            mimeSub = 'png';
            break;
          case 'gif':
            mimeSub = 'gif';
            break;
          case 'webp':
            mimeSub = 'webp';
            break;
          case 'svg':
            mimeSub = 'svg+xml';
            break;
          default:
            mimeSub = 'jpeg';
        }
      }

      // احفظ اسم الملف الأصلي مع id زمني لمنع التعارض، مع الاحتفاظ بالاسم الأساسي إن وُجد
      final baseName = imageFileName.value.isNotEmpty
          ? p.basenameWithoutExtension(imageFileName.value)
          : 'subcat2';
      final fileName = '${baseName}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final uri = Uri.parse(uploadApiUrl);
      final request = http.MultipartRequest('POST', uri);

      // HINT: بعض السيرفرات تتوقع 'images' بدل 'images[]'، لكن بما أن سيرفرك يستخدم 'images[]' في الكود السابق - حافظنا عليه
      final multipartFile = http.MultipartFile.fromBytes(
        'images[]',
        imageBytes.value!,
        filename: fileName,
        contentType: MediaType(mimeMain, mimeSub),
      );

      request.files.add(multipartFile);

      debugPrint('uploadImageToServer -> fileName: $fileName, contentType: $mimeMain/$mimeSub, mimeType: $mimeType');

      final streamedResponse = await request.send();
      final status = streamedResponse.statusCode;
      final responseString = await streamedResponse.stream.bytesToString();

      debugPrint('uploadImageToServer status: $status');
      debugPrint('uploadImageToServer body: $responseString');

      if (status == 200 || status == 201) {
        final jsonData = json.decode(responseString);
        final url = _extractImageUrl(jsonData);
        if (url.isEmpty) {
          throw Exception('لم يُرجع السيرفر رابط الصورة في الاستجابة');
        }
        uploadedImageUrl.value = url;
        debugPrint('uploadedImageUrl: ${uploadedImageUrl.value}');
      } else {
        // إذا السيرفر أعطاك رسالة خطأ مفصلة فحاول إظهارها
        String serverMsg = 'Upload failed: $status';
        try {
          final parsed = json.decode(responseString);
          if (parsed is Map && parsed['message'] != null) serverMsg = parsed['message'].toString();
          if (parsed is Map && parsed['errors'] != null) serverMsg += '\n${parsed['errors'].toString()}';
        } catch (_) {}
        throw Exception(serverMsg);
      }
    } catch (e) {
      debugPrint('uploadImageToServer error: $e');
      _showSnackbar('خطأ', 'فشل رفع الصورة: $e', _SnackType.error);
      rethrow;
    }
  }

  String _extractImageUrl(dynamic jsonData) {
    try {
      if (jsonData is Map && jsonData['image_urls'] != null && jsonData['image_urls'] is List) {
        return List<String>.from(jsonData['image_urls']).first;
      } else if (jsonData is Map && jsonData['image_url'] != null) {
        return jsonData['image_url'].toString();
      } else if (jsonData is Map && jsonData['image'] != null) {
        return jsonData['image'].toString();
      } else if (jsonData is String) {
        return jsonData;
      }
    } catch (_) {}
    return '';
  }

  // ======== [ترجمة] ========
  Future<String> _translateToEnglish(String arabicText) async {
    try {
      final translation = await translator.translate(arabicText, from: 'ar', to: 'en');
      return translation.text;
    } catch (e) {
      debugPrint("Translation error: $e");
      return arabicText;
    }
  }

  // ======== [سناك بار احترافي] ========
  void _showSnackbar(String title, String message, _SnackType type, {IconData? icon, int seconds = 3}) {
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
      case _SnackType.info:
      default:
        gradient = LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600]);
        defaultIcon = Icons.info_outline;
        break;
    }

    final iconToShow = icon ?? defaultIcon;

    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        messageText: Text(message, style: const TextStyle(color: Colors.white)),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        backgroundGradient: gradient,
        icon: Icon(iconToShow, color: Colors.white),
        duration: Duration(seconds: seconds),
        isDismissible: true,
        shouldIconPulse: true,
        maxWidth: 800,
        snackStyle: SnackStyle.FLOATING,
      ),
    );
  }

  // ======== [جلب التصنيفات و الأب] ========
  Future<void> fetchCategories(String language) async {
    categoriesList.clear();
    isLoadingCategories.value = true;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories/$language'));
      debugPrint('fetchCategories status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          categoriesList.value = data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب التصنيفات', _SnackType.error);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', _SnackType.error);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب التصنيفات: $e', _SnackType.error);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchSubCategories({int? categoryId, required String language}) async {
    parentSubCategoriesList.clear();
    isLoadingParentSubCategories.value = true;
    final queryParams = <String, String>{'language': language, if (categoryId != null) 'category_id': categoryId.toString()};
    final uri = Uri.parse('$_baseUrl/subcategories').replace(queryParameters: queryParams);
    debugPrint('fetchSubCategories uri: $uri');
    try {
      final response = await http.get(uri);
      debugPrint('fetchSubCategories status: ${response.statusCode}');
      debugPrint('fetchSubCategories body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as List<dynamic>;
        parentSubCategoriesList.value = data.map((e) => SubcategoryLevelOne.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', _SnackType.error);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب التصنيفات الفرعية: $e', _SnackType.error);
    } finally {
      isLoadingParentSubCategories.value = false;
    }
  }

  Future<void> fetchSubCategoriesLevelTwo({int? parent1Id, required String language, String? searchName}) async {
    subCategoriesLevelTwoList.clear();
    isLoadingSubCategoriesLevelTwo.value = true;
    final queryParams = <String, String>{
      'language': language,
      if (parent1Id != null) 'sub_category_level_one_id': parent1Id.toString(),
      if (searchName != null && searchName.trim().isNotEmpty) 'name': searchName.trim(),
    };
    final uri = Uri.parse('$_baseUrl/subcategories-level-two').replace(queryParameters: queryParams);
    debugPrint('fetchSubCategoriesLevelTwo uri: $uri');
    try {
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      debugPrint('fetchSubCategoriesLevelTwo status: ${response.statusCode}');
      debugPrint('fetchSubCategoriesLevelTwo body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        final data = jsonResponse['data'] as List<dynamic>;
        subCategoriesLevelTwoList.value = data.map((e) => SubcategoryLevelTwo.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', _SnackType.error);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب التصنيفات الفرعية الثانية: $e', _SnackType.error);
    } finally {
      isLoadingSubCategoriesLevelTwo.value = false;
    }
  }

  // ======== [إنشاء تصنيف فرعي ثاني] ========
  Future<void> createSubCategoryLevelTwo(int parent1Id, String arabicName, {String? arabicDescription}) async {
    if (arabicName.isEmpty) {
      _showSnackbar('تحذير', 'الرجاء إدخال اسم التصنيف الفرعي الثاني', _SnackType.info);
      return;
    }

    isSaving.value = true;
    try {
      final englishName = await _translateToEnglish(arabicName);
      final slug = englishName.toLowerCase().replaceAll(' ', '-');

      if (imageBytes.value != null) {
        await uploadImageToServer();
      }

      final uri = Uri.parse('$_baseUrl/subcategories-two-store');
      final payload = {
        "sub_category_level_one_id": parent1Id,
        "slug": slug,
        "image": uploadedImageUrl.value.isNotEmpty ? uploadedImageUrl.value : null,
        "translations": [
          {"language": "ar", "name": arabicName},
          {"language": "en", "name": englishName},
        ],
      };

      debugPrint('createSubCategoryLevelTwo POST $uri');
      debugPrint('payload: ${json.encode(payload)}');

      final response = await http.post(uri, headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}, body: jsonEncode(payload));

      debugPrint('createSubCategoryLevelTwo status: ${response.statusCode}');
      debugPrint('createSubCategoryLevelTwo body: ${response.body}');

      final responseData = _safeDecode(response.body);
      final okStatus = response.statusCode == 200 || response.statusCode == 201;
      final successFlag = responseData is Map && ((responseData['status'] == 'success') || (responseData['success'] == true));

      if (okStatus && successFlag) {
        _showSnackbar('نجاح', 'تم إنشاء التصنيف الفرعي الثاني بنجاح', _SnackType.success);
        resetForm();
        String lang = 'ar';
        try {
          lang = Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
        } catch (_) {}
        await fetchSubCategoriesLevelTwo(parent1Id: parent1Id, language: lang);
      } else {
        String msg = 'فشل في إنشاء التصنيف الفرعي الثاني';
        if (responseData is Map) msg = (responseData['message'] ?? responseData['error'])?.toString() ?? msg;
        _showSnackbar('خطأ', msg, _SnackType.error);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء إنشاء التصنيف الفرعي الثاني: $e', _SnackType.error);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [تحديث] ========
TextEditingController levelTwoSlugController = TextEditingController();
TextEditingController levelTwoMetaTitleController = TextEditingController();
TextEditingController levelTwoMetaDescController = TextEditingController();

Future<void> updateSubCategoryLevelTwo(SubcategoryLevelTwo subCategory, int parent1Id, String newArabicName) async {
  if (newArabicName.trim().isEmpty) {
    _showSnackbar('تحذير', 'الرجاء إدخال اسم التصنيف الفرعي الثاني', _SnackType.info);
    return;
  }

  isSaving.value = true;
  try {
    final newEnglishName = await _translateToEnglish(newArabicName);

    // slug: استخدم المدخل اليدوي إن وُجد وإلا توليد من العربي
    String newSlug = levelTwoSlugController.text.trim();
    if (newSlug.isEmpty) {
      newSlug = newArabicName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'[\s_-]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
    }

    if (imageBytes.value != null) {
      await uploadImageToServer();
    }

    final Map<String, dynamic> updateData = {
      "sub_category_level_one_id": parent1Id,
      "slug": newSlug,
      "meta_title": levelTwoMetaTitleController.text.trim().isNotEmpty 
          ? levelTwoMetaTitleController.text.trim() 
          : newArabicName,
      "meta_description": levelTwoMetaDescController.text.trim().isNotEmpty
          ? levelTwoMetaDescController.text.trim()
          : newArabicName,
      "translations": [
        {"language": "ar", "name": newArabicName},
        {"language": "en", "name": newEnglishName},
      ],
    };

    if (uploadedImageUrl.value.isNotEmpty) updateData['image'] = uploadedImageUrl.value;

    // إزالة الحقول null لتقليل الباودي
    updateData.removeWhere((k, v) => v == null);

    final uri = Uri.parse('$_baseUrl/subcategories-level-two/update/${subCategory.id}');
    debugPrint('updateSubCategoryLevelTwo PUT $uri payload: ${json.encode(updateData)}');

    final response = await http.put(uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(updateData));

    debugPrint('updateSubCategoryLevelTwo status: ${response.statusCode}');
    debugPrint('updateSubCategoryLevelTwo body: ${response.body}');

    final responseData = _safeDecode(response.body);
    final successFlag = (response.statusCode == 200 || response.statusCode == 201) &&
        responseData is Map &&
        ((responseData['status'] == 'success') || (responseData['success'] == true));

    if (successFlag) {
      _showSnackbar('نجاح', 'تم تحديث التصنيف الفرعي الثاني بنجاح', _SnackType.success);
      resetForm();
      String lang = 'ar';
      try {
        lang = Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
      } catch (_) {}
      await fetchSubCategoriesLevelTwo(parent1Id: parent1Id, language: lang);
    } else if (response.statusCode == 422 && responseData is Map) {
      _showSnackbar('خطأ', (responseData['errors'] ?? responseData['message']).toString(), _SnackType.error);
    } else {
      String msg = 'فشل في تحديث التصنيف الفرعي الثاني';
      if (responseData is Map) msg = (responseData['message'] ?? responseData['error'])?.toString() ?? msg;
      _showSnackbar('خطأ', msg, _SnackType.error);
    }
  } catch (e) {
    _showSnackbar('خطأ', 'حدث خطأ أثناء تحديث التصنيف الفرعي الثاني: $e', _SnackType.error);
  } finally {
    isSaving.value = false;
  }
}


  // ======== [حذف] ========
  Future<void> deleteSubCategoryLevelTwo(int id, int parent1Id) async {
    isDeleting.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/subcategories-level-two/delete/$id');
      final response = await http.delete(uri, headers: {'Accept': 'application/json'});

      debugPrint('deleteSubCategoryLevelTwo status: ${response.statusCode}');
      debugPrint('deleteSubCategoryLevelTwo body: ${response.body}');

      final responseData = _safeDecode(response.body);
      final successFlag = response.statusCode == 200 && responseData is Map && ((responseData['status'] == 'success') || (responseData['success'] == true));

      if (successFlag) {
        _showSnackbar('نجاح', 'تم حذف التصنيف الفرعي الثاني بنجاح', _SnackType.success);
        resetForm();
        String lang = 'ar';
        try {
          lang = Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
        } catch (_) {}
        await fetchSubCategoriesLevelTwo(parent1Id: parent1Id, language: lang);
      } else {
        String msg = 'فشل في حذف التصنيف الفرعي الثاني';
        if (responseData is Map) msg = (responseData['message'] ?? responseData['error'])?.toString() ?? msg;
        _showSnackbar('خطأ', msg, _SnackType.error);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء حذف التصنيف الفرعي الثاني: $e', _SnackType.error);
    } finally {
      isDeleting.value = false;
    }
  }

  // ======== [reset] ========
  void resetForm() {
    imageBytes.value = null;
    imageFileName.value = '';
    imageFilePath.value = '';
    uploadedImageUrl.value = '';
    update(['subcategory_level_two_image']);
  }

  // ======== [مساعدة لفك JSON بأمان] ========
  dynamic _safeDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  // ======== [تحميل صورة من رابط (لمعاينة)] ========
  Future<void> loadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        imageBytes.value = response.bodyBytes;
        update(['subcategory_level_two_image']);
      }
    } catch (e) {
      debugPrint('فشل تحميل الصورة: $e');
    }
  }
}
