import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/appservices.dart';

class ChangeLanguageController extends GetxController {
  // اللغة الحالية (بما فيها scriptCode للـ RTL)
  var currentLocale = Locale.fromSubtags(languageCode: 'ar', scriptCode: 'Arab').obs;

  // قائمة اللغات المدعومة مع تحديد الـ RTL حيث يلزم
  static const _supported = {
    'ar': Locale.fromSubtags(languageCode: 'ar', scriptCode: 'Arab'),
    'en': Locale('en'),
  };

  // تغيير اللغة
  void changeLanguage(String langCode) {
    // اذا لم تكن مدعومة، نرجع للعربية
    if (!_supported.containsKey(langCode)) {
      langCode = 'ar';
    }
    final locale = _supported[langCode]!;
    currentLocale.value = locale;
    Get.updateLocale(locale);
    saveLanguage(langCode);
    
    // إعادة تحميل الصفحات للتأكد من تطبيق التغيير
    Get.forceAppUpdate();
  }

  // حفظ اللغة في SharedPreferences
  void saveLanguage(String langCode) {
    Get.find<AppServices>()
        .sharedPreferences
        .setString('lang', langCode);
  }

  // استعادة اللغة عند التشغيل
  @override
  void onInit() {
    super.onInit();
    final prefs = Get.find<AppServices>().sharedPreferences;
    final savedLang = prefs.getString('lang');

    String code = savedLang ??
        Get.deviceLocale?.languageCode ??
        'ar';

    // إذا لم تكن اللغة المحفوظة مدعومة، استخدم عربية
    if (!_supported.containsKey(code)) {
      code = 'ar';
    }

    final locale = _supported[code]!;
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }
}