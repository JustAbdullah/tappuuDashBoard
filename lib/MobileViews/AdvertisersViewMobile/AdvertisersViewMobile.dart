import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/AdvertiserProfileController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../AdminSidebar.dart';

class AdvertisersViewMobile extends StatefulWidget {
  const AdvertisersViewMobile({Key? key}) : super(key: key);

  @override
  _AdvertisersViewMobileState createState() => _AdvertisersViewMobileState();
}

class _AdvertisersViewMobileState extends State<AdvertisersViewMobile> {
  final AdvertiserProfileController controller = Get.put(AdvertiserProfileController());
  final TextEditingController _searchController = TextEditingController();
  int? _selectedUserId;
  bool _isFilterLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await controller.fetchUsersWithCounts();
    await controller.fetchAdvertiserProfiles();
  }

  void _showDeleteDialog(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error),
            SizedBox(width:10.w),
            Text('تأكيد الحذف', style: TextStyle(
              fontSize:15.sp, fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w700, color: AppColors.error,
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف هذا المعلن؟', style: TextStyle(
              fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark)),
            ),
            SizedBox(height: 8.h),
            Text('سيتم حذف جميع البيانات المرتبطة به!', style: TextStyle(
              fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.error.withOpacity(0.8),
            )),
          ],
        ),
        actions: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('إلغاء', style: TextStyle(
                  fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
              ))),
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                onPressed: controller.isDeleting.value ? null : () {
                  controller.deleteAdvertiserProfile(id);
                  Get.back();
                },
                child: controller.isDeleting.value
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.delete, size:20.r),
                      SizedBox(width:8.w),
                      Text('حذف', style: TextStyle(
                        fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.bold,
                      )),
                    ]),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _applyFilter() async {
    setState(() {
      _isFilterLoading = true;
    });
    
    try {
      await controller.fetchAdvertiserProfiles(
        userId: _selectedUserId,
        name: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
    } finally {
      setState(() {
        _isFilterLoading = false;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedUserId = null;
      _searchController.clear();
    });
    controller.fetchAdvertiserProfiles();
  }

  String _formatDaysAgo(DateTime date) {
    final now = DateTime.now();
    final days = now.difference(date).inDays;
    if (days == 0) return 'اليوم';
    if (days == 1) return 'منذ يوم واحد';
    return 'منذ $days يوم';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المعلنين', style: TextStyle(
          fontSize: 16.sp, fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w700, 
        )),
      ),
      drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              // شريط البحث
              Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(textDirection: TextDirection.rtl, children: [
                  Expanded(child: TextField(
                    textDirection: TextDirection.rtl,
                    controller: _searchController,
                    style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark)),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم المعلن  ...',
                      hintStyle: TextStyle(
                        fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark)),
                      prefixIcon: Icon(Icons.search, size:22.r),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => setState(() {}),
                  )),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, size:18.r, color: AppColors.textSecondary(isDark)),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilter();
                      },
                    ),
                ]),
              ),
              SizedBox(height: 16.h),
              
              // فلترة حسب المستخدم
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text('فلترة المعلنين', style: TextStyle(
                      fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700, 
                      color: AppColors.textPrimary(isDark),
                    )),
                    SizedBox(height:16.h),
                    
                    // فلترة حسب المستخدم
                    Text('فلترة حسب المستخدم:', style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    )),
                    SizedBox(height:8.h),
                    Obx(() {
                      if (controller.isLoadingUsers.value) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal:12.w),
                        decoration: BoxDecoration(
                          color: AppColors.card(isDark),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.divider(isDark))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedUserId,
                            isExpanded: true,
                            hint: Text(
                              'جميع المستخدمين',
                              style: TextStyle(
                                fontSize:14.sp, 
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('جميع المستخدمين', style: TextStyle(fontSize:14.sp)),
                              ),
                              ...controller.users.map((user) {
                                return DropdownMenuItem<int>(
                                  value: user.id,
                                  child: Text('${user.email} (ID: ${user.id})', style: TextStyle(
                                    fontSize:14.sp,
                                    color: AppColors.textPrimary(isDark),
                                  )),
                                );
                              }).toList(),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedUserId = newValue;
                              });
                            },
                          ),
                        ),
                      );
                    }),
                    SizedBox(height:24.h),
                    
                    // أزرار الفلترة
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _isFilterLoading ? null : _applyFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: Size(150.w, 45.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: _isFilterLoading
                              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
                              : Text('تطبيق الفلترة', style: TextStyle(fontSize:14.sp)),
                        ),
                        ElevatedButton(
                          onPressed: _clearFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            minimumSize: Size(150.w, 45.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text('حذف الفلترة', style: TextStyle(fontSize:14.sp)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height:24.h),
              
              // قائمة المعلنين
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (controller.profilesList.isEmpty) {
                  return Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined, size:64.r, color: AppColors.textSecondary(isDark)),
                      SizedBox(height:16.h),
                      Text('لا توجد بيانات للمعلنين', style: TextStyle(
                        fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                      )),
                    ],
                  ));
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.profilesList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final profile = controller.profilesList[index];
                    final createdAt = profile.createdAt ?? DateTime.now();
                    final dateText = _formatDaysAgo(createdAt);
                    
                    return Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 250.w,
                                child: Text(profile.name ?? 'بدون اسم', style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(isDark),
                                  
                                )),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text('ID: ${profile.id}', style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.sp,
                                )),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          
                          // صف اللوجو والوصف
                          Row(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // اللوجو
                              Container(
                                width: 60.r,
                                height: 60.r,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: Colors.grey[200],
                                  border: Border.all(color: AppColors.divider(isDark))),
                                child: profile.logo != null && profile.logo!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: profile.logo!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Icon(Icons.business, size: 30.r),
                                    )
                                  : Center(child: Icon(Icons.business, size: 30.r, color: Colors.grey)),
                              ),
                              SizedBox(width: 12.w),
                              
                              // الوصف
                              Expanded(
                                child: Text(
                                  profile.description ?? 'بدون وصف',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary(isDark),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          
                          // صف البريد الإلكتروني وتاريخ الإنشاء
                          Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Text('البريد الإلكتروني:', style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary(isDark),
                                    )),
                                    SizedBox(height: 4.h),
                                    Text(profile.user?.email ?? 'بدون بريد', style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.textPrimary(isDark),
                                    )),
                                  ],
                                ),
                              ),
                              SizedBox(width: 70.w,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Text('تاريخ الإنشاء:', style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary(isDark),
                                    )),
                                    SizedBox(height: 4.h),
                                    Text(dateText, style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.textPrimary(isDark),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          
                          // زر الحذف
                          Center(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.delete, size: 18.r),
                              label: Text('حذف المعلن', style: TextStyle(fontSize: 14.sp)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                              ),
                              onPressed: () => _showDeleteDialog(profile.id!),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}