import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/AdminAdsController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';

import '../../core/data/model/AdResponse.dart';
import '../../core/data/model/UserModel.dart' as UserModel;
import '../../core/data/model/category.dart' as CatrTra;
import '../../core/data/model/subcategory_level_one.dart';
import '../../core/data/model/subcategory_level_two.dart';

class AdminAdsDesktopUnderView extends StatefulWidget {
  const AdminAdsDesktopUnderView({Key? key}) : super(key: key);

  @override
  _AdminAdsDesktopUnderViewState createState() => _AdminAdsDesktopUnderViewState();
}

class _AdminAdsDesktopUnderViewState extends State<AdminAdsDesktopUnderView> {
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
    await controller.fetchAdminAds(lang: _lang, status: 'under_review');
  }

  void _applyFilters() {
    setState(() {
      _isFilterLoading = true;
    });
    
    controller.fetchAdminAds(
      searchTitle:_searchController.text.toString(),
      status: 'under_review',
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
    controller.fetchAdminAds(lang: _lang, status: 'under_review');
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
            Text('هل أنت متأكد من حذف هذا الإعلان؟', style: TextStyle(
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
  
  
  void _showispublished(int adId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.primary),
            SizedBox(width:10.w),
            Text(' نشر الاعلان', style: TextStyle(
              fontSize:15.sp, fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w700, color: AppColors.primary,
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل انت متاكد برغبتك   بنشر الإعلان؟', style: TextStyle(
              fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark)),
            ),
            SizedBox(height: 8.h),
            Text('سيتم مباشرة تطبيق العملية', style: TextStyle(
              fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.primary.withOpacity(0.8),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                onPressed: controller.isLoadingAdminAds.value ? null : () {
                  controller.togglePublish(adId,'under_review','منشور');
                  //published
                  Get.back();
                },
                child: controller.isLoadingAdminAds.value
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.done, size:20.r),
                      SizedBox(width:8.w),
                      Text('تطبيق العملية', style: TextStyle(
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

  // شاشة تفاصيل الإعلان المنبثقة - تصميم محسن
// شاشة تفاصيل الإعلان المنبثقة - تصميم محسن ومهني
void _showAdDetails(Ad ad) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = AppColors.textPrimary(isDark);
  final bgColor = AppColors.card(isDark);
  final accentColor = AppColors.primary;
  int _currentImageIndex = 0;
  
  Get.dialog(
    Dialog(
      insetPadding: EdgeInsets.all(16.r),
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  icon: Icon(Icons.close, size: 22.r, color: textColor),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.divider(isDark)),
            SizedBox(height: 20.h),
            
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معرض الصور - تصميم محترف
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
                                            fit: BoxFit.contain,
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
                    
                    // العنوان والسعر - تصميم أنيق
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              ad.title,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: AppTextStyles.tajawal,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
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
                                fontSize: 14.sp,
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
                    
                    // وصف الإعلان - تصميم مضغوط
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
                              fontSize: 14.sp,
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
                              fontSize: 13.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: textColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    
                    // بيانات المعلن - تصميم أنيق
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
                              fontSize: 14.sp,
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
                    
                    // خصائص الإعلان - تصميم جدولي
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
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(3),
                              },
                              border: TableBorder.symmetric(
                                inside: BorderSide(
                                  color: AppColors.divider(isDark).withOpacity(0.3),
                                  width: 1
                                ),
                              ),
                              children: ad.attributes.map((attribute) {
                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                  ),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                                      child: Text(
                                        attribute.name,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                          fontSize: 12.5.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                                      child: Text(
                                        attribute.value,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                          fontSize: 12.5.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                    
                    // معلومات الإعلان - تصميم مضغوط
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
                              fontSize: 14.sp,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ويدجت لعرض صف بمصاحب لأيقونة
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
            fontSize: 12.5.sp,
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
              fontSize: 12.5.sp,
              fontFamily: AppTextStyles.tajawal,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ),
      ],
    ),
  );
}

// ويدجت لعرض معلومات في شكل شريحة
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


  Widget _buildInfoRow(String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.textPrimary(isDark);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.r, color: AppColors.primary),
          ),
          SizedBox(width: 16.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
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
            // شريط العنوان وأزرار اللغة
            Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('الإعلانات تحت المراجعة', style: TextStyle(
                fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
              )),
              Row(textDirection: TextDirection.rtl, children: [
                _buildLangButton('ar', 'العربية', true),
                SizedBox(width:10.w),
                _buildLangButton('en', 'English', false),
              ]),
            ]),
            SizedBox(height:16.h),
            
            // شريط البحث
            Center(child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth:800.w),
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
                      hintText: 'ابحث في الإعلانات...',
                      hintStyle: TextStyle(
                        fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark)),
                      prefixIcon: Icon(Icons.search, size:22.r),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  )),
                  SizedBox(width:12.w),
                  ElevatedButton(
                    onPressed: _applyFilters,
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
            
            // سطر الفلترات المتعددة
            SizedBox(height:16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // فلترة التصنيف الرئيسي
                  Expanded(
                    child: _buildFilterDropdown(
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
                            orElse: () => CatrTra. Translation(
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
                  ),
                  SizedBox(width: 12.w),
                  
                  // فلترة التصنيف الفرعي الأول
                  Expanded(
                    child: Obx(() => _buildFilterDropdown(
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
                  ),
                  SizedBox(width: 12.w),
                  
                  // فلترة التصنيف الفرعي الثاني
                  Expanded(
                    child: Obx(() => _buildFilterDropdown(
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
                  ),
                  SizedBox(width: 12.w),
                  
                  // فلترة المستخدم
                  Expanded(
                    child: Obx(() => _buildFilterDropdown(
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
                  ),
                  SizedBox(width: 12.w),
                  
                  // زر تطبيق الفلترة وإلغاء الفلترة
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isFilterLoading ? null : _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                        child: _isFilterLoading
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                          : Text('تطبيق الفلترة', style: TextStyle(
                              fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                            )),
                      ),
                      SizedBox(width: 10.w),
                      OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                        child: Text('إلغاء الفلترة', style: TextStyle(
                          fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height:24.h),
            
            // جدول الإعلانات
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
                      _buildHeaderCell("معرف الإعلان", 1),
                      _buildHeaderCell("صورة الإعلان", 1),
                      _buildHeaderCell("عنوان الإعلان", 2),
                      _buildHeaderCell("السعر", 1),
                      _buildHeaderCell("المعلن", 1),
                      _buildHeaderCell("البريد الإلكتروني", 1),
                      _buildHeaderCell("تاريخ الإنشاء", 1), 
                       _buildHeaderCell("حالة الاعلان", 1),
                      _buildHeaderCell("الإجراءات", 2),
                    ]),
                  )),
                  Obx(() {
                    if (controller.isLoadingAdminAds.value) {
                      return SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth:3.r)),
                      );
                    }
                    if (controller.adminAdsList.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.list_alt, size:64.r, color: AppColors.textSecondary(isDark)),
                          SizedBox(height:16.h),
                          Text('لا توجد إعلانات', style: TextStyle(
                            fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )),
                        ]),
                      ));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAdRow(
                          controller.adminAdsList[index], 
                          index, 
                          isDark,
                          index % 2 == 0 ? rowColor1 : rowColor2
                        ),
                        childCount: controller.adminAdsList.length,
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

  Widget _buildLangButton(String lang, String text, bool isLeft) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _lang = lang;
          _applyFilters();
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _lang == lang ? Colors.white : AppColors.primary,
        backgroundColor: _lang == lang ? AppColors.primary : Colors.transparent,
        side: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
          topLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
          bottomLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
          topRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
          bottomRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
        ))),
      child: Text(text, style: TextStyle(
        fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
      )),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String title,
    required int? value,
    required List<T> items,
    required Function(int?) onChanged,
    required String Function(T) displayText,
    required bool isDark,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Text(title, style: TextStyle(
          fontSize:12.sp, 
          fontFamily: AppTextStyles.tajawal,
          color: AppColors.textSecondary(isDark),
        )),
        SizedBox(height:4.h),
        Container(
          height:40.h,
          padding: EdgeInsets.symmetric(horizontal:12.w),
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.divider(isDark))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: value,
              isExpanded: true,
              hint: isLoading 
                ? Text('جاري التحميل...', style: TextStyle(fontSize:12.sp))
                : Text('اختر $title', style: TextStyle(fontSize:12.sp)),
              icon: Icon(Icons.arrow_drop_down, size:18.r, color: AppColors.textSecondary(isDark)),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text('الكل', style: TextStyle(fontSize:12.sp)),
                ),
                ...items.map((item) {
                  final id = _getIdFromItem(item);
                  return DropdownMenuItem<int?>(
                    value: id,
                    child: Text(displayText(item), 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize:12.sp)),
                  );
                }).toList(),
              ],
              onChanged: isLoading ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  int _getIdFromItem(dynamic item) {
    if (item is  CatrTra. Category) return item.id;
    if (item is SubcategoryLevelOne) return item.id;
    if (item is SubcategoryLevelTwo) return item.id;
    if (item is UserModel.UserModel) return item.id;
    return 0;
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

  Widget _buildAdRow(Ad ad, int index, bool isDark, Color color) {
    final createdAt = ad.createdAt;
    final dateText = _formatDaysAgo(createdAt);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(ad.id.toString(), 1),
        _buildImageCell(ad.images.isNotEmpty ? ad.images.first : ''),
        _buildCell(ad.title, 2),
        _buildCell(_formatPrice(ad.price), 1), // استخدام الدالة الجديدة لتنسيق السعر
        _buildCell(ad.advertiser.name ?? 'بدون اسم', 1),
        _buildCell(ad.user.email.toString(), 1),
        _buildCell(dateText, 1), 
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // زر التفاصيل الجديد
              IconButton(
                icon: Icon(Icons.info_outline, size: 18.r, color: AppColors.primary),
                onPressed: () => _showAdDetails(ad),
              ),
              SizedBox(width: 3.w),
              IconButton(
                icon: Icon(Icons.delete, size:18.r, color: AppColors.error),
                onPressed: () => _showDeleteDialog(ad.id),
              ), 
               SizedBox(width: 3.w),
               IconButton(
                icon: Icon(Icons.book_online_sharp, size:18.r, color: AppColors.darkBlue),
                onPressed: () => _showispublished(ad.id),
              ), 
             
            ],
          ),
        ),
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

  Widget _buildImageCell(String imageUrl) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2.r)),
                errorWidget: (context, url, error) => Icon(Icons.image, size: 20.r),
              )
            : Icon(Icons.image, size: 20.r),
        ),
      ),
    );
  }
}