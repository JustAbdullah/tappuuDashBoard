import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'MyCustomScrollBehavior.dart';
import 'app_routes.dart';
import 'controllers/LoadingController.dart';
import 'controllers/ThemeController.dart';
import 'core/constant/app_text_styles.dart';
import 'core/constant/appcolors.dart';
import 'core/localization/AppTranslation.dart';
import 'core/localization/changelanguage.dart';
import 'core/services/appservices.dart';
import 'enhanced_navigator_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إزالة الـ “#” من المسارات
  setUrlStrategy(PathUrlStrategy());

  // Edge-to-Edge وشفافية الأشرطة
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  // تهيئة الخدمات والاعتماديات
  final appServices = await AppServices.init();
  Get.put(appServices);
  Get.put(ChangeLanguageController());
  Get.put(ThemeController()); // Initialize ThemeController here

  // مسار البداية في التاريخ
  final initialUri = Uri.parse(html.window.location.href);
  html.window.history.replaceState(
    {'route': initialUri.path},
    '',
    initialUri.path,
  );

  // زر “رجوع” في المتصفح -> استخدم Navigator.canPop عبر navigatorKey
  html.window.onPopState.listen((_) {
    final canPop = Get.key?.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back();
    }
  });

  // قصر التطبيق على الوضع الرأسي
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp(initialUri: initialUri));
}

class MyApp extends StatelessWidget {
  final Uri initialUri;
  const MyApp({Key? key, required this.initialUri}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final langCtrl = Get.find<ChangeLanguageController>();
    final themeCtrl = Get.find<ThemeController>(); // Get existing instance

    // إجبار اللغة العربية
    langCtrl.changeLanguage('ar');

    return Obx(() {
      final isDarkMode = themeCtrl.isDarkMode.value;
    
      return Directionality(
        textDirection: TextDirection.rtl, // إجبار RTL للغة العربية
        child: GetMaterialApp(
          scrollBehavior: MyCustomScrollBehavior(),
          navigatorKey: Get.key,
          debugShowCheckedModeBanner: false,
          title: 'طابوو',
          translations: AppTranslation(),
          locale: const Locale('ar'), // إجبار اللغة العربية
          fallbackLocale: const Locale('ar'),
          initialRoute: AppRoutes.initial,
          getPages: AppRoutes.pages,
          initialBinding: BindingsBuilder(() {
            Get.put(LoadingController(), permanent: true);
          }),
          navigatorObservers: [EnhancedNavigatorObserver()],
          themeMode: themeCtrl.isDarkMode.value ? ThemeMode.dark : ThemeMode.light, // Add this line
          theme: ThemeData(
            fontFamily: AppTextStyles.tajawal,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              background: AppColors.backgroundLight,
              surface: AppColors.surfaceLight,
            ),
          ),
          darkTheme: ThemeData( // Add dark theme
            fontFamily: AppTextStyles.tajawal,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              background: AppColors.backgroundDark,
              surface: AppColors.surfaceDark,
            ),
          ),
          builder: (ctx, child) {
            return WillPopScope(
              onWillPop: () async => _confirmExit(isDarkMode),
              child: child!,
            );
          },
        ),
      );
    });
  }

  Future<bool> _confirmExit(bool isDarkMode) async {
    if (Get.isDialogOpen ?? false) return false;

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface(isDarkMode),
        title: Text(
          'تأكيد الخروج',
          style: TextStyle(
            fontSize: 18,
            fontFamily: AppTextStyles.tajawal,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(isDarkMode),
          ),
        ),
        content: Text(
          'هل تريد حقًا الخروج من التطبيق؟',
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppTextStyles.tajawal,
            color: AppColors.textPrimary(isDarkMode),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDarkMode),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'خروج',
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}