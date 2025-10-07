import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

import '../core/data/model/Attribute.dart';
import '../core/data/model/category.dart';

class AttributeController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
  // ======== [متغيّرات الحالة] ========
  RxList<Attribute> attributesList = <Attribute>[].obs;
  RxBool isLoadingAttributes = false.obs;
  RxBool isSaving = false.obs;
  RxList<Category> categoriesList = <Category>[].obs;
  RxBool isLoadingCategories = false.obs;

  RxBool isDeleting = false.obs;

  // ======== [دوال جلب البيانات] ========
  Future<void> fetchCategories(String language) async {
    categoriesList.clear();
    isLoadingCategories.value = true;

    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/categories/$language'
      ));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          categoriesList.value = data
              .map((category) => Category.fromJson(category as Map<String, dynamic>))
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

  // للمكتبة
  final translator = GoogleTranslator();

  // ======== [دوال الترجمة] ========
  Future<String> _translateToEnglish(String arabicText) async {
    try {
      final translation = await translator.translate(arabicText, from: 'ar', to: 'en');
      return translation.text;
    } catch (e) {
      print("Translation error: $e");
      return arabicText;
    }
  }

  // ======== [جلب كل الخصائص] ========
  Future<void> fetchAttributes({
    required String lang,
    int? categoryId,
    String? search,        // ← إضافة معامل البحث الاختياري
  }) async {
    attributesList.clear();
    isLoadingAttributes.value = true;

    try {
      // بناء معلمات الاستعلام
      final query = <String, String>{
        'lang': lang,
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      };

      final uri = Uri.parse('$_baseUrl/attributes').replace(queryParameters: query);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body) as Map<String, dynamic>;

        if (jsonResp['success'] == true) {
          final List data = jsonResp['attributes'] as List;
          attributesList.value = data
              .map((e) => Attribute.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _showSnackbar('خطأ', jsonResp['message'] ?? 'فشل جلب الخصائص', true);
          print(jsonResp['message']);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ اتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب الخصائص: $e', true);
      print(e);
    } finally {
      isLoadingAttributes.value = false;
    }
  }

  // ======== [إنشاء خاصية جديدة] ========
  Future<void> createAttribute({
    required String nameAr,
    required String valueType,
    required bool isShared,
    List<String>? optionsAr,
    int? categoryId,
    bool categoryIsRequired = false, // is_required في pivot عند الربط بالتصنيف
    bool attributeIsRequired = false, // required على مستوى الخاصية نفسها (الحقل الجديد)
  }) async {
    if (nameAr.isEmpty) {
      _showSnackbar('تحذير', 'الرجاء إدخال اسم الخاصية بالعربية', true);
      return;
    }
    if (valueType == 'options' && (optionsAr == null || optionsAr.isEmpty)) {
      _showSnackbar('تحذير', 'الرجاء إدخال قيم الخيارات العربية', true);
      return;
    }

    isSaving.value = true;
    try {
      final nameEn = await _translateToEnglish(nameAr);

      final body = {
        'name_ar': nameAr,
        'name_en': nameEn,
        'value_type': valueType,
        'is_shared': isShared ? 1 : 0,
        // أرسل الحقل required كـ boolean (backend يقبل boolean)
        'required': attributeIsRequired ? 1 : 0,
        if (optionsAr != null)
          'options': await Future.wait(optionsAr.map((optAr) async {
            final optEn = await _translateToEnglish(optAr);
            return {
              'value_ar': optAr,
              'value_en': optEn,
              'display_order': 0,
            };
          })),
        if (categoryId != null) 'category_id': categoryId,
        if (categoryId != null) 'is_required': categoryIsRequired ? 1 : 0,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/attributes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // طباعة للتتبع
      print('🚨 Status code: ${response.statusCode}');
      print('🚨 Response headers: ${response.headers}');
      print('🚨 Raw response body:\n${response.body}');

      if (response.statusCode != 201) {
        _showSnackbar('خطأ', 'خطأ في السيرفر (${response.statusCode})', true);
        return;
      }

      late Map<String, dynamic> respData;
      try {
        respData = json.decode(response.body) as Map<String, dynamic>;
      } catch (jsonError) {
        print('🚨 JSON decode error: $jsonError');
        _showSnackbar('خطأ', 'رد السيرفر ليس JSON صالحاً، انظر الـ console', true);
        return;
      }

      if (respData.containsKey('errors')) {
        print('🚨 Validation errors: ${respData['errors']}');
      }
      if (respData.containsKey('message')) {
        print('🚨 Message: ${respData['message']}');
      }
      if (respData.containsKey('error')) {
        print('🚨 Exception message: ${respData['error']}');
      }

      if (respData['success'] == true) {
        _showSnackbar('نجاح', 'تم إنشاء الخاصية بنجاح', false);
        // جلب من جديد - استخدم نفس اللغة التي تعمل بها الواجهة (هنا 'ar' كمثال)
        await fetchAttributes(lang: 'ar');
      } else {
        final errMsg = respData['message'] ??
            (respData['errors'] != null
                ? respData['errors'].toString()
                : 'فشل إنشاء الخاصية');
        _showSnackbar('خطأ', errMsg, true);
      }
    } catch (e) {
      print('🚨 Exception during createAttribute: $e');
      _showSnackbar('خطأ', 'حدث خطأ أثناء إنشاء الخاصية: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [تعديل خاصية موجودة] ========
  Future<void> updateAttribute({
    required int id,
    String? nameAr,
    String? valueType,
    bool? isShared,
    List<String>? optionsAr,
    bool? attributeIsRequired, // إرسال required عند التعديل إن أردنا تغييره
  }) async {
    isSaving.value = true;
    try {
      final body = <String, dynamic>{};
      if (nameAr != null) {
        body['name_ar'] = nameAr;
        body['name_en'] = await _translateToEnglish(nameAr);
      }
      if (valueType != null) body['value_type'] = valueType;
      if (isShared != null) body['is_shared'] = isShared ? 1 : 0;
      if (attributeIsRequired != null) body['required'] = attributeIsRequired ? 1 : 0;
      if (valueType == 'options' && optionsAr != null) {
        body['options'] = await Future.wait(optionsAr.map((optAr) async {
          final optEn = await _translateToEnglish(optAr);
          return {
            'value_ar': optAr,
            'value_en': optEn,
            'display_order': 0,
          };
        }));
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/attributes/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final respData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && respData['success'] == true) {
        _showSnackbar('نجاح', 'تم تعديل الخاصية بنجاح', false);
        await fetchAttributes(lang: 'ar');
      } else {
        _showSnackbar('خطأ', respData['message'] ?? 'فشل تعديل الخاصية', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء تعديل الخاصية: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [حذف خاصية] ========
  Future<void> deleteAttribute(int id) async {
    isSaving.value = true;
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/attributes/$id'));
      final respData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && respData['success'] == true) {
        _showSnackbar('نجاح', 'تم حذف الخاصية بنجاح', false);
fetchAttributes(lang: "ar");
      } else {
        _showSnackbar('خطأ', respData['message'] ?? 'فشل حذف الخاصية', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء حذف الخاصية: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [ربط خاصية بتصنيف رئيسي] ========
  Future<void> attachAttribute({
    required int attributeId,
    required int categoryId,
    bool isRequired = false,
  }) async {
    isSaving.value = true;
    try {
      final body = {
        'category_id': categoryId,
        'is_required': isRequired ? 1 : 0,
      };
      final response = await http.post(
        Uri.parse('$_baseUrl/attributes/$attributeId/attach'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final respData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && respData['success'] == true) {
        _showSnackbar('نجاح', 'تم ربط الخاصية بالتصنيف بنجاح', false);
      } else {
        _showSnackbar('خطأ', respData['message'] ?? 'فشل الربط', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء الربط: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [مساعد عرض الرسائل] ========
  void _showSnackbar(String title, String msg, bool isError) {
    // نفترض implement ShowSnackbar elsewhere
    Get.snackbar(title, msg, backgroundColor: isError ? Colors.red : Colors.green);
  }
}
