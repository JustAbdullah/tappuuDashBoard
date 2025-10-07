import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import '../core/data/model/City.dart';

enum SnackType { success, error, info }

class CityController extends GetxController {
  static const _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api/cities';
  
  final translator = GoogleTranslator();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isDeleting = false.obs;
  final RxList<TheCity> citiesList = <TheCity>[].obs;
  final Rxn<TheCity> city = Rxn<TheCity>();

  @override
  void onInit() {
    super.onInit();
    fetchCities(country: 'SY', language: 'ar');
  }

  Map<String, String> _defaultHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<String> _translateToEnglish(String arabicText) async {
    try {
      final translation = await translator.translate(arabicText, from: 'ar', to: 'en');
      return translation.text;
    } catch (e) {
      print("Translation error: $e");
      return arabicText;
    }
  }

  /// الدالة المعدلة لعرض السناك بار بشكل موثوق
  void _showSnack({
    required String title,
    required String message,
    SnackType type = SnackType.info,
    IconData? icon,
    int seconds = 3,
  }) {
    // أغلق أي Snackbars مفتوحة أولًا
    try {
      Get.closeAllSnackbars();
    } catch (_) {}

    final LinearGradient gradient;
    final Color textColor = Colors.white;
    final IconData defaultIcon;
    switch (type) {
      case SnackType.success:
        gradient = LinearGradient(colors: [Colors.green.shade700, Colors.green.shade600]);
        defaultIcon = Icons.check_circle;
        break;
      case SnackType.error:
        gradient = LinearGradient(colors: [Colors.red.shade900, Colors.red.shade700]);
        defaultIcon = Icons.error_outline;
        break;
      case SnackType.info:
      default:
        gradient = LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade700]);
        defaultIcon = Icons.info_outline;
        break;
    }

    final iconToShow = icon ?? defaultIcon;

    // استخدم Get.showSnackbar مع GetSnackBar لموثوقية أكبر وتحكّم أفضل
    Get.showSnackbar(
      GetSnackBar(
        titleText: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        messageText: Text(message, style: TextStyle(color: textColor)),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        backgroundGradient: gradient,
        shouldIconPulse: true,
        duration: Duration(seconds: seconds),
        icon: Icon(iconToShow, color: Colors.white),
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutQuad,
        reverseAnimationCurve: Curves.easeInQuad,
        // إضمن أن السناك يطفو فوق المحتوى
        snackStyle: SnackStyle.FLOATING,
      ),
    );
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

    Future<bool> createCity({
    required String arabicName,
    required String country,
    String? token,
  }) async {
    isSaving.value = true;
    try {
      final englishName = await _translateToEnglish(arabicName);
      final slug = englishName.toLowerCase().replaceAll(' ', '-');

      final body = json.encode({
        'slug': slug,
        'country': country,
        'translations': [
          {'language': 'ar', 'name': arabicName},
          {'language': 'en', 'name': englishName},
        ],
      });

      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: _defaultHeaders(token: token),
        body: body,
      );

      // محاولة قراءة رسالة الخادم
      String serverMsg = '';
      try {
        final j = json.decode(res.body);
        if (j is Map && j['message'] != null) serverMsg = j['message'].toString();
      } catch (_) {}

      if (res.statusCode == 200 || res.statusCode == 201) {
        // أعدل: أنتظر جلب المدن قبل عرض السناك لضمان أن القائمة محدثة عندما يراها المستخدم
        await fetchCities(country: country, language: 'ar');

        _showSnack(
          title: 'تمت الإضافة',
          message:'تم إنشاء المدينة بنجاح',
          type: SnackType.success,
          icon: Icons.check_circle,
        );

        // أترك مهلة قصيرة لكي يظهر السناك قبل أن يقوم الـ UI بأي إغلاق/تغيير route
        await Future.delayed(const Duration(milliseconds: 600));
        return true;
      } else {
        String msg = serverMsg.isNotEmpty ? serverMsg : 'فشل إنشاء المدينة. الحالة: ${res.statusCode}';
        _showSnack(title: 'خطأ', message: msg, type: SnackType.error, icon: Icons.error_outline);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء إنشاء المدينة: $e', type: SnackType.error, icon: Icons.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateCity({
    required int id,
    required String arabicName,
    required String country,
    String? token,
  }) async {
    isSaving.value = true;
    try {
      final englishName = await _translateToEnglish(arabicName);
      final slug = englishName.toLowerCase().replaceAll(' ', '-');

      final Map<String, dynamic> payload = {
        'slug': slug,
        'country': country,
        'translations': [
          {'language': 'ar', 'name': arabicName},
          {'language': 'en', 'name': englishName},
        ],
      };

      final res = await http.put(
        Uri.parse('$_baseUrl/update/$id'),
        headers: _defaultHeaders(token: token),
        body: json.encode(payload),
      );

      // قراءة رسالة الخادم إن وُجدت
      String serverMsg = '';
      try {
        final j = json.decode(res.body);
        if (j is Map && j['message'] != null) serverMsg = j['message'].toString();
      } catch (_) {}

      if (res.statusCode == 200) {
        await fetchCities(country: country, language: 'ar');

        _showSnack(
          title: 'تم التعديل',
          message: serverMsg.isNotEmpty ? serverMsg : 'تم تحديث بيانات المدينة بنجاح',
          type: SnackType.success,
          icon: Icons.edit,
        );

        // وقت قصير للسناك ليظهر قبل إعادة التوجيه/إغلاق الـ UI
        await Future.delayed(const Duration(milliseconds: 600));
        return true;
      } else {
        String msg = serverMsg.isNotEmpty ? serverMsg : 'فشل تحديث المدينة. الحالة: ${res.statusCode}';
        _showSnack(title: 'خطأ', message: msg, type: SnackType.error, icon: Icons.error_outline);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء تحديث المدينة: $e', type: SnackType.error, icon: Icons.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }


  Future<bool> deleteCity({
    required int id,
    String? token,
  }) async {
    isDeleting.value = true;
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _defaultHeaders(token: token),
      );

      if (res.statusCode == 200) {
        await fetchCities(country: 'SY', language: 'ar');
        _showSnack(
          title: 'تم الحذف',
          message: 'تم حذف المدينة بنجاح',
          type: SnackType.success,
          icon: Icons.delete_forever
        );
        return true;
      } else {
        String msg = 'فشل حذف المدينة. الحالة: ${res.statusCode}';
        try {
          final bodyJson = json.decode(res.body);
          if (bodyJson is Map && bodyJson['message'] != null) msg = bodyJson['message'].toString();
        } catch (_) {}
        _showSnack(title: 'خطأ', message: msg, type: SnackType.error, icon: Icons.error_outline);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء حذف المدينة: $e', type: SnackType.error, icon: Icons.error);
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  String getCityName(TheCity c, {String lang = 'ar'}) {
    final t = c.translations.firstWhereOrNull((tr) => tr.language == lang);
    return t?.name ?? c.slug;
  }
}
