import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

import '../core/data/model/Attribute.dart';
import '../core/data/model/category.dart';

class AttributeController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  // الحالة
  RxList<Attribute> attributesList = <Attribute>[].obs;
  RxBool isLoadingAttributes = false.obs;
  RxBool isSaving = false.obs;
  RxList<Category> categoriesList = <Category>[].obs;
  RxBool isLoadingCategories = false.obs;

  final translator = GoogleTranslator();

  // جلب التصنيفات
  Future<void> fetchCategories(String language) async {
    categoriesList.clear();
    isLoadingCategories.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/categories/$language');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          categoriesList.value = data
              .map((category) => Category.fromJson(category as Map<String, dynamic>))
              .toList();
        } else {
          _sb('خطأ', jsonResponse['message'] ?? 'فشل جلب التصنيفات', true);
        }
      } else {
        _sb('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _sb('خطأ', 'حدث خطأ أثناء جلب التصنيفات: $e', true);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ترجمة بسيطة (تستخدم في الإنشاء فقط)
  Future<String> _translateToEnglish(String arabicText) async {
    try {
      final t = await translator.translate(arabicText, from: 'ar', to: 'en');
      return t.text;
    } catch (_) {
      return arabicText;
    }
  }

  // جلب الخصائص
  Future<void> fetchAttributes({
    required String lang,
    int? categoryId,
    String? search,
  }) async {
    attributesList.clear();
    isLoadingAttributes.value = true;
    try {
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
          attributesList.value = data.map((e) => Attribute.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          _sb('خطأ', jsonResp['message'] ?? 'فشل جلب الخصائص', true);
        }
      } else {
        _sb('خطأ', 'خطأ اتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _sb('خطأ', 'حدث خطأ أثناء جلب الخصائص: $e', true);
    } finally {
      isLoadingAttributes.value = false;
    }
  }

  // إنشاء خاصية
  Future<void> createAttribute({
    required String nameAr,
    required String valueType,
    required bool isShared,
    List<String>? optionsAr,
    int? categoryId,
    bool categoryIsRequired = false,
    bool attributeIsRequired = false,
  }) async {
    if (nameAr.isEmpty) {
      _sb('تحذير', 'الرجاء إدخال اسم الخاصية بالعربية', true);
      return;
    }
    if (valueType == 'options' && (optionsAr == null || optionsAr.where((e) => e.trim().isNotEmpty).isEmpty)) {
      _sb('تحذير', 'الرجاء إدخال قيم الخيارات', true);
      return;
    }

    isSaving.value = true;
    try {
      final nameEn = await _translateToEnglish(nameAr);
      final Map<String, dynamic> body = {
        'name_ar': nameAr.trim(),
        'name_en': nameEn,
        'value_type': valueType,
        'is_shared': isShared,
        'required': attributeIsRequired,
        if (optionsAr != null)
          'options': await Future.wait(
            optionsAr.where((o) => o.trim().isNotEmpty).map((optAr) async {
              final optEn = await _translateToEnglish(optAr);
              return {'value_ar': optAr.trim(), 'value_en': optEn, 'display_order': 0};
            }),
          ),
        if (categoryId != null) 'category_id': categoryId,
        if (categoryId != null) 'is_required': categoryIsRequired,
      };

      final uri = Uri.parse('$_baseUrl/attributes');
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      final respData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201 && respData['success'] == true) {
        _sb('نجاح', 'تم إنشاء الخاصية بنجاح', false);
        await fetchAttributes(lang: 'ar');
      } else {
        _sb('خطأ', respData['message'] ?? 'فشل إنشاء الخاصية', true);
      }
    } catch (e) {
      _sb('خطأ', 'Exception أثناء الإنشاء: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // تعديل خاصية
  // sendOptions = true فقط عند تعديل الخيارات فعليًا
  Future<void> updateAttribute({
    required int id,
    String? nameAr,
    String? valueType,
    bool? isShared,
    bool? attributeIsRequired,
    List<Map<String, dynamic>>? optionsWithIds, // [{id?, value_ar, value_en, display_order}]
    bool sendOptions = false,
  }) async {
    isSaving.value = true;
    try {
      final Map<String, dynamic> body = {};
      if (nameAr != null) {
        body['name_ar'] = nameAr.trim();
        body['name_en'] = nameAr.trim(); // حافظ على نفس النص (أو ترجم إذا تحب)
      }
      if (valueType != null) body['value_type'] = valueType;
      if (isShared != null) body['is_shared'] = isShared;
      if (attributeIsRequired != null) body['required'] = attributeIsRequired;

      if (sendOptions && valueType == 'options' && optionsWithIds != null) {
        final cleaned = optionsWithIds.where((o) {
          final va = (o['value_ar'] ?? '').toString().trim();
          final ve = (o['value_en'] ?? '').toString().trim();
          return va.isNotEmpty && ve.isNotEmpty;
        }).toList();

        if (cleaned.isEmpty) {
          _sb('تحذير', 'لا يمكن إرسال خيارات فارغة', true);
          isSaving.value = false;
          return;
        }

        body['options'] = cleaned.map((o) {
          return {
            if (o['id'] != null) 'id': o['id'],
            'value_ar': o['value_ar'].toString().trim(),
            'value_en': o['value_en'].toString().trim(),
            'display_order': o['display_order'] ?? 0,
          };
        }).toList();
      }

      final uri = Uri.parse('$_baseUrl/attributes/$id');
      final response = await http.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      final respData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && respData['success'] == true) {
        _sb('نجاح', 'تم تعديل الخاصية بنجاح', false);
        await fetchAttributes(lang: 'ar');
      } else {
        _sb('خطأ', respData['message'] ?? 'فشل تعديل الخاصية', true);
      }
    } catch (e) {
      _sb('خطأ', 'حدث خطأ أثناء التعديل: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // حذف خاصية
  Future<void> deleteAttribute(int id) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/attributes/$id');
      final response = await http.delete(uri);
      final respData = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && respData['success'] == true) {
        _sb('نجاح', 'تم حذف الخاصية بنجاح', false);
        await fetchAttributes(lang: "ar");
      } else {
        _sb('خطأ', respData['message'] ?? 'فشل حذف الخاصية', true);
      }
    } catch (e) {
      _sb('خطأ', 'حدث خطأ أثناء حذف الخاصية: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ربط خاصية بتصنيف
  Future<void> attachAttribute({
    required int attributeId,
    required int categoryId,
    bool isRequired = false,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/attributes/$attributeId/attach');
      final body = {'category_id': categoryId, 'is_required': isRequired};
      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      final respData = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && respData['success'] == true) {
        _sb('نجاح', 'تم ربط الخاصية بالتصنيف بنجاح', false);
      } else {
        _sb('خطأ', respData['message'] ?? 'فشل الربط', true);
      }
    } catch (e) {
      _sb('خطأ', 'حدث خطأ أثناء الربط: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // Snackbar مختصر
  void _sb(String title, String msg, bool isError) {
    Get.snackbar(title, msg, backgroundColor: isError ? Colors.red : Colors.green, colorText: Colors.white);
  }
}
