import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/ThemeController.dart';

import '../DeskTopViews/SendNotificationViewDeskTop/SendNotificationViewDeskTop.dart';
import '../HomeDeciderView.dart';
import '../core/constant/app_text_styles.dart';
import '../core/constant/appcolors.dart';
import 'AboutUsViewMobile/AboutUsViewMobile.dart';
import 'AdReportsViewMobile/AdReportsViewMobile.dart';
import 'AdminAdsMobileUnderView /AdminAdsMobileUnderView.dart';
import 'AdminAdsMobileView/AdminAdsMobileView.dart';
import 'AdvertisersViewMobile/AdvertisersViewMobile.dart';
import 'AppLogoViewMobile/AppLogoViewMobile.dart';
import 'AreasViewMobile/AreasViewMobile.dart';
import 'AttributesViewMobile/AttributesViewMobile.dart';
import 'CategoriesViewMobile/CategoriesViewMobile.dart';
import 'CitiesViewMobile/CitiesViewMobile.dart';
import 'ColorAndCurrencyViewMobile/ColorAndCurrencyViewMobile.dart';
import 'PremiumPackagesViewMobile/PremiumPackagesViewMobile.dart';
import 'SubCategoriesLevelTwoViewMobile/SubCategoriesLevelTwoViewMobile.dart';
import 'SubCategoriesViewMobile/SubCategoriesViewMobile.dart';
import 'TermsAndConditionsViewMobile/TermsAndConditionsViewMobile.dart';
import 'UserWalletViewMobile/UserWalletViewMobile.dart';
import 'UsersMobile/UsersViewMobile.dart';
import 'WalletTransactionsViewMobile/WalletTransactionsViewMobile.dart';

class AdminSidebar extends StatefulWidget {
  final bool isMobile;
  final VoidCallback? onClose;
  const AdminSidebar({Key? key, this.isMobile = false, this.onClose}) : super(key: key);

  @override
  _AdminSidebarState createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      return Container(
        width: widget.isMobile ? double.infinity : 220.w,
        decoration: BoxDecoration(
          color: Color(0xFF1E1F2B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(4, 0),
            )
          ],
        ),
        child: Column(
          textDirection: TextDirection.rtl,
          children: [  
            // زر الإغلاق للهاتف
            if (widget.isMobile) 
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  "لوحة التحكم",
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTextStyles.tajawal,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            
            if (!widget.isMobile) Container(
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.dashboard, 
                      color: AppColors.primary, 
                      size: 24.r
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "لوحة التحكم",
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTextStyles.tajawal,
                    ),
                  ),
                ],
              ),
            ),
            
            // قائمة العناصر
            Expanded(
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                children: [
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'المستخدمين',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> UsersViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.ad_units,
                    title: 'الإعلانات',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> AdminAdsMobileView());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.reviews,
                    title: 'قيد المراجعة',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> AdminAdsMobileUnderView());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.business_center,
                    title: 'ملفات المعلنين',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> AdvertisersViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.category,
                    title: 'التصنيفات',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> CategoriesViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.subdirectory_arrow_right,
                    title: 'الفرعية',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> SubCategoriesViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.view_list,
                    title: 'الثانوية',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> SubCategoriesLevelTwoViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.style,
                    title: 'خصائص الإعلان',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> AttributesViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'المحافظ الالكترونية',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> UserWalletViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.loyalty,
                    title: 'الباقات',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                  //    Get.offAll(()=> PremiumPackagesViewMobile());
                    },
                  ), 
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'ارشفة التحويلات',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> WalletTransactionsViewMobile());
                    },
                  ), 
                  _buildMenuItem(
                    icon: Icons.report_problem,
                    title: 'البلاغات',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> AdReportsViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.image,
                    title: 'شعار التطبيق',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> AppLogoViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.palette,
                    title: 'العملات والالوان',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> ColorAndCurrencyViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.gavel,
                    title: 'الشروط والقوانين',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> TermsAndConditionsViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'من نحن',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> AboutUsViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.location_city,
                    title: 'المدن',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> CitiesViewMobile());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.map,
                    title: 'المناطق',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> AreasViewMobile());
                    },
                  ),
                  SizedBox(height: 24.h),
                  // تبديل الثيم
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.light_mode, color: Colors.white70, size: 20.r),
                          Text(
                            isDarkMode ? 'الوضع المضيء' : 'الوضع المظلم',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              fontFamily: AppTextStyles.tajawal,
                            ),
                          ),
                          Switch(
                            value: isDarkMode,
                            onChanged: (_) => themeController.toggleTheme(),
                            activeColor: AppColors.primary,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'الإشعارات',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=> SendNotificationViewDeskTop());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'تسجيل الخروج',
                    isDarkMode: isDarkMode,
                    isMobile: widget.isMobile,
                    onTap: () {
                      if (widget.isMobile) widget.onClose?.call();
                      Get.offAll(()=>HomeDeciderView());
                    },
                  ),
                ],
              ),
            ),
            
            if (!widget.isMobile)
              Container(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    Text("v1.0.0",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey[600],
                        fontSize: 12.sp,
                        fontFamily: AppTextStyles.tajawal,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text("© 2025 نظام إدارة",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey[600],
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color:  Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8.w : 16.w, 
          vertical: isMobile ? 4.h : 8.h,
        ),
        minLeadingWidth: 0,
        dense: isMobile,
        leading: Icon(
          icon,
          size: isMobile ? 18.r : 20.r,
          color:  (isDarkMode ? Colors.white70 : AppColors.textSecondary(false)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 12.sp : 13.sp,
            fontFamily: AppTextStyles.tajawal,
            fontWeight:FontWeight.w500,
            color: (isDarkMode ? Colors.white70 : AppColors.textSecondary(false)),
          ),
        ),
        trailing:  !isMobile
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