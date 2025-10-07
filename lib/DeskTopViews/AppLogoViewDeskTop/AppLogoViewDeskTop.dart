import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/AppLogoController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../ImageUploadWidget.dart';

class AppLogoViewDeskTop extends StatefulWidget {
  const AppLogoViewDeskTop({Key? key}) : super(key: key);

  @override
  _AppLogoViewDeskTopState createState() => _AppLogoViewDeskTopState();
}

class _AppLogoViewDeskTopState extends State<AppLogoViewDeskTop> {
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
    
    // لا نحتاج لتحميل الصورة من الرابط، سنعرضها مباشرة من الرابط في الواجهة
    controller.imageBytes.value = null;

    Get.dialog(_buildDialog(isDark: isDark));
  }

  Widget _buildDialog({required bool isDark}) {
    return Center(
      child: Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 80.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500.w, minWidth: 400.w),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                _buildTextField('اسم الشعار', Icons.text_fields, _nameController, isDark),
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
                _buildActionButtons(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, 
      TextEditingController controller, bool isDark) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      style: TextStyle(
        fontSize: 16.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDark),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontFamily: AppTextStyles.tajawal,
          color: AppColors.textSecondary(isDark),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: AppColors.card(isDark),
        prefixIcon: Icon(icon, size: 22.r),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('إلغاء', style: TextStyle(
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          )),
        ),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
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
                  url: controller.appLogo.value!.url, // نستخدم نفس الرابط
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
              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(controller.appLogo.value != null ? Icons.save : Icons.add, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      controller.appLogo.value != null ? 'حفظ التعديلات' : 'إضافة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          AdminSidebarDeskTop(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إدارة شعار التطبيق',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(
                          controller.appLogo.value != null ? Icons.edit : Icons.add,
                          size: 18.r,
                        ),
                        label: Text(
                          controller.appLogo.value != null ? 'تعديل الشعار' : 'إضافة شعار',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        onPressed: _showEditDialog,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Expanded(
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
                                'انقر على زر "إضافة شعار" لتحميل شعار التطبيق',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDark),
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
                            Container(
                              width: 200.w,
                              height: 200.h,
                              decoration: BoxDecoration(
                                color: AppColors.card(isDark),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
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
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}