import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/WaitingScreenController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../ImageUploadWidget.dart';

class WaitingScreenViewDeskTop extends StatefulWidget {
  const WaitingScreenViewDeskTop({Key? key}) : super(key: key);

  @override
  _WaitingScreenViewDeskTopState createState() => _WaitingScreenViewDeskTopState();
}

class _WaitingScreenViewDeskTopState extends State<WaitingScreenViewDeskTop> {
  final WaitingScreenController controller = Get.put(WaitingScreenController());
  final TextEditingController _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchWaitingScreen();
  }

  void _showEditDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // تعيين القيم الحالية إذا كانت موجودة
    if (controller.waitingScreen.value != null) {
      _colorController.text = controller.waitingScreen.value!.color;
      controller.selectedColor.value = controller.waitingScreen.value!.color;
    } else {
      _colorController.text = '#FFFFFF';
      controller.selectedColor.value = '#FFFFFF';
    }
    
    // التأكد من أن اللون المختار ليس فارغًا
    if (controller.selectedColor.value.isEmpty) {
      controller.selectedColor.value = '#FFFFFF';
      _colorController.text = '#FFFFFF';
    }
    
    controller.imageBytes.value = null;

    Get.dialog(_buildDialog(isDark: isDark));
  }

  void _showColorPicker() {
    Color currentColor = Colors.white;
    if (controller.selectedColor.value.isNotEmpty && controller.selectedColor.value != 'transparent') {
      currentColor = _parseColor(controller.selectedColor.value);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر لون الخلفية', textDirection: TextDirection.rtl),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                String hexColor = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                controller.updateColor(hexColor);
                _colorController.text = hexColor;
                setState(() {}); // إضافة هذا السطر لتحديث الواجهة
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('تم', textDirection: TextDirection.rtl),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('0x')) {
        return Color(int.parse(colorString));
      } else {
        return Colors.white;
      }
    } catch (e) {
      return Colors.white;
    }
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
                    Icon(Icons.palette, size: 24.r, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Text(
                      controller.waitingScreen.value != null 
                          ? 'تعديل شاشة الانتظار' 
                          : 'إعداد شاشة الانتظار',
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
                
                // حقل اختيار اللون
                Text('لون الخلفية', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                )),
                SizedBox(height: 8.h),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _colorController,
                        onChanged: (value) {
                          // تحديث اللون عند إدخال قيمة يدوية
                          if (value.isNotEmpty && value.startsWith('#')) {
                            controller.updateColor(value);
                            setState(() {}); // تحديث الواجهة
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'أدخل كود اللون (مثل #FFFFFF)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          filled: true,
                          fillColor: AppColors.card(isDark),
                          suffixIcon: Icon(Icons.color_lens),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Obx(() => Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: _parseColor(controller.selectedColor.value),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColors.divider(isDark)),
                      ),
                    )),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'يمكنك إدخال كود اللون يدوياً باستخدام الصيغة HEX (مثل #FFFFFF للون الأبيض)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _showColorPicker,
                    child: Text('أو اختر لونًا من المعرض', style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.primary,
                    )),
                  ),
                ),
                
                SizedBox(height: 16.h),
                Text('صورة الشاشة (اختياري)', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                )),
                SizedBox(height: 8.h),
                
                // عرض الصورة الحالية إذا كانت موجودة
                if (controller.waitingScreen.value != null && controller.waitingScreen.value!.imageUrl.isNotEmpty)
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
                        width: 150.w,
                        height: 150.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Image.network(
                          controller.waitingScreen.value!.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                        ),
                      ),
                      SizedBox(height: 16.h),
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
            // التحقق من صحة اللون
            String selectedColor = controller.selectedColor.value;
            if (selectedColor.isEmpty || !selectedColor.startsWith('#')) {
              Get.snackbar(
                'تنبيه',
                'يجب اختيار لون صالح للخلفية',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white
              );
              return;
            }

            bool success;
            if (controller.imageBytes.value != null) {
              success = await controller.updateImageWithUpload();
            } else {
              success = await controller.createOrUpdateWaitingScreen(
                color: selectedColor,
                imageUrl: controller.waitingScreen.value?.imageUrl,
                token: null,
              );
            }
            
            if (success) {
              Get.back();
              // إعادة تحميل البيانات لضمان التحديث
              controller.fetchWaitingScreen();
            }
          },
          child: controller.isSaving.value
              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(controller.waitingScreen.value != null ? Icons.save : Icons.add, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      controller.waitingScreen.value != null ? 'حفظ التعديلات' : 'إنشاء جديد',
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
                        'إعدادات شاشة الانتظار',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(
                          controller.waitingScreen.value != null ? Icons.edit : Icons.add,
                          size: 18.r,
                        ),
                        label: Text(
                          controller.waitingScreen.value != null ? 'تعديل الإعدادات' : 'إضافة إعدادات',
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

                      if (controller.waitingScreen.value == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.color_lens,
                                size: 64.r,
                                color: AppColors.textSecondary(isDark),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'لا توجد إعدادات لشاشة الانتظار',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'انقر على زر "إضافة إعدادات" لتهيئة شاشة الانتظار',
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

                      final waitingScreen = controller.waitingScreen.value!;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // معاينة شاشة الانتظار
                            Container(
                              width: 300.w,
                              height: 400.h,
                              decoration: BoxDecoration(
                                color: _parseColor(waitingScreen.color),
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
                                child: waitingScreen.imageUrl.isNotEmpty
                                    ? Image.network(
                                        waitingScreen.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 50.r,
                                              color: AppColors.textSecondary(isDark),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.color_lens,
                                          size: 80.r,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // معلومات الإعدادات
                            Container(
                              width: 300.w,
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: AppColors.card(isDark),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'معلومات الإعدادات:',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: AppTextStyles.tajawal,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Text(
                                        'لون الخلفية: ',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        ),
                                      ),
                                      Container(
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(
                                          color: _parseColor(waitingScreen.color),
                                          borderRadius: BorderRadius.circular(4.r),
                                          border: Border.all(color: AppColors.divider(isDark)),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        waitingScreen.color,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textPrimary(isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'الصورة: ${waitingScreen.imageUrl.isNotEmpty ? "مضافة" : "غير مضافة"}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: AppTextStyles.tajawal,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                ],
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
}