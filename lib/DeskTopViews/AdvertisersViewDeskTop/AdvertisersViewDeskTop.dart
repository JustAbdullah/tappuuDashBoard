import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/AdvertiserProfileController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';

import '../../core/data/model/AdvertiserProfile.dart';

class AdvertisersViewDeskTop extends StatefulWidget {
  const AdvertisersViewDeskTop({Key? key}) : super(key: key);

  @override
  _AdvertisersViewDeskTopState createState() => _AdvertisersViewDeskTopState();
}

class _AdvertisersViewDeskTopState extends State<AdvertisersViewDeskTop> {
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
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w, minWidth: 300.w, maxHeight: 300.h),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(textDirection: TextDirection.rtl, children: [
                    Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error),
                    SizedBox(width:10.w),
                    Text('تأكيد الحذف', style: TextStyle(
                      fontSize:15.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700, color: AppColors.error,
                    )),
                  ]),
                  SizedBox(height:16.h),
                  Text('هل أنت متأكد من حذف هذا المعلن؟', style: TextStyle(
                    fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDark)),
                  ),
                  Text('سيتم حذف جميع البيانات المرتبطة به!', style: TextStyle(
                    fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.error.withOpacity(0.8),
                  )),
                  SizedBox(height:24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('إلغاء', style: TextStyle(
                          fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                      ),
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
                          ? CircularProgressIndicator(color: Colors.white, strokeWidth:2.r)
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
            ),
          ),
        ),
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

  Future<void> _resetFilters() async {
    setState(() {
      _selectedUserId = null;
      _searchController.clear();
    });
    await controller.fetchAdvertiserProfiles();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor1 = isDark ? AppColors.grey900 : AppColors.grey50;
    final rowColor2 = isDark ? AppColors.grey800 : AppColors.grey100;
    
    return Scaffold(
      body: Row(children: [
        AdminSidebarDeskTop(),
        Expanded(child: Padding(
          padding: EdgeInsets.symmetric(horizontal:24.w, vertical:16.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl, children: [
            Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('إدارة المعلنين', style: TextStyle(
                fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
              )),
            ]),
            SizedBox(height:16.h),
            // شريط البحث مع زر المسح
            Center(child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth:600.w, minWidth:400.w),
              child: Container(
                height:56.h,
                padding: EdgeInsets.symmetric(horizontal:16.w),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius:12, offset: Offset(0,4),
                  )]),
                child: Row(textDirection: TextDirection.rtl, children: [
                  Expanded(child: TextField(
                    textDirection: TextDirection.rtl,
                    controller: _searchController,
                    style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark)),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم المعلن أو الوصف...',
                      hintStyle: TextStyle(
                        fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark)),
                      prefixIcon: Icon(Icons.search, size:22.r, color: AppColors.textSecondary(isDark)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size:18.r, color: AppColors.textSecondary(isDark)),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilter();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  )),
                  SizedBox(width:12.w),
                  ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                    child: Text('بحث', style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                    )),
                  ),
                ]),
              ),
            )),
            // فلترة حسب المستخدم مع زر إلغاء الفلترة
            SizedBox(height:16.h),
            Center(child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth:600.w, minWidth:400.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal:16.w, vertical:8.h),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.divider(isDark))),
                child: Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('فلترة حسب المستخدم:', style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    )),
                    SizedBox(width:12.w),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingUsers.value) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedUserId,
                            isExpanded: true,
                            hint: Text('جميع المستخدمين', style: TextStyle(
                              fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                            icon: Icon(Icons.arrow_drop_down, size:20.r, color: AppColors.textPrimary(isDark)),
                            style: TextStyle(
                              fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textPrimary(isDark)), // اللون حسب الوضع
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('جميع المستخدمين', 
                                  style: TextStyle(
                                    fontSize:14.sp,
                                    color: AppColors.textPrimary(isDark)))),
                              ...controller.users.map((user) {
                                return DropdownMenuItem<int>(
                                  value: user.id,
                                  child: Text('${user.email} (ID: ${user.id})', 
                                    style: TextStyle(
                                      fontSize:14.sp,
                                      color: AppColors.textPrimary(isDark))),
                                );
                              }).toList(),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedUserId = newValue;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                     SizedBox(width:16.w),
                    ElevatedButton(
                      onPressed: _isFilterLoading ? null : _applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal:20.w, vertical:8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                      child: _isFilterLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
                        : Text('تطبيق الفلترة', style: TextStyle(
                            fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                          )),
                    ),
                  ],
                ),
              ),
            )),
            SizedBox(height:24.h),
            Expanded(child: Container(
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius:12, offset: Offset(0,4),
                )]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: Container(
                    padding: EdgeInsets.symmetric(vertical:16.h, horizontal:16.w),
                    decoration: BoxDecoration(color: isDark ? AppColors.grey800 : AppColors.grey200),
                    child: Row(textDirection: TextDirection.rtl, children: [
                      _buildHeaderCell("معرف المعلن", 1),
                      _buildHeaderCell("اللوجو", 1),
                      _buildHeaderCell("اسم المعلن", 2),
                      _buildHeaderCell("الوصف", 3),
                      _buildHeaderCell("البريد الإلكتروني", 2),
                      _buildHeaderCell("تاريخ الإنشاء", 1),
                      _buildHeaderCell("الإجراءات", 1),
                    ]),
                  )),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth:3.r)),
                      );
                    }
                    if (controller.profilesList.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.business_outlined, size:64.r, color: AppColors.textSecondary(isDark)),
                          SizedBox(height:16.h),
                          Text('لا توجد بيانات للمعلنين', style: TextStyle(
                            fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )),
                        ]),
                      ));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAdvertiserRow(
                          controller.profilesList[index], 
                          index, 
                          isDark,
                          index % 2 == 0 ? rowColor1 : rowColor2
                        ),
                        childCount: controller.profilesList.length,
                      ),
                    );
                  }),
                ]),
              ),
            )),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(text, 
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w700, 
          color: AppColors.textPrimary(Theme.of(context).brightness == Brightness.dark),
        )),
    );
  }

  Widget _buildAdvertiserRow(AdvertiserProfile profile, int index, bool isDark, Color color) {
    final createdAt = profile.createdAt ?? DateTime.now().subtract(Duration(days: 1));
    final dateText = _formatDaysAgo(createdAt);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(profile.id.toString(), 1),
        _buildLogoCell(profile.logo),
        _buildCell(profile.name ?? 'بدون اسم', 2),
        _buildCell(profile.description ?? 'بدون وصف', 3, maxLines: 2),
        _buildCell(profile.user?.email ?? 'بدون بريد', 2),
        _buildCell(dateText, 1),
        Expanded(flex:1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: Icon(Icons.delete, size:18.r, color: AppColors.error),
            onPressed: () => _showDeleteDialog(profile.id!),
          ),
        ])),
      ]),
    );
  }

  Widget _buildCell(String text, int flex, {
    int maxLines = 1,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(text, 
          textAlign: TextAlign.center,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize:12.sp, 
            fontFamily: AppTextStyles.tajawal,
            fontWeight: fontWeight,
          )),
      ),
    );
  }

  Widget _buildLogoCell(String? logoUrl) {
    return Expanded(
      flex: 1,
      child: Center(
        child: logoUrl != null && logoUrl.isNotEmpty
          ? Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                image: DecorationImage(
                  image: NetworkImage(logoUrl),
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Icon(Icons.business, size: 30.r),
      ),
    );
  }
  
  String _formatDaysAgo(DateTime date) {
    final now = DateTime.now();
    final days = now.difference(date).inDays;
    if (days == 0) return 'اليوم';
    if (days == 1) return 'منذ يوم واحد';
    return 'منذ $days يوم';
  }
}