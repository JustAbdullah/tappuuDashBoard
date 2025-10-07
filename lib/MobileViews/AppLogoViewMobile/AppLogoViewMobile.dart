import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/AppLogoController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../DeskTopViews/ImageUploadWidget.dart';
import '../AdminSidebar.dart';

class AppLogoViewMobile extends StatefulWidget {
  const AppLogoViewMobile({Key? key}) : super(key: key);

  @override
  _AppLogoViewMobileState createState() => _AppLogoViewMobileState();
}

class _AppLogoViewMobileState extends State<AppLogoViewMobile> {
  final AppLogoController controller = Get.put(AppLogoController());
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchAppLogo();
  }

  void _showEditDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (controller.appLogo.value != null) {
      _nameController.text = controller.appLogo.value!.name;
    } else {
      _nameController.clear();
    }
    
    controller.imageBytes.value = null;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary(isDark),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.photo, size: 24.r, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Text(
                    controller.appLogo.value != null 
                        ? 'تعديل شعار التطبيق' 
                        : 'إضافة شعار جديد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              
              TextField(
                textDirection: TextDirection.rtl,
                controller: _nameController,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textPrimary(isDark),
                ),
                decoration: InputDecoration(
                  labelText: 'اسم الشعار',
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: AppColors.card(isDark),
                  prefixIcon: Icon(Icons.text_fields, size: 22.r),
                ),
              ),
              SizedBox(height: 16.h),
              
              Text('صورة الشعار', style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              
              // عرض الصورة الحالية إذا كانت موجودة
              if (controller.appLogo.value != null && controller.appLogo.value!.url.isNotEmpty)
                Column(
                  children: [
                    Text(
                      'الصورة الحالية:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Image.network(
                        controller.appLogo.value!.url,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لتحميل صورة جديدة، استخدم الزر أدناه:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              
              Obx(() => ImageUploadWidget(
                imageBytes: controller.imageBytes.value,
                onPickImage: controller.pickImage,
                onRemoveImage: controller.removeImage,
              )),
              SizedBox(height: 24.h),
              
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('إلغاء', style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                      )),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: controller.isSaving.value ? null : () async {
                        if (_nameController.text.isEmpty) {
                          Get.snackbar('تحذير', 'الرجاء إدخال اسم الشعار',
                            backgroundColor: Colors.orange, colorText: Colors.white);
                          return;
                        }
                        
                        bool success;
                        if (controller.appLogo.value != null) {
                          // إذا كان هناك صورة جديدة مرفوعة
                          if (controller.imageBytes.value != null) {
                            success = await controller.updateLogoWithImage(
                              id: controller.appLogo.value!.id,
                              token: null,
                            );
                          } else {
                            // إذا لم يتم رفع صورة جديدة، نقوم بتحديث الاسم فقط
                            success = await controller.updateLogoUrl(
                              id: controller.appLogo.value!.id,
                              url: controller.appLogo.value!.url,
                              token: null,
                            );
                          }
                        } else {
                          success = await controller.createAppLogoWithImage(
                            name: _nameController.text,
                            token: null,
                          );
                        }
                        
                        if (success) {
                          Get.back();
                        }
                      },
                      child: controller.isSaving.value
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(controller.appLogo.value != null ? Icons.save : Icons.add, size: 20.r),
                                SizedBox(width: 8.w),
                                Text(
                                  controller.appLogo.value != null ? 'حفظ' : 'إضافة',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
        title: Text('إدارة شعار التطبيق', 
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          )
        ),
        actions: [
          IconButton(
            icon: Icon(
              controller.appLogo.value != null ? Icons.edit : Icons.add,
              size: 22.r,
            ),
            onPressed: _showEditDialog,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3.r,
              ),
            );
          }

          if (controller.appLogo.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64.r,
                    color: AppColors.textSecondary(isDark),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا يوجد شعار للتطبيق',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'انقر على زر + لتحميل شعار التطبيق',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: _showEditDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    ),
                    child: Text(
                      'إضافة شعار',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final logo = controller.appLogo.value!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Container(
                    width: 200.w,
                    height: 200.h,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        logo.url,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image,
                            size: 50.r,
                            color: AppColors.textSecondary(isDark),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  logo.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                SizedBox(height: 8.h),
                if (logo.createdAt != null)
                  Text(
                    'تم الإنشاء: ${_formatDate(logo.createdAt!)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: _showEditDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                  child: Text(
                    'تعديل الشعار',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}