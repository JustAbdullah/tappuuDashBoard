// lib/controllers/ColorController.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/model/AppColor.dart';

enum SnackType { success, error, info }

class ColorAndCurrencyController extends GetxController {
  static const _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  // حالة التحميل العامة
  final isLoading = false.obs;
  final isGetFirstTime = false.obs;

  // -----------------------
  // الألوان
  // -----------------------
  final RxList<AppColor> colorsList = <AppColor>[].obs;
  final Rxn<AppColor> color = Rxn<AppColor>();

  // اللون الافتراضي (لو لم يُحدد)
  final Color defaultColor = const Color(0xFF2D5E8C);
  final String defaultHex = '#2D5E8C';

  // -----------------------
  // العملات
  // -----------------------
  final String _baseUrlCurr = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api/v1';
  final RxList<Map<String, dynamic>> currencies = <Map<String, dynamic>>[].obs;
  final currentCurrency = 'SYP'.obs; // رمز العملة المختارة
  final isCurrenciesLoading = false.obs;

  // -----------------------
  // Helpers / Headers
  // -----------------------
  Map<String, String> _defaultHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // -----------------------
  // Snackbar helper (احترافي)
  // -----------------------
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

  // =======================
  // Colors: CRUD
  // =======================

  Future<void> fetchColors({String? token}) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/colors');
      final res = await http.get(uri, headers: _defaultHeaders(token: token));

      if (res.statusCode == 200) {
        final result = json.decode(res.body) as Map<String, dynamic>;
        if (result['success'] == true && result['data'] != null) {
          final list = (result['data'] as List)
              .map((e) => AppColor.fromJson(e as Map<String, dynamic>))
              .toList();
          colorsList.assignAll(list);

          // لو في لون اسمه 'primary' حدّث العنصر المختار أو غيره حسب حاجتك
         final primary = list.firstWhere(
  (c) => c.name.toLowerCase() == 'primary',
  orElse: () => list.isNotEmpty
      ? list.first
      : AppColor(id: 0, name: 'primary', hexCode: defaultHex),
);
color.value = primary;

        } else {
          colorsList.clear();
          color.value = null;
          _showSnack(title: 'تنبيه', message: 'لا توجد ألوان حالياً', type: SnackType.info, icon: Icons.info_outline);
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل جلب الألوان. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء جلب الألوان: $e', type: SnackType.error, icon: Icons.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<AppColor?> fetchColorById({required int id, String? token}) async {
    // حاول من الذاكرة أولاً
    final local = colorsList.firstWhereOrNull((c) => c.id == id);
    if (local != null) {
      color.value = local;
      return local;
    }

    // في حال أردت جلب من السيرفر، أضف راوت show في الباك وتفعّله هنا.
    return null;
  }

  Future<bool> createColor({
    required String name,
    required String hexCode,
    String? token,
  }) async {
    isLoading.value = true;
    try {
      if (name.trim().isEmpty) {
        _showSnack(title: 'تنبيه', message: 'اسم اللون مطلوب.', type: SnackType.error, icon: Icons.error_outline);
        return false;
      }
      String hex = hexCode.trim();
      if (!hex.startsWith('#')) hex = '#$hex';

      final uri = Uri.parse('$_baseUrl/colors/store');
      final body = json.encode({'name': name.trim(), 'hex_code': hex});
      final res = await http.post(uri, headers: _defaultHeaders(token: token), body: body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final result = json.decode(res.body) as Map<String, dynamic>;
        if (result['success'] == true && result['data'] != null) {
          final created = AppColor.fromJson(result['data'] as Map<String, dynamic>);
          colorsList.add(created);
          color.value = created;
          _showSnack(title: 'تمت الإضافة', message: 'تم إنشاء اللون بنجاح.', type: SnackType.success, icon: Icons.check_circle);
          return true;
        } else {
          _showSnack(title: 'فشل', message: result['message']?.toString() ?? 'فشل الإضافة', type: SnackType.error, icon: Icons.error_outline);
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل الإضافة. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء الإضافة: $e', type: SnackType.error, icon: Icons.error);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> updateColor({
    required int id,
    String? name,
    String? hexCode,
    String? token,
  }) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/colors/update/$id');

      final Map<String, dynamic> payload = {};
      if (name != null) payload['name'] = name.trim();
      if (hexCode != null) {
        String hex = hexCode.trim();
        if (!hex.startsWith('#')) hex = '#$hex';
        payload['hex_code'] = hex;
      }

      if (payload.isEmpty) {
        _showSnack(title: 'تنبيه', message: 'لا بيانات للتحديث.', type: SnackType.info, icon: Icons.info_outline);
        return false;
      }

      final res = await http.post(uri, headers: _defaultHeaders(token: token), body: json.encode(payload));

      if (res.statusCode == 200) {
        final result = json.decode(res.body) as Map<String, dynamic>;
        if (result['success'] == true && result['data'] != null) {
          final updated = AppColor.fromJson(result['data'] as Map<String, dynamic>);
          final idx = colorsList.indexWhere((c) => c.id == updated.id);
          if (idx >= 0) colorsList[idx] = updated;
          color.value = updated;
          _showSnack(title: 'تم التعديل', message: 'تم تحديث اللون بنجاح.', type: SnackType.success, icon: Icons.edit);
          return true;
        } else {
          _showSnack(title: 'فشل', message: result['message']?.toString() ?? 'فشل التعديل', type: SnackType.error, icon: Icons.error_outline);
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل التعديل. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء التعديل: $e', type: SnackType.error, icon: Icons.error);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> deleteColor({required int id, String? token}) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/colors/delete/$id');
      final res = await http.delete(uri, headers: _defaultHeaders(token: token));

      if (res.statusCode == 200) {
        final result = json.decode(res.body) as Map<String, dynamic>;
        if (result['success'] == true) {
          colorsList.removeWhere((c) => c.id == id);
          if (color.value != null && color.value!.id == id) color.value = null;
          _showSnack(title: 'تم الحذف', message: result['message']?.toString() ?? 'تم حذف اللون بنجاح.', type: SnackType.success, icon: Icons.delete_forever);
          return true;
        } else {
          _showSnack(title: 'فشل', message: result['message']?.toString() ?? 'فشل الحذف', type: SnackType.error, icon: Icons.error_outline);
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل الحذف. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء الحذف: $e', type: SnackType.error, icon: Icons.error);
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  // -----------------------
  // Color helpers
  // -----------------------
  Color getColorByName(String name) {
    final found = colorsList.firstWhereOrNull((c) => c.name.toLowerCase() == name.toLowerCase());
    if (found != null) return found.toColor();
    return defaultColor;
  }

  Color colorFromHex(String? hexCode) {
    try {
      if (hexCode == null || hexCode.trim().isEmpty) return defaultColor;
      String hex = hexCode.replaceFirst('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  // =======================
  // Currencies: CRUD & operations
  // =======================

  /// جلب كل العملات (القاعدة أولاً كما في الباك)
  Future<void> fetchCurrencies({String? token}) async {
    isCurrenciesLoading.value = true;
    try {
      final res = await http.get(Uri.parse("$_baseUrlCurr/currencies"), headers: _defaultHeaders(token: token));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          currencies.value = List<Map<String, dynamic>>.from(data['data'] as List);
          // اضبط العملة الحالية إذا كانت محفوظة أو افتراضي
          await _loadSavedCurrency();
          // لو العملة الحالية غير موجودة في القائمة، اختر الأولى (القاعدة)
          final exists = currencies.firstWhereOrNull((c) => c['code'] == currentCurrency.value);
          if (exists == null && currencies.isNotEmpty) {
            currentCurrency.value = currencies.first['code']?.toString() ?? 'SYP';
            await _saveCurrentCurrency(currentCurrency.value);
          }
        } else {
          currencies.clear();
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل جلب العملات. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء جلب العملات: $e', type: SnackType.error, icon: Icons.error);
    } finally {
      isCurrenciesLoading.value = false;
    }
  }

  /// جلب عملة مفردة (show)
  Future<Map<String, dynamic>?> fetchCurrencyById(dynamic idOrCode, {String? token}) async {
    try {
      final res = await http.get(Uri.parse("$_baseUrlCurr/currencies/$idOrCode"), headers: _defaultHeaders(token: token));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          return Map<String, dynamic>.from(body['data']);
        }
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'خطأ أثناء جلب العملة: $e', type: SnackType.error, icon: Icons.error);
    }
    return null;
  }

  /// إنشاء عملة جديدة
  Future<bool> createCurrency({
    required String name,
    required String code,
    required double rate,
    String? symbol,
    bool isBase = false,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrlCurr/currencies");
      final body = jsonEncode({
        'name': name.trim(),
        'code': code.trim().toUpperCase(),
        'symbol': symbol,
        'rate': rate,
        'is_base': isBase ? 1 : 0,
      });

      final res = await http.post(uri, headers: _defaultHeaders(token: token), body: body);
      final decoded = jsonDecode(res.body);

      if ((res.statusCode == 200 || res.statusCode == 201) && decoded['success'] == true) {
        // إعادة جلب العملات لضمان تناسق الـ rates لو تم تعيين قاعدة جديدة
        await fetchCurrencies(token: token);
        _showSnack(title: 'نجاح', message: 'تم إنشاء العملة بنجاح', type: SnackType.success, icon: Icons.check_circle);
        return true;
      } else {
        _showSnack(title: 'فشل', message: decoded['message'] ?? (decoded['errors']?.toString() ?? 'فشل إنشاء العملة'), type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء إنشاء العملة: $e', type: SnackType.error, icon: Icons.error);
    }
    return false;
  }

  /// تعديل عملة (لا يسمح بتغيير rate للقاعدة هنا بحسب الباك)
  Future<bool> updateCurrency({
    required dynamic idOrCode,
    String? name,
    String? code,
    String? symbol,
    double? rate,
    bool? isBase,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrlCurr/currencies/$idOrCode");
      final Map<String, dynamic> payload = {};
      if (name != null) payload['name'] = name.trim();
      if (code != null) payload['code'] = code.trim().toUpperCase();
      if (symbol != null) payload['symbol'] = symbol;
      if (rate != null) payload['rate'] = rate;
      if (isBase != null) payload['is_base'] = isBase ? 1 : 0;

      final res = await http.put(uri, headers: _defaultHeaders(token: token), body: jsonEncode(payload));
      final decoded = jsonDecode(res.body);

      if (res.statusCode == 200 && decoded['success'] == true) {
        await fetchCurrencies(token: token);
        _showSnack(title: 'نجاح', message: 'تم تعديل العملة بنجاح', type: SnackType.success, icon: Icons.edit);
        return true;
      } else {
        _showSnack(title: 'فشل', message: decoded['message'] ?? (decoded['errors']?.toString() ?? 'فشل تعديل العملة'), type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء تعديل العملة: $e', type: SnackType.error, icon: Icons.error);
    }
    return false;
  }

  /// حذف عملة (لا يسمح بحذف القاعدة حسب الباك)
  Future<bool> deleteCurrency({
    required dynamic idOrCode,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrlCurr/currencies/$idOrCode");
      final res = await http.delete(uri, headers: _defaultHeaders(token: token));
      final decoded = jsonDecode(res.body);

      if (res.statusCode == 200 && decoded['success'] == true) {
        await fetchCurrencies(token: token);
        _showSnack(title: 'نجاح', message: decoded['message']?.toString() ?? 'تم حذف العملة', type: SnackType.success, icon: Icons.delete_forever);
        return true;
      } else {
        _showSnack(title: 'فشل', message: decoded['message'] ?? 'فشل حذف العملة', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء حذف العملة: $e', type: SnackType.error, icon: Icons.error);
    }
    return false;
  }

  /// تعيين عملة كقاعدة جديدة
  Future<bool> setBaseCurrency({
    required dynamic idOrCode,
    double? providedRate,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrlCurr/currencies/$idOrCode/set-base");
      final body = <String, dynamic>{};
      if (providedRate != null) body['rate'] = providedRate;

      final res = await http.post(uri, headers: _defaultHeaders(token: token), body: jsonEncode(body));
      final decoded = jsonDecode(res.body);

      if (res.statusCode == 200 && decoded['success'] == true) {
        await fetchCurrencies(token: token);
        _showSnack(title: 'نجاح', message: decoded['message']?.toString() ?? 'تم تعيين العملة كقاعدة', type: SnackType.success, icon: Icons.flag);
        return true;
      } else {
        _showSnack(title: 'فشل', message: decoded['message'] ?? (decoded['errors']?.toString() ?? 'فشل تعيين القاعدة'), type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء تعيين القاعدة: $e', type: SnackType.error, icon: Icons.error);
    }
    return false;
  }

  /// تحديث rate لعملة غير أساسية
  Future<bool> updateCurrencyRate({
    required dynamic idOrCode,
    required double rate,
    String? token,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrlCurr/currencies/$idOrCode/update-rate");
      final res = await http.post(uri, headers: _defaultHeaders(token: token), body: jsonEncode({'rate': rate}));
      final decoded = jsonDecode(res.body);

      if (res.statusCode == 200 && decoded['success'] == true) {
        await fetchCurrencies(token: token);
        _showSnack(title: 'نجاح', message: 'تم تحديث السعر', type: SnackType.success, icon: Icons.sync);
        return true;
      } else {
        _showSnack(title: 'فشل', message: decoded['message'] ?? 'فشل تحديث السعر', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء تحديث السعر: $e', type: SnackType.error, icon: Icons.error);
    }
    return false;
  }

  // -----------------------
  // Local currency helpers (SharedPreferences)
  // -----------------------
  Future<void> _saveCurrentCurrency(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency', code);
    } catch (_) {}
  }

  Future<void> _loadSavedCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_currency');
      if (saved != null && saved.isNotEmpty) {
        currentCurrency.value = saved;
      }
    } catch (_) {}
  }

  /// تغيير العملة محلياً (يستخدم rates من currencies list)
  Future<void> changeCurrentCurrency(String code) async {
    currentCurrency.value = code;
    await _saveCurrentCurrency(code);
    _showSnack(title: 'تم التغيير', message: 'تم اختيار العملة $code', type: SnackType.success, icon: Icons.monetization_on);
  }

  /// تنسيق السعر حسب العملة الحالية (السعر الأصلي متوقع بـ SYP)
  String formatPrice(double price) {
    final syFormat = NumberFormat.currency(
      locale: 'ar_SY',
      symbol: '',
      decimalDigits: 0,
    );
    final usdFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    final currency = currencies.firstWhereOrNull(
      (c) => c['code'] == currentCurrency.value,
    );

    if (currency == null) {
      return '${syFormat.format(price)} ل.س';
    }

    if ((currency['code'] ?? '') == 'SYP') {
      return '${syFormat.format(price)} ل.س';
    } else {
      final rate = (currency['rate'] as num).toDouble();
      if (rate == 0) return usdFormat.format(0);
      final converted = price / rate;
      final symbol = (currency['symbol'] ?? currency['code'])?.toString();
      return "$symbol ${converted.toStringAsFixed(2)}";
    }
  }

  // -----------------------
  // Local sorting/filtering for currencies
  // -----------------------
  /// sortBy: 'code' | 'name' | 'rate' | 'is_base'
  void sortCurrencies(String sortBy, {bool desc = false}) {
    final list = List<Map<String, dynamic>>.from(currencies);
    list.sort((a, b) {
      int cmp = 0;
      switch (sortBy) {
        case 'code':
          cmp = a['code'].toString().compareTo(b['code'].toString());
          break;
        case 'name':
          cmp = a['name'].toString().compareTo(b['name'].toString());
          break;
        case 'rate':
          final ra = (a['rate'] as num).toDouble();
          final rb = (b['rate'] as num).toDouble();
          cmp = ra.compareTo(rb);
          break;
        case 'is_base':
          final ia = (a['is_base'] == 1 || a['is_base'] == true) ? 0 : 1; // base first
          final ib = (b['is_base'] == 1 || b['is_base'] == true) ? 0 : 1;
          cmp = ia.compareTo(ib);
          break;
        default:
          cmp = a['code'].toString().compareTo(b['code'].toString());
      }
      return desc ? -cmp : cmp;
    });
    currencies.assignAll(list);
  }

  // -----------------------
  // Utility
  // -----------------------
  @override
  void onInit() {
    super.onInit();
    if (!isGetFirstTime.value) {
      fetchColors();
      fetchCurrencies();
      isGetFirstTime.value = true;
    }
  }
}
