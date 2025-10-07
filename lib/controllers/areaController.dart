// lib/controllers/AreaController.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../core/data/model/Area.dart';
import '../core/data/model/City.dart';
import '../core/localization/changelanguage.dart';

enum SnackType { success, error, info }

class AreaController extends GetxController {
  final RxList<Area> areas = <Area>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  
  final String baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  @override
  void onInit() {
    super.onInit();
  }

  /// دالة مساعدة لعرض السناك بار
  void _showSnack({
    required String title,
    required String message,
    SnackType type = SnackType.info,
    IconData? icon,
    int seconds = 3,
  }) {
    final LinearGradient gradient;
    final Color textColor = Colors.white;
    switch (type) {
      case SnackType.success:
        gradient = LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400]);
        break;
      case SnackType.error:
        gradient = LinearGradient(colors: [Colors.red.shade700, Colors.red.shade400]);
        break;
      case SnackType.info:
      default:
        gradient = LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]);
        break;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundGradient: gradient,
      colorText: textColor,
      icon: icon != null ? Icon(icon, color: Colors.white) : null,
      shouldIconPulse: true,
      duration: Duration(seconds: seconds),
      maxWidth: 800,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutQuad,
      reverseAnimationCurve: Curves.easeInQuad,
      snackStyle: SnackStyle.FLOATING,
    );
  }


  /// إنشاء منطقة جديدة
  Future<bool> createArea({
    required int cityId,
    required String name,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$baseUrl/areas');
      final Map<String, dynamic> payload = {
        'city_id': cityId,
        'name': name.trim(),
      };

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final newArea = Area.fromJson(json.decode(res.body));
        areas.add(newArea);
        _showSnack(
          title: 'تمت الإضافة', 
          message: 'تم إضافة المنطقة بنجاح', 
          type: SnackType.success,
          icon: Icons.check_circle
        );
        return true;
      } else {
        _showSnack(
          title: 'خطأ', 
          message: 'فشل إضافة المنطقة. الحالة: ${res.statusCode}', 
          type: SnackType.error, 
          icon: Icons.error_outline
        );
        return false;
      }
    } catch (e) {
      _showSnack(
        title: 'استثناء', 
        message: 'حدث خطأ أثناء إضافة المنطقة: $e', 
        type: SnackType.error, 
        icon: Icons.error
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// تحديث منطقة
  Future<bool> updateArea({
    required int id,
    required String name,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$baseUrl/areas/$id');
      final Map<String, dynamic> payload = {
        'name': name.trim(),
      };

      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode == 200) {
        final updatedArea = Area.fromJson(json.decode(res.body));
        final index = areas.indexWhere((a) => a.id == id);
        if (index != -1) areas[index] = updatedArea;
        _showSnack(
          title: 'تم التحديث', 
          message: 'تم تحديث المنطقة بنجاح', 
          type: SnackType.success,
          icon: Icons.edit
        );
        return true;
      } else {
        _showSnack(
          title: 'خطأ', 
          message: 'فشل تحديث المنطقة. الحالة: ${res.statusCode}', 
          type: SnackType.error, 
          icon: Icons.error_outline
        );
        return false;
      }
    } catch (e) {
      _showSnack(
        title: 'استثناء', 
        message: 'حدث خطأ أثناء تحديث المنطقة: $e', 
        type: SnackType.error, 
        icon: Icons.error
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// حذف منطقة
  Future<bool> deleteArea({
    required int id,
  }) async {
    isDeleting.value = true;
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/areas/$id'),
      );

      if (res.statusCode == 200) {
        areas.removeWhere((area) => area.id == id);
        _showSnack(
          title: 'تم الحذف', 
          message: 'تم حذف المنطقة بنجاح', 
          type: SnackType.success,
          icon: Icons.delete_forever
        );
        return true;
      } else {
        _showSnack(
          title: 'خطأ', 
          message: 'فشل حذف المنطقة. الحالة: ${res.statusCode}', 
          type: SnackType.error, 
          icon: Icons.error_outline
        );
        return false;
      }
    } catch (e) {
      _showSnack(
        title: 'استثناء', 
        message: 'حدث خطأ أثناء حذف المنطقة: $e', 
        type: SnackType.error, 
        icon: Icons.error
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  static const _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api/cities';

  final RxList<TheCity> citiesList = <TheCity>[].obs;
  final Rxn<TheCity> city = Rxn<TheCity>();

  Map<String, String> _defaultHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }
  Future<void> fetchCities({
    required String country,
    required String language,
    String? token,
  }) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(country)}/${Uri.encodeComponent(language)}');
      final res = await http.get(uri, headers: _defaultHeaders(token: token));

      if (res.statusCode == 200) {
        final List<dynamic> dataList = json.decode(res.body);
        final list = dataList.map((e) => TheCity.fromJson(e)).toList();
        citiesList.assignAll(list);

        if (list.isNotEmpty) {
          city.value = list.first;
        } else {
          city.value = null;
          _showSnack(title: 'تنبيه', message: 'لا توجد مدن في هذه الدولة/اللغة', type: SnackType.info, icon: Icons.info_outline);
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل جلب المدن. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء جلب المدن: $e', type: SnackType.error, icon: Icons.error);
    } finally {
      isLoading.value = false;
    }
  }

   Future<void> fetchAreas({
    int? cityId,
    int? perPage,
    String? token,
  }) async {
    isLoading.value = true;
    try {
      final Uri baseUri = Uri.parse('$baseUrl/areas');
      final Map<String, String> queryParams = {};

      if (cityId != null) queryParams['city_id'] = cityId.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();

      final uri = queryParams.isNotEmpty ? baseUri.replace(queryParameters: queryParams) : baseUri;

      final res = await http.get(uri, headers: _defaultHeaders(token: token));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);

        List<dynamic> dataList = [];

        // حالات الاستجابة المحتملة:
        // 1) استجابة بشكل { success: true, data: [...] }
        // 2) استجابة مباشرةً كمصفوفة [...]
        // 3) استجابة مع meta pagination
        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded['data'] != null && decoded['data'] is List) {
            dataList = decoded['data'];
          } else if (decoded['success'] == true && decoded['data'] == null) {
            // قد يكون الخطأ أو مصفوفة فارغة
            dataList = [];
          } else {
            // حالة غير متوقعة: نحاول البحث عن المفتاح 'data' أو إرجاع مصفوفة فارغة
            dataList = [];
          }
        }

        final parsed = dataList.map((e) {
          if (e is Map<String, dynamic>) return Area.fromJson(e);
          return Area.fromJson(Map<String, dynamic>.from(e));
        }).toList();

        areas.assignAll(parsed);

        if (areas.isEmpty) {
          _showSnack(
            title: 'معلومة',
            message: 'لا توجد مناطق مطابقة للمعايير.',
            type: SnackType.info,
            icon: Icons.info_outline,
          );
        }
      } else if (res.statusCode == 400) {
        // خطأ تحقق (مثلاً city_id غير صحيح)
        final body = json.decode(res.body);
        _showSnack(
          title: 'خطأ',
          message: body['error'] ?? body['message'] ?? 'طلب غير صحيح (${res.statusCode})',
          type: SnackType.error,
          icon: Icons.error_outline,
        );
      } else {
        _showSnack(
          title: 'خطأ',
          message: 'فشل جلب المناطق. الحالة: ${res.statusCode}',
          type: SnackType.error,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء جلب المناطق: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
    } finally {
      isLoading.value = false;
    }
  }


  // Observable لقائمة المناطق الجارية

  // معرف المنطقة المحدد (مثل ما كنت تستخدم)
  final idOfArea = Rx<int?>(null);

  // حالة التحميل للاستخدام في الواجهات

  // كاش داخلي: المفتاح '<cityId>_<lang>'
  final Map<String, List<Area>> _cache = {};

  // غيّر إلى الـ base URL عندك

  // (اختياري) توكن المصادقة إذا مطلوب
  String? authToken;

  /// يبني مفتاح الكاش
  String _cacheKey(int cityId, String lang) => '${cityId}_$lang';

  /// جلب المناطق للمدينة من الـ API.
  /// - يعيد true لو نجح، false لو فشل.
  /// - يستخدم الكاش ما لم تطلب forceRefresh = true.
  Future<bool> fetchAreasGet(int cityId, {bool forceRefresh = false}) async {
    final langCode = _safeLangCode();
    final key = _cacheKey(cityId, langCode);

    // إرجاع من الكاش إن وجد ولم يُطلب تحديث قسري
    if (!forceRefresh && _cache.containsKey(key)) {
      areas.value = _cache[key]!;
      return true;
    }

    isLoading.value = true;
    try {
      final uri = Uri.parse('$baseUrl/areas/city/$cityId')
          .replace(queryParameters: {'lang': langCode});

      final headers = <String, String>{
        'Accept': 'application/json',
        'Accept-Language': langCode,
      };
      if (authToken != null && authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final body = response.body;
        final decoded = json.decode(body);

        // نتعامل مع احتمال أن الـ API يرجع كائن يحتوي على data أو يرجع مباشرة مصفوفة
        List<dynamic> list;
        if (decoded is Map && decoded['data'] is List) {
          list = List<dynamic>.from(decoded['data']);
        } else if (decoded is List) {
          list = List<dynamic>.from(decoded);
        } else {
          // شكّل غير متوقع
          print('AreaController.fetchAreas: unexpected response structure');
          isLoading.value = false;
          return false;
        }

        final fetched = list
            .map((e) => Area.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        // خزّن في الكاش وحدّث الـ observable
        _cache[key] = fetched;
        areas.value = fetched;
        isLoading.value = false;
        return true;
      } else {
        // خطأ من السيرفر — اطبع لمساعدة التصحيح
        print(
            'AreaController.fetchAreas failed: status=${response.statusCode}, body=${response.body}');
        isLoading.value = false;
        return false;
      }
    } on TimeoutException catch (e) {
      print('AreaController.fetchAreas timeout: $e');
      isLoading.value = false;
      return false;
    } catch (e) {
      print('AreaController.fetchAreas exception: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// يعيد اسم المنطقة بحسب المعرف (يدعم البحث في القوائم المحمّلة والكاش)
  String? getAreaNameById(int? areaId) {
    if (areaId == null) return null;

    // 1) ابحث في القائمة الحالية أولاً
    final foundCurrent = areas.firstWhereOrNull((a) => a.id == areaId);
    if (foundCurrent != null) return foundCurrent.name;

    // 2) ابحث في الكاش
    for (final list in _cache.values) {
      final f = list.firstWhereOrNull((a) => a.id == areaId);
      if (f != null) return f.name;
    }

    return null;
  }



  /// يفرّغ كاش لمدينة واحدة (حسب اللغة الحالية)
  void invalidateCityCache(int cityId) {
    final lang = _safeLangCode();
    _cache.remove(_cacheKey(cityId, lang));
  }

  /// يفرّغ كل الكاش
  void clearCache() {
    _cache.clear();
  }

  /// يحصل على المناطق من الكاش أو يجلبها من السيرفر إن لم تكن موجودة
  Future<List<Area>> getAreasOrFetch(int cityId) async {
    final lang = _safeLangCode();
    final key = _cacheKey(cityId, lang);
    if (_cache.containsKey(key)) return _cache[key]!;
    final ok = await fetchAreasGet(cityId);
    return ok ? (_cache[key] ?? []) : [];
  }

  /// مساعدة: الحصول على كود اللغة بأمان
  String _safeLangCode() {
    try {
      final code =
          Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
      return (code == null || code.isEmpty) ? 'ar' : code;
    } catch (_) {
      return 'ar';
    }
  }

  /// اختياري: تعيّن التوكن لو احتجت للمصادقة
  void setAuthToken(String token) {
    authToken = token;
  }

  /// اختبارات/تجارب سريعة: طباعة حالة الكنترولر
  @override
  void onClose() {
    // نظف إذا لزم
    super.onClose();
  }


  // معرف المنطقة المحدد (مثل ما كنت تستخدم)

  // حالة التحميل للاستخدام في الواجهات

  // كاش داخلي: المفتاح '<cityId>_<lang>'

  // غيّر إلى الـ base URL عندك

  // (اختياري) توكن المصادقة إذا مطلوب

  /// يبني مفتاح الكاش
    Future<bool> fetchAreasEdit(int cityId, {bool forceRefresh = false}) async {
    final langCode = _safeLangCode();
    final key = _cacheKey(cityId, langCode);

    // إرجاع من الكاش إن وجد ولم يُطلب تحديث قسري
    if (!forceRefresh && _cache.containsKey(key)) {
      areas.value = _cache[key]!;
      return true;
    }

    isLoading.value = true;
    try {
      final uri = Uri.parse('$baseUrl/areas/city/$cityId')
          .replace(queryParameters: {'lang': langCode});

      final headers = <String, String>{
        'Accept': 'application/json',
        'Accept-Language': langCode,
      };
      if (authToken != null && authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final body = response.body;
        final decoded = json.decode(body);

        // نتعامل مع احتمال أن الـ API يرجع كائن يحتوي على data أو يرجع مباشرة مصفوفة
        List<dynamic> list;
        if (decoded is Map && decoded['data'] is List) {
          list = List<dynamic>.from(decoded['data']);
        } else if (decoded is List) {
          list = List<dynamic>.from(decoded);
        } else {
          // شكّل غير متوقع
          print('AreaController.fetchAreas: unexpected response structure');
          isLoading.value = false;
          return false;
        }

        final fetched = list
            .map((e) => Area.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        // خزّن في الكاش وحدّث الـ observable
        _cache[key] = fetched;
        areas.value = fetched;
        isLoading.value = false;
        return true;
      } else {
        // خطأ من السيرفر — اطبع لمساعدة التصحيح
        print(
            'AreaController.fetchAreas failed: status=${response.statusCode}, body=${response.body}');
        isLoading.value = false;
        return false;
      }
    } on TimeoutException catch (e) {
      print('AreaController.fetchAreas timeout: $e');
      isLoading.value = false;
      return false;
    } catch (e) {
      print('AreaController.fetchAreas exception: $e');
      isLoading.value = false;
      return false;
    }
  }



}

/// امتداد مفيد لو لم يكن لديك في المشروع
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }


  /////////
  

 
}