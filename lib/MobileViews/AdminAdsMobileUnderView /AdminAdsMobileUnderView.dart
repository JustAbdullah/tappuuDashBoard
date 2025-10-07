import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tappuu_dashboard/controllers/AdminAdsController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/AdResponse.dart';

import '../../core/data/model/category.dart' as categoryTras;
import '../../core/data/model/subcategory_level_one.dart';
import '../../core/data/model/subcategory_level_two.dart';
import '../AdminSidebar.dart';

class AdminAdsMobileUnderView extends StatefulWidget {
  const AdminAdsMobileUnderView({Key? key}) : super(key: key);

  @override
  _AdminAdsMobileUnderViewState createState() => _AdminAdsMobileUnderViewState();
}

class _AdminAdsMobileUnderViewState extends State<AdminAdsMobileUnderView> {
  final AdminAdsController controller = Get.put(AdminAdsController());
  final TextEditingController _searchController = TextEditingController();
  String _lang = 'ar';
  
  // متغيرات الفلترة
  int? _selectedCategoryId;
  int? _selectedSubCategoryOneId;
  int? _selectedSubCategoryTwoId;
  int? _selectedUserId;
  bool _isFilterLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await controller.fetchUsersWithCounts();
    await controller.fetchCategories(_lang);
    await controller.fetchAdminAds(lang: _lang, status: '	under_review');
  }

  void _applyFilters() {
    setState(() {
      _isFilterLoading = true;
    });
    
    controller.fetchAdminAds(
      status: '	under_review',
      lang: _lang,
      categoryId: _selectedCategoryId,
      subCategoryLevelOneId: _selectedSubCategoryOneId,
      subCategoryLevelTwoId: _selectedSubCategoryTwoId,
      userId: _selectedUserId,
    ).then((_) {
      setState(() {
        _isFilterLoading = false;
      });
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSubCategoryOneId = null;
      _selectedSubCategoryTwoId = null;
      _selectedUserId = null;
      _searchController.clear();
    });
    controller.fetchAdminAds(lang: _lang, status: '	under_review');
  }

  // تنسيق السعر بصيغة آلاف وملايين
  String _formatPrice(double? price) {
    if (price == null) return '0 ليرة سورية';
    
    final formatter = NumberFormat('#,###,###');
    final formattedPrice = formatter.format(price);
    
    return '$formattedPrice ليرة سورية';
  }

  void _showDeleteDialog(int adId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error),
            SizedBox(width:10.w),
            Text('تأكيد الحذف', style: TextStyle(
              fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w700, color: AppColors.error,
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف هذا الإعلان؟', style: TextStyle(
              fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
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
                  fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
              ))),
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal:24.w, vertical:12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                onPressed: controller.isLoadingAdminAds.value ? null : () {
                  controller.deleteAdminAd(adId);
                  Get.back();
                },
                child: controller.isLoadingAdminAds.value
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.delete, size:20.r),
                      SizedBox(width:8.w),
                      Text('حذف', style: TextStyle(
                        fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
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

  // شاشة تفاصيل الإعلان المنبثقة للجوال
  void _showAdDetails(Ad ad) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.textPrimary(isDark);
    final bgColor = AppColors.card(isDark);
    final accentColor = AppColors.primary;
    int _currentImageIndex = 0;
    
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            // رأس الشاشة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفاصيل الإعلان',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.r, color: textColor),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Divider(height: 1, color: AppColors.divider(isDark)),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معرض الصور
                    if (ad.images.isNotEmpty) ...[
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            children: [
                              Container(
                                height: 220.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  color: AppColors.surface(isDark).withOpacity(0.2),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: PageView.builder(
                                        itemCount: ad.images.length,
                                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                                        itemBuilder: (context, index) {
                                          return CachedNetworkImage(
                                            imageUrl: ad.images[index],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(
                                                color: accentColor,
                                                strokeWidth: 2.r,
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: AppColors.surface(isDark),
                                              child: Center(
                                                child: Icon(Icons.image_not_supported, 
                                                  size: 40.r, 
                                                  color: AppColors.textSecondary(isDark),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    
                                    // مؤشر الصور
                                    if (ad.images.length > 1)
                                      Positioned(
                                        bottom: 10.h,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(ad.images.length, (index) {
                                            return Container(
                                              width: 8.r,
                                              height: 8.r,
                                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _currentImageIndex == index 
                                                  ? accentColor 
                                                  : AppColors.textSecondary(isDark).withOpacity(0.5),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        },
                      ),
                    ],
                    
                    // العنوان والسعر
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            ad.title,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: accentColor),
                            ),
                            child: Text(
                              _formatPrice(ad.price),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: AppTextStyles.tajawal,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // وصف الإعلان
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            'الوصف',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            ad.description,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: textColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // بيانات المعلن
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            'بيانات المعلن',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRowWithIcon(Icons.person_outline, 'الاسم:', ad.advertiser.name ?? 'غير معروف'),
                          _buildDetailRowWithIcon(Icons.email_outlined, 'البريد:', ad.user.email),
                          if (ad.advertiser.contactPhone != null)
                            _buildDetailRowWithIcon(Icons.phone_android, 'هاتف:', ad.advertiser.contactPhone!),
                          if (ad.advertiser.whatsappPhone != null)
                            _buildDetailRowWithIcon(Icons.wallet, 'واتساب:', ad.advertiser.whatsappPhone!),
                          if (ad.city != null)
                            _buildDetailRowWithIcon(Icons.location_on_outlined, 'المدينة:', ad.city!.name),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // خصائص الإعلان
                    if (ad.attributes.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppColors.surface(isDark),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              'خصائص الإعلان',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: AppTextStyles.tajawal,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ...ad.attributes.map((attribute) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Text(
                                      attribute.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        attribute.value,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                    
                    // معلومات الإعلان
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            'معلومات الإعلان',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            textDirection: TextDirection.rtl,
                            children: [
                              _buildInfoChip('رقم: #${ad.id}', Icons.numbers),
                              _buildInfoChip('الحالة: ${ad.status == 'published' ? 'منشور' : 'مخفي'}', Icons.visibility),
                              _buildInfoChip('مميز: ${ad.is_premium ? 'نعم' : 'لا'}', Icons.star_border),
                              _buildInfoChip('المشاهدات: ${ad.views}', Icons.remove_red_eye_outlined),
                              _buildInfoChip('التصنيف: ${ad.category.name}', Icons.category_outlined),
                              _buildInfoChip('التاريخ: ${DateFormat('yyyy/MM/dd').format(ad.createdAt)}', Icons.calendar_today_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // أزرار الإجراءات
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.delete, size: 18.r, color: AppColors.error),
                            label: Text('حذف', style: TextStyle(
                              fontSize: 14.sp, 
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.error,
                            )),
                            onPressed: () => _showDeleteDialog(ad.id),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              side: BorderSide(color: AppColors.error),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.close, size: 18.r),
                            label: Text('إغلاق', style: TextStyle(
                              fontSize: 14.sp, 
                              fontFamily: AppTextStyles.tajawal,
                            )),
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRowWithIcon(IconData icon, String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.textPrimary(isDark);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 18.r, color: AppColors.primary),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppColors.primary;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 16.r, color: accentColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ],
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

  Widget _buildFilterDropdown({
    required String title,
    required int? value,
    required List<dynamic> items,
    required Function(int?) onChanged,
    required String Function(dynamic) displayText,
    required bool isDark,
    bool isLoading = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider(isDark))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: value,
          isExpanded: true,
          hint: isLoading 
            ? Text('جاري التحميل...', style: TextStyle(fontSize:14.sp))
            : Text('اختر $title', style: TextStyle(fontSize:14.sp)),
          icon: Icon(Icons.arrow_drop_down, size:22.r, color: AppColors.textSecondary(isDark)),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text('الكل', style: TextStyle(fontSize:14.sp)),
            ),
            ...items.map((item) {
              final id = _getIdFromItem(item);
              return DropdownMenuItem<int?>(
                value: id,
                child: Text(displayText(item), 
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize:14.sp)),
              );
            }).toList(),
          ],
          onChanged: isLoading ? null : onChanged,
        ),
      ),
    );
  }

  int _getIdFromItem(dynamic item) {
    if (item is categoryTras.Category) return item.id;
    if (item is SubcategoryLevelOne) return item.id;
    if (item is SubcategoryLevelTwo) return item.id;
    if (item is UserModel) return item.id;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.appBar(isDark),
        elevation: 2,
        title: Text('الإعلانات تحت المراجعة', style: TextStyle(
          fontSize: 18.sp, 
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w800, 
          color: AppColors.onPrimary,
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt, color: AppColors.primary),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            // Language Toggle
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLangButton('ar', 'العربية', true),
                SizedBox(width: 10.w),
                _buildLangButton('en', 'English', false),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Search Field
            Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: TextField(
                textDirection: TextDirection.rtl,
                controller: _searchController,
                style: TextStyle(
                  fontSize: 14.sp, 
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textPrimary(isDark)),
                decoration: InputDecoration(
                  hintText: 'ابحث في الإعلانات...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp, 
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark)),
                  prefixIcon: Icon(Icons.search, size: 22.r),
                  border: InputBorder.none,
                ),
                onChanged: (value) => _applyFilters(),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Ads List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingAdminAds.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary, 
                      strokeWidth: 3.r,
                    ),
                  );
                }
                
                if (controller.adminAdsList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt, 
                          size: 64.r, 
                          color: AppColors.textSecondary(isDark)),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد إعلانات',
                          style: TextStyle(
                            fontSize: 16.sp, 
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                        ),
                    )],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: controller.adminAdsList.length,
                  itemBuilder: (context, index) {
                    final ad = controller.adminAdsList[index];
                    final createdAt = ad.createdAt;
                    final dateText = _formatDaysAgo(createdAt);
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 16.h),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: InkWell(
                        onTap: () => _showAdDetails(ad),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.rtl,
                            children: [
                              // الصورة والعنوان
                              Row(
                                textDirection: TextDirection.rtl,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (ad.images.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: CachedNetworkImage(
                                        imageUrl: ad.images.first,
                                        width: 80.r,
                                        height: 80.r,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: AppColors.card(isDark),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary,
                                              strokeWidth: 2.r,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: AppColors.card(isDark),
                                          child: Center(
                                            child: Icon(Icons.image, size: 30.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        Text(
                                          ad.title,
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: AppTextStyles.tajawal,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary(isDark),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          _formatPrice(ad.price),
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontFamily: AppTextStyles.tajawal,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              
                              // معلومات المعلن
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  CircleAvatar(
                                    radius: 16.r,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: Icon(Icons.person, size: 18.r, color: AppColors.primary),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      ad.advertiser.name ?? 'بدون اسم',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  CircleAvatar(
                                    radius: 16.r,
                                    backgroundColor: AppColors.info.withOpacity(0.1),
                                    child: Icon(Icons.email, size: 18.r, color: AppColors.info),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      ad.user.email,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              
                              // معلومات الإعلان
                              Row(
                                textDirection: TextDirection.rtl,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Icon(Icons.calendar_today, size: 16.r, color: AppColors.textSecondary(isDark)),
                                      SizedBox(width: 4.w),
                                      Text(
                                        dateText,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Icon(Icons.visibility, size: 16.r, color: AppColors.textSecondary(isDark)),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${ad.views} مشاهدة',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Icon(Icons.category, size: 16.r, color: AppColors.textSecondary(isDark)),
                                      SizedBox(width: 4.w),
                                      Text(
                                        ad.category.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              
                              // أزرار الإجراءات
                              Row(
                                textDirection: TextDirection.rtl,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: Icon(Icons.info_outline, size: 18.r, color: AppColors.primary),
                                      label: Text('التفاصيل', style: TextStyle(
                                        fontSize: 14.sp, 
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.primary,
                                      )),
                                      onPressed: () => _showAdDetails(ad),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        side: BorderSide(color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: Icon(Icons.delete, size: 18.r, color: AppColors.error),
                                      label: Text('حذف', style: TextStyle(
                                        fontSize: 14.sp, 
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.error,
                                      )),
                                      onPressed: () => _showDeleteDialog(ad.id),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        side: BorderSide(color: AppColors.error),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String lang, String text, bool isLeft) {
    final isSelected = _lang == lang;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _lang = lang;
            _applyFilters();
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
              bottomLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
              topRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
              bottomRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تصفية الإعلانات', style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDark),
                  )),
                  IconButton(
                    icon: Icon(Icons.close, size: 22.r),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              
              // فلترة التصنيف الرئيسي
              Text('التصنيف الرئيسي', style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              _buildFilterDropdown(
                title: 'التصنيف الرئيسي',
                value: _selectedCategoryId,
                items: controller.categoriesList,
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    _selectedSubCategoryOneId = null;
                    _selectedSubCategoryTwoId = null;
                    if (value != null) {
                      controller.fetchSubCategories(
                        categoryId: value,
                        language: _lang,
                      );
                    }
                  });
                },
                displayText: (category) => category.translations
                    .firstWhere(
                      (t) => t.language == 'ar',
                      orElse: () =>categoryTras. Translation(
                        id: 0,
                        categoryId: 0,
                        language: 'ar',
                        name: 'غير معروف',
                        description: '',
                      ),
                    )
                    .name,
                isDark: isDark,
              ),
              SizedBox(height: 16.h),
              
              // فلترة التصنيف الفرعي الأول
              Text('التصنيف الفرعي الأول', style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              Obx(() => _buildFilterDropdown(
                title: 'التصنيف الفرعي',
                value: _selectedSubCategoryOneId,
                items: controller.parentSubCategoriesList,
                onChanged: (value) {
                  setState(() {
                    _selectedSubCategoryOneId = value;
                    _selectedSubCategoryTwoId = null;
                    if (value != null) {
                      controller.fetchSubCategoriesLevelTwo(
                        parent1Id: value,
                        language: _lang,
                      );
                    }
                  });
                },
                displayText: (subCat) => subCat.name,
                isDark: isDark,
                isLoading: controller.isLoadingParentSubCategories.value,
              )),
              SizedBox(height: 16.h),
              
              // فلترة التصنيف الفرعي الثاني
              Text('التصنيف الفرعي الثاني', style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              Obx(() => _buildFilterDropdown(
                title: 'التصنيف الفرعي الثانوي',
                value: _selectedSubCategoryTwoId,
                items: controller.subCategoriesLevelTwoList,
                onChanged: (value) {
                  setState(() {
                    _selectedSubCategoryTwoId = value;
                  });
                },
                displayText: (subCat) => subCat.name,
                isDark: isDark,
                isLoading: controller.isLoadingSubCategoriesLevelTwo.value,
              )),
              SizedBox(height: 16.h),
              
              // فلترة المستخدم
              Text('المستخدم', style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              Obx(() => _buildFilterDropdown(
                title: 'المستخدم',
                value: _selectedUserId,
                items: controller.users,
                onChanged: (value) {
                  setState(() {
                    _selectedUserId = value;
                  });
                },
                displayText: (user) => '${user.email} (ID: ${user.id})',
                isDark: isDark,
                isLoading: controller.isLoadingUsers.value,
              )),
              SizedBox(height: 30.h),
              
              // أزرار التطبيق والإلغاء
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isFilterLoading ? null : _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                      )),
                      child: _isFilterLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                        : Text('تطبيق الفلترة', style: TextStyle(
                            fontSize: 16.sp, 
                            fontFamily: AppTextStyles.tajawal,
                          )),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                      )),
                      child: Text('إلغاء الفلترة', style: TextStyle(
                        fontSize: 16.sp, 
                        fontFamily: AppTextStyles.tajawal,
                      )),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}