import 'package:get/get.dart';

import 'HomeDeciderView.dart';

class AppRoutes {
  /// المسار الابتدائي للتطبيق
  static const String initial = '/Decider';

  /// مسار عرض تفاصيل المنشور
  static const String postDetails = '/post/:id';

  /// مسار رابط التحميل الديناميكي
  static const String link = '/link';

  /// قائمة الصفحات (GetPages)
  static final List<GetPage> pages = [
    GetPage(
      name: initial,
      page: () => const HomeDeciderView(),
    ),
   /* GetPage(
      name: postDetails,
      page: () => DetailsLoadLink(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: link,
      page: () => DetailsLoadLink(),
      transition: Transition.fadeIn,
    ),*/
  ];
}
