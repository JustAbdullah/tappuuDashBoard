import 'package:shared_preferences/shared_preferences.dart';

class AppServices {
  late SharedPreferences sharedPreferences;

  static Future<AppServices> init() async {
    AppServices services = AppServices();
    services.sharedPreferences = await SharedPreferences.getInstance();
    return services;
  }
}
