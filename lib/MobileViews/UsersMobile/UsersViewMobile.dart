import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/UserController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';

import '../AdminSidebar.dart';
class UsersViewMobile extends StatefulWidget {
  const UsersViewMobile({Key? key}) : super(key: key);

  @override
  _UsersViewMobileState createState() => _UsersViewMobileState();
}

class _UsersViewMobileState extends State<UsersViewMobile> {
  final UserController userController = Get.put(UserController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _upgradeController = TextEditingController();
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    userController.fetchUsersWithCounts();
  }

  String _formatDaysAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final days = difference.inDays;
    return 'منذ $days يوم';
  }

  void _showUpgradeDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.rocket_launch, size: 24.r, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Text(
                    'ترقية الإعلانات',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _upgradeController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textPrimary(isDarkMode),
                ),
                decoration: InputDecoration(
                  labelText: 'عدد الإعلانات الجديدة',
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDarkMode),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border(isDarkMode)),
                  ),
                  filled: true,
                  fillColor: AppColors.card(isDarkMode),
                  prefixIcon: Icon(Icons.add, size: 22.r),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (_upgradeController.text.isNotEmpty) {
                        userController.updateMaxFreePostsDefault(
                      newValue:     int.parse(_upgradeController.text),
                      updateExistingUsers: true
                        );
                        Get.back();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upgrade, size: 20.r),
                        SizedBox(width: 8.w),
                        Text(
                          'تطبيق',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int userId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 24.r, color: AppColors.error),
                  SizedBox(width: 10.w),
                  Text(
                    'تأكيد الحذف',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'هل أنت متأكد من حذف هذا المستخدم؟',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textPrimary(isDarkMode),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      userController.deleteUser(userId);
                      Get.back();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, size: 20.r),
                        SizedBox(width: 8.w),
                        Text(
                          'حذف',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context), // دالة إغلاق الدرج
        ),
      ),
      appBar: AppBar(
        title: Text('إدارة المستخدمين', 
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          )
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.upgrade, size: 22.r),
            onPressed: _showUpgradeDialog,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // Search bar
            Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 600.w,
                        minWidth: 400.w,
                      ),
                      child: Container(
                        height: 56.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: AppColors.card(isDarkMode),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Expanded(
                              child: TextField(
  textDirection: TextDirection.rtl,
  controller: _searchController,
  style: TextStyle(
    fontSize: 14.sp,
    fontFamily: AppTextStyles.tajawal,
    color: AppColors.textPrimary(isDarkMode),
  ),
  textAlign: TextAlign.center,           // محاذاة أفقية
  textAlignVertical: TextAlignVertical.center, // محاذاة عمودية
  decoration: InputDecoration(
    hintText: 'ابحث عن مستخدم...',
    hintStyle: TextStyle(
      fontSize: 14.sp,
      fontFamily: AppTextStyles.tajawal,
      color: AppColors.textSecondary(isDarkMode),
    ),
    prefixIcon: Icon(Icons.search, size: 22.r),
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 0), // اضبطها حسب الحاجة
  ),
),

                            ),
                            SizedBox(width: 12.w),
                         
                            SizedBox(width: 8.w),
                            ElevatedButton(
                              onPressed: () {
                                userController.fetchUsersWithCounts(email:_searchController.text.toString() );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                elevation: 1,
                              ),
                              child: Text(
                                'بحث',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
              
            
     
            
            SizedBox(height: 16.h),
            
            // Users list
            Expanded(
              child: Obx(() {
                if (userController.isLoadingUsers.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3.r,
                    ),
                  );
                }
                
                if (userController.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off, size: 48.r, 
                             color: AppColors.textSecondary(isDarkMode)),
                        SizedBox(height: 16.h),
                        Text(
                          'لا يوجد مستخدمين',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: userController.users.length,
                  itemBuilder: (context, index) {
                    final user = userController.users[index];
                    final availableAds = user.maxFreePosts - user.freePostsUsed;
                    final createdAt = user.date ?? DateTime.now().subtract(Duration(days: 300));
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المعرف: ${user.id}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(isDarkMode),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: user.isBlocked 
                                      ? AppColors.error.withOpacity(0.1)
                                      : AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    user.isBlocked ? 'محظور' : 'نشط',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontFamily: AppTextStyles.tajawal,
                                      fontWeight: FontWeight.bold,
                                      color: user.isBlocked 
                                        ? AppColors.error 
                                        : AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 12.h),
                            
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textPrimary(isDarkMode),
                              ),
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            Text(
                              _formatDaysAgo(createdAt),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDarkMode),
                              ),
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem('الإعلانات', '${user.adsCount}'),
                                _buildStatItem('ملفات المعلنين', '${user.advertiserProfileCount}'),
                                _buildStatItem('المتاحة', '$availableAds', isHighlighted: true),
                              ],
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, size: 20.r, 
                                          color: AppColors.primary),
                                  onPressed: () {},
                                ),
                                SizedBox(width: 8.w),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 20.r, 
                                          color: AppColors.error),
                                  onPressed: () => _showDeleteDialog(user.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
       
     
       ])) );
  }

  Widget _buildStatItem(String title, String value, {bool isHighlighted = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDarkMode),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
            fontWeight: FontWeight.bold,
            color: isHighlighted 
              ? AppColors.primary 
              : AppColors.textPrimary(isDarkMode),
          ),
        ),
      ],
    );
  }
}