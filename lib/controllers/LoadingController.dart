
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/model/user.dart';


class LoadingController extends GetxController {
   final RxBool isDesktop = false.obs;
  final RxBool isTablet = false.obs;
  final RxBool isMobile = false.obs;
  var isLoading = RxBool(true);
  var isGo = RxBool(false); // متغير جديد للتحكم في عملية الانتقال
  User? currentUser;
 // HomeController homeController = Get.find<HomeController>();
RxBool showOneTimeLogin  = false.obs;

  @override
  void onInit() {
   // homeController.onInit();
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (isGo.value) return; // إذا كانت isGo = true، لا تنفذ العملية مرة أخرى

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // التحقق مما إذا كانت هذه أول مرة يُفتح فيها التطبيق
    String? firstTimeFlag = prefs.getString('firstTimeFlag');
    bool isFirstTime = firstTimeFlag == null || firstTimeFlag == 'isFirstTime';

    int delaySeconds = isFirstTime ? 3 : 3;
    await Future.delayed(Duration(seconds: delaySeconds));

    if (isFirstTime) {
      await prefs.setString('firstTimeFlag', 'isNotFirstTime');

      await Future.delayed(Duration(milliseconds: 500)); // ⏳ تأخير بسيط
      isGo.value = true; // تحديث المتغير بعد الانتقال
    //  Get.to(() => HomeScreen());
      return;
    }

    String? userData = prefs.getString('user');
    await Future.delayed(Duration(milliseconds: 500)); // ⏳ تأخير بسيط

    if (userData != null) {
      currentUser = User.fromJson(jsonDecode(userData));
    }

    isGo.value = true; // تحديث المتغير بعد الانتقال
 //Get.to(() => HomeScreen());
  }

  Future<void> refreshUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userData = prefs.getString('user');
  
  if (userData != null) {
    currentUser = User.fromJson(jsonDecode(userData));
  }
  update(); // إخطار المشاهدين بالتحديث
}

}
