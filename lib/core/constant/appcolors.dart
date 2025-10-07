import 'package:flutter/material.dart';

class AppColors {

 


  // ─── الألوان الأساسية ───────────────────────────────────────
  static const Color primary = Color(0xFFF2B81B);
  static const Color primaryDark = Color(0xFF232223);

  // اللون الثانوي (مثال: أصفر لتحفيز الانتباه)
  static const Color secondary = Color(0xFFEB9E2B);
  static const Color secondaryDark = Color(0xFFC49020);

  // ─── الألوان المحايدة ───────────────────────────────────────
  

  static const Color greyLight = Color(0xFFBDBDBD);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF616161);

  // ─── الألوان الدلالية ───────────────────────────────────────
 

  // ─── ألوان النص فوق الخلفيات ───────────────────────────────
  static const Color onPrimary      = Color(0xFFFFFFFF);
  static const Color onSecondary    = Color(0xFF000000);
  static const Color onBackground   = Color(0xFF000000);
  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color onSurfaceDark  = Color(0xFFFFFFFF);

  // ─── دوال الوضع الفاتح/الداكن ───────────────────────────────

 // ─── الألوان المحايدة المحسنة ───────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  static const Color cardLight = Color(0xFFF1F3F5);
  static const Color cardDark = Color(0xFF252525);
  
  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF1F3F5);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFCED4DA);
  static const Color grey500 = Color(0xFFADB5BD);
  static const Color grey600 = Color(0xFF868E96);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey800 = Color(0xFF343A40);
  static const Color grey900 = Color(0xFF212529);

  // ─── الألوان الدلالية ───────────────────────────────────────
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);
  static const Color darkBlue = Color.fromARGB(255, 7, 33, 61);
  static const Color blue = Color(0xFF5483C5);
static Color border(bool isDarkMode) => 
    isDarkMode ? grey700 : grey300;
  // ─── دوال الوضع الفاتح/الداكن المحسنة ───────────────────────
  static Color background(bool isDarkMode) => 
      isDarkMode ? backgroundDark : backgroundLight;

  static Color surface(bool isDarkMode) => 
      isDarkMode ? surfaceDark : surfaceLight;
  
  static Color card(bool isDarkMode) => 
      isDarkMode ? cardDark : cardLight;
  
  static Color textPrimary(bool isDarkMode) => 
      isDarkMode ? grey100 : grey900;
  
  static Color textSecondary(bool isDarkMode) => 
      isDarkMode ? grey400 : grey600;
  
    
  static Color textThreey(bool isDarkMode) => 
      isDarkMode ? grey400 : Colors.black;
  
  static Color divider(bool isDarkMode) => 
      isDarkMode ? grey700 : grey300;
  
  static Color icon(bool isDarkMode) => 
      isDarkMode ? grey300 : const Color.fromARGB(255, 35, 36, 38);


  static Color appBar(bool isDarkMode) => 
      isDarkMode ? surfaceDark : darkBlue;
}