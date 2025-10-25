import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AboutUsViewDeskTop/AboutUsViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminAdsDesktopView/AdminAdsDesktopView.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdvertisersViewDeskTop/AdvertisersViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/AreasViewDeskTop/AreasViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/CitiesViewDeskTop/CitiesViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/ColorAndCurrencyViewDeskTop/ColorAndCurrencyViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/PremiumPackagesViewDeskTop/PremiumPackagesViewDeskTo.dart';
import 'package:tappuu_dashboard/DeskTopViews/SubCategoriesLevelTwoViewDeskTop/SubCategoriesLevelTwoViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/SubCategoriesViewDeskTop/SubCategoriesViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/TermsAndConditionsViewDeskTop/TermsAndConditionsViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/UserWalletViewDeskTop/UserWalletViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/UsersViewsDeskTop/UsersViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/WalletTransactionsViewDeskTop/WalletTransactionsViewDeskTop.dart';
import 'package:tappuu_dashboard/DeskTopViews/WatermarkViewDeskTop/WatermarkViewDeskTop.dart';
import 'package:tappuu_dashboard/controllers/ThemeController.dart';


import '../core/constant/app_text_styles.dart';
import '../core/constant/appcolors.dart';
import 'AdReportsScreenDesktop/AdReportsScreenDesktop.dart';
import 'AdminAdsDesktopViewUnderRview/AdminAdsDesktopViewUnderRview.dart';
import 'AppLogoViewDeskTop/AppLogoViewDeskTop.dart';
import 'BankAccountsViewDeskTop/BankAccountsViewDeskTop.dart';
import 'CategoriesViewDeskTop/CategoriesViewDeskTop.dart';
import 'AttributesViewDeskTop/AttributesViewDeskTop.dart';
import 'EditableTextViewDeskTop/EditableTextViewDeskTop.dart';
import 'FontManagementViewDeskTop/FontManagementViewDeskTop.dart';
import 'PostCategoriesViewDeskTop/PostCategoriesViewDeskTop.dart';
import 'PostsViewDeskTop/PostsViewDeskTop.dart';
import 'SendNotificationViewDeskTop/SendNotificationViewDeskTop.dart';
import 'TransfersViewDeskTop/TransfersViewDeskTop.dart';
import 'WaitingScreenViewDeskTop/WaitingScreenViewDeskTop.dart';

class AdminSidebarDeskTop extends StatefulWidget {
  const AdminSidebarDeskTop({Key? key}) : super(key: key);

  @override
  _AdminSidebarDeskTopState createState() => _AdminSidebarDeskTopState();
}

class _AdminSidebarDeskTopState extends State<AdminSidebarDeskTop> {
  final ThemeController themeController = Get.find<ThemeController>();
  int _selectedIndex = 0;

  // دالة للتنقل بين الواجهات
  void _navigateToScreen(Widget screen, int index) {
    setState(() {
      _selectedIndex = index;
    });
    Get.offAll(() => screen);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      
      return Container(
        width: 260.w,
        decoration: BoxDecoration(
          color: Color(0xFF1E1F2B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(4, 0),
            )
          ],
        ),
        child: Column(
          textDirection: TextDirection.rtl,
          children: [  
            // Header with logo
            Container(
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(Icons.dashboard, 
                      color: Colors.white, 
                      size: 26.r),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "لوحة التحكم",
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: AppTextStyles.tajawal,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                children: [
                  // القسم الأول: المحتوى الأساسي
                  _buildSectionTitle("المحتوى الأساسي", isDarkMode),
                  _buildMenuItem(
                    icon: Icons.people_alt_rounded,
                    title: 'المستخدمين',
                    index: 1,
                    isActive: _selectedIndex == 1,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(UsersViewDeskTop(), 1);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.ad_units_outlined,
                    title: 'الإعلانات',
                    index: 2,
                    isActive: _selectedIndex == 2,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(AdminAdsDesktopView(), 2);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.rate_review_outlined,
                    title: 'قيد المراجعة',
                    index: 3,
                    isActive: _selectedIndex == 3,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(AdminAdsDesktopUnderView(), 3);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.folder_special_outlined,
                    title: 'ملفات المعلنين',
                    index: 4,
                    isActive: _selectedIndex == 4,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(AdvertisersViewDeskTop(), 4);
                    },
                  ),
                  
                  // القسم الثاني: التصنيفات
                  _buildSectionTitle("التصنيفات", isDarkMode),
                  _buildMenuItem(
                    icon: Icons.category_outlined,
                    title: 'التصنيفات الرئيسية',
                    index: 5,
                    isActive: _selectedIndex == 5,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(CategoriesViewDeskTop(), 5);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.subdirectory_arrow_right,
                    title: 'التصنيفات الفرعية',
                    index: 6,
                    isActive: _selectedIndex == 6,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(SubCategoriesViewDeskTop(), 6);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.view_list_outlined,
                    title: 'التصنيفات الثانوية',
                    index: 7,
                    isActive: _selectedIndex == 7,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(SubCategoriesLevelTwoViewDeskTop(), 7);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.tune,
                    title: 'خصائص الإعلان',
                    index: 8,
                    isActive: _selectedIndex == 8,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(AttributesViewDeskTop(), 8);
                    },
                  ),

                     _buildMenuItem(
                    icon: Icons.report,
                    title: 'البلاغات',
                    index: 9,
                    isActive: _selectedIndex == 9,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(AdReportsViewDeskTop(), 9);
                    },
                  ),
                  
                  
                  // القسم الثالث: المدفوعات والمحافظ
                  _buildSectionTitle("المدفوعات والمحافظ", isDarkMode),

                    _buildMenuItem(
                    icon: Icons.account_balance,
                    title: 'البنوك وطرق الدفع ',
                    index: 10,
                    isActive: _selectedIndex == 24,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(BankAccountsViewDeskTop(), 24);
                    },
                  ),

                    _buildMenuItem(
                    icon: Icons.money_outlined,
                    title: 'عمليات التحويل البنكي',
                    index: 10,
                    isActive: _selectedIndex == 25,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(TransfersViewDeskTop(), 25);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'محافظ المستخدمين',
                    index: 10,
                    isActive: _selectedIndex == 10,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(UserWalletViewDeskTop(), 10);
                    },
                  ),

                 
                  _buildMenuItem(
                    icon: Icons.history_outlined,
                    title: 'أرشيف المعاملات',
                    index: 11,
                    isActive: _selectedIndex == 11,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(WalletTransactionsViewDeskTop(), 11);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.attach_money_outlined,
                    title: 'الباقات المميزة',
                    index: 12,
                    isActive: _selectedIndex == 12,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(PremiumPackagesViewDeskTop(), 12);
                    },
                  ),
                  
                  // القسم الرابع: الموقع الجغرافي
                  _buildSectionTitle("الموقع الجغرافي", isDarkMode),
                  _buildMenuItem(
                    icon: Icons.location_city_outlined,
                    title: 'المدن',
                    index: 13,
                    isActive: _selectedIndex == 13,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(CitiesViewDeskTop(), 13);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.map_outlined,
                    title: 'المناطق',
                    index: 14,
                    isActive: _selectedIndex == 14,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(AreasViewDeskTop(), 14);
                    },
                  ),
                  
                  // القسم الخامس: الإعدادات
                  _buildSectionTitle("الإعدادات", isDarkMode),

                   _buildMenuItem(
                    icon: Icons.image,
                    title: 'شعار التطبيق',
                    index: 15,
                    isActive: _selectedIndex == 15,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(   AppLogoViewDeskTop(), 15);
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.text_decrease,
                    title: 'النصوص المتغيرة',
                    index: 15,
                    isActive: _selectedIndex == 26,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(   EditableTextViewDeskTop(), 26);
                    },
                  ),

               
                  _buildMenuItem(
                    icon: Icons.palette_outlined,
                    title: 'الألوان والعملات',
                    index: 16,
                    isActive: _selectedIndex == 16,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(ColorAndCurrencyViewDeskTop(), 16);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.security_outlined,
                    title: 'الخصوصية والشروط',
                    index: 17,
                    isActive: _selectedIndex == 17,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(TermsAndConditionsViewDeskTop(), 17);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'من نحن',
                    index: 18,
                    isActive: _selectedIndex == 18,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(AboutUsViewDeskTop(), 18);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_active_outlined,
                    title: 'الإشعارات',
                    index: 19,
                    isActive: _selectedIndex == 19,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(SendNotificationViewDeskTop(), 19);
                    },
                  ),
                   _buildMenuItem(
                    icon: Icons.fit_screen,
                    title: 'شاشة الإنتظار',
                    index: 20,
                    isActive: _selectedIndex == 20,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(WaitingScreenViewDeskTop(), 20);
                    },
                  ),   _buildMenuItem(
                    icon: Icons.font_download_sharp,
                    title: 'الأحجام والخطوط',
                    index: 21,
                    isActive: _selectedIndex == 21,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(FontManagementViewDeskTop(), 21);
                    },

                  ),_buildMenuItem(
                    icon: Icons.branding_watermark,
                    title: 'العلامة المائية',
                    index: 21,
                    isActive: _selectedIndex == 24,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(WatermarkViewDeskTop(), 24);
                    },
                    
                  ),
                      _buildSectionTitle("المدونة", isDarkMode),
                _buildMenuItem(
                    icon: Icons.post_add,
                    title: 'المدونة',
                    index: 22,
                    isActive: _selectedIndex == 22,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(PostsViewDeskTop(), 22);
                    },
                  ), _buildMenuItem(
                    icon: Icons.category,
                    title: 'تصنيفات المنشورات',
                    index: 22,
                    isActive: _selectedIndex == 23,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      _navigateToScreen(PostCategoriesViewDeskTop(), 23);
                    },
                  ), 
                
                  SizedBox(height: 24.h),
                  
                  // Dark/Light mode toggle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.light_mode_outlined,
                            color: AppColors.primary,
                            size: 22.r,
                          ),
                          Text(
                            isDarkMode ? 'الوضع المضيء' : 'الوضع المظلم',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppTextStyles.tajawal,
                            ),
                          ),
                          Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              themeController.toggleTheme();
                            },
                            activeColor: AppColors.primary,
                            inactiveTrackColor: Colors.grey[400],
                            inactiveThumbColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                 
                  SizedBox(height: 16.h),
                  _buildMenuItem(
                    icon: Icons.logout_outlined,
                    title: 'تسجيل الخروج',
                    index: 18,
                    isActive: _selectedIndex == 18,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // تنفيذ عملية تسجيل الخروج
                    },
                  ),
                ],
              ),
            ),
            
            // Footer
            Container(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  Text(
                    "v1.0.0",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12.sp,
                      fontFamily: AppTextStyles.tajawal,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "© 2025 نظام الإدارة",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12.sp,
                      fontFamily: AppTextStyles.tajawal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(right: 24.w, top: 16.h, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w700,
          color: AppColors.primary.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isActive,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isActive 
          ? AppColors.primary.withOpacity(0.15) 
          : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isActive
            ? Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        minLeadingWidth: 0,
        minVerticalPadding: 0,
        dense: true,
        leading: Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: isActive 
              ? AppColors.primary.withOpacity(0.2) 
              : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20.r,
            color: isActive 
              ? AppColors.primary
              : Colors.white70,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: AppTextStyles.tajawal,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive 
              ? AppColors.primary
              : Colors.white70,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2.r),
                    bottomLeft: Radius.circular(2.r),
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}