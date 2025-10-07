// lib/views/AboutUsViewDeskTop.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/AboutUsController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../AdminSidebarDeskTop.dart';

class AboutUsViewDeskTop extends StatefulWidget {
  const AboutUsViewDeskTop({Key? key}) : super(key: key);

  @override
  _AboutUsViewDeskTopState createState() => _AboutUsViewDeskTopState();
}

class _AboutUsViewDeskTopState extends State<AboutUsViewDeskTop> {
  final AboutUsController aboutUsController = Get.put(AboutUsController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController(); // جديد
  final TextEditingController _contactEmailController = TextEditingController();  // جديد

  @override
  void initState() {
    super.initState();
    // عند تحميل البيانات، نملأ الحقول
    ever(aboutUsController.aboutUs, (aboutUs) {
      if (aboutUs != null) {
        _titleController.text = aboutUs.title;
        _descriptionController.text = aboutUs.description;
        _facebookController.text = aboutUs.facebook ?? '';
        _twitterController.text = aboutUs.twitter ?? '';
        _instagramController.text = aboutUs.instagram ?? '';
        _youtubeController.text = aboutUs.youtube ?? '';
        _whatsappController.text = aboutUs.whatsapp ?? '';
        _contactNumberController.text = aboutUs.contactNumber ?? ''; // جديد
        _contactEmailController.text = aboutUs.contactEmail ?? '';   // جديد
      }
    });
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _facebookController.clear();
    _twitterController.clear();
    _instagramController.clear();
    _youtubeController.clear();
    _whatsappController.clear();
    _contactNumberController.clear(); // جديد
    _contactEmailController.clear();  // جديد
  }

  void _showEditDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDarkMode),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 800.w,
              minWidth: 600.w,
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(
                          aboutUsController.aboutUs.value == null ? Icons.add : Icons.edit,
                          size: 24.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          aboutUsController.aboutUs.value == null ? 'إضافة محتوى من نحن' : 'تعديل محتوى من نحن',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _buildTextField(
                      controller: _titleController,
                      label: 'العنوان',
                      icon: Icons.title,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'الوصف',
                      icon: Icons.description,
                      isDarkMode: isDarkMode,
                      maxLines: 10,
                    ),
                    SizedBox(height: 16.h),
                    // جديد: حقلي الاتصال
                    _buildTextField(
                      controller: _contactNumberController,
                      label: 'رقم الاتصال',
                      icon: Icons.phone,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _contactEmailController,
                      label: 'البريد الإلكتروني',
                      icon: Icons.email,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'روابط التواصل الاجتماعي',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildSocialField(
                      controller: _facebookController,
                      label: 'فيسبوك',
                      icon: Icons.facebook,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 10.h),
                    _buildSocialField(
                      controller: _twitterController,
                      label: 'تويتر',
                      icon: Icons.circle,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 10.h),
                    _buildSocialField(
                      controller: _instagramController,
                      label: 'إنستغرام',
                      icon: Icons.camera_alt,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 10.h),
                    _buildSocialField(
                      controller: _youtubeController,
                      label: 'يوتيوب',
                      icon: Icons.play_circle_fill,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 10.h),
                    _buildSocialField(
                      controller: _whatsappController,
                      label: 'واتساب',
                      icon: Icons.chat,
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDarkMode),
                            ),
                          ),
                        ),
                        Obx(() {
                          if (aboutUsController.isLoading.value) {
                            return CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3.r,
                            );
                          }
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 28.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              if (_titleController.text.isEmpty) {
                                Get.snackbar(
                                  'تحذير',
                                  'يرجى إدخال العنوان',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white
                                );
                                return;
                              }

                              if (_descriptionController.text.isEmpty) {
                                Get.snackbar(
                                  'تحذير',
                                  'يرجى إدخال الوصف',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white
                                );
                                return;
                              }

                              bool success;
                              if (aboutUsController.aboutUs.value == null) {
                                success = await aboutUsController.createAboutUs(
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  facebook: _facebookController.text.isNotEmpty ? _facebookController.text : null,
                                  twitter: _twitterController.text.isNotEmpty ? _twitterController.text : null,
                                  instagram: _instagramController.text.isNotEmpty ? _instagramController.text : null,
                                  youtube: _youtubeController.text.isNotEmpty ? _youtubeController.text : null,
                                  whatsapp: _whatsappController.text.isNotEmpty ? _whatsappController.text : null,
                                  contactNumber: _contactNumberController.text.isNotEmpty ? _contactNumberController.text : null, // جديد
                                  contactEmail: _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,    // جديد
                                );
                              } else {
                                success = await aboutUsController.updateAboutUs(
                                  id: aboutUsController.aboutUs.value!.id,
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  facebook: _facebookController.text.isNotEmpty ? _facebookController.text : null,
                                  twitter: _twitterController.text.isNotEmpty ? _twitterController.text : null,
                                  instagram: _instagramController.text.isNotEmpty ? _instagramController.text : null,
                                  youtube: _youtubeController.text.isNotEmpty ? _youtubeController.text : null,
                                  whatsapp: _whatsappController.text.isNotEmpty ? _whatsappController.text : null,
                                  contactNumber: _contactNumberController.text.isNotEmpty ? _contactNumberController.text : null, // جديد
                                  contactEmail: _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,    // جديد
                                );
                              }

                              if (success) {
                                Get.back();
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(aboutUsController.aboutUs.value == null ? Icons.add : Icons.edit, size: 20.r),
                                SizedBox(width: 8.w),
                                Text(
                                  aboutUsController.aboutUs.value == null ? 'إضافة' : 'تحديث',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 16.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDarkMode),
      ),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
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
        prefixIcon: Icon(icon, size: 22.r),
      ),
    );
  }

  Widget _buildSocialField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 16.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDarkMode),
      ),
      decoration: InputDecoration(
        labelText: label,
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
        prefixIcon: Icon(icon, size: 22.r),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required String? url,
    required bool isDarkMode,
  }) {
    return Card(
      color: AppColors.card(isDarkMode),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.r, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textPrimary(isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // جديد: دالة لعرض معلومات الاتصال
  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    required String? value,
    required bool isDarkMode,
  }) {
    if (value == null || value.isEmpty) return SizedBox();
    
    return Card(
      color: AppColors.card(isDarkMode),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.r, color: AppColors.primary),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDarkMode),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDarkMode),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                        'إدارة محتوى من نحن',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.edit, size: 18.r),
                        label: Text(
                          aboutUsController.aboutUs.value == null ? 'إضافة محتوى' : 'تعديل المحتوى',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 20.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          _showEditDialog();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: Obx(() {
                      if (aboutUsController.isLoading.value && aboutUsController.aboutUs.value == null) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final aboutUs = aboutUsController.aboutUs.value;
                      if (aboutUs == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 64.r, color: AppColors.textSecondary(isDarkMode)),
                              SizedBox(height: 16.h),
                              Text(
                                'لا يوجد محتوى',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDarkMode),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'انقر على زر "إضافة محتوى" لبدء الإضافة',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: [
                            Card(
                              color: AppColors.card(isDarkMode),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(24.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      aboutUs.title,
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary(isDarkMode),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      aboutUs.description,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.textPrimary(isDarkMode),
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // جديد: عرض معلومات الاتصال
                            if (aboutUs.contactNumber != null || aboutUs.contactEmail != null) ...[
                              Text(
                                'معلومات الاتصال',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary(isDarkMode),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Wrap(
                                spacing: 12.w,
                                runSpacing: 12.h,
                                children: [
                                  if (aboutUs.contactNumber != null)
                                    _buildContactInfo(
                                      icon: Icons.phone,
                                      label: 'رقم الاتصال',
                                      value: aboutUs.contactNumber,
                                      isDarkMode: isDarkMode,
                                    ),
                                  if (aboutUs.contactEmail != null)
                                    _buildContactInfo(
                                      icon: Icons.email,
                                      label: 'البريد الإلكتروني',
                                      value: aboutUs.contactEmail,
                                      isDarkMode: isDarkMode,
                                    ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                            ],
                            Text(
                              'وسائل التواصل الاجتماعي',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontFamily: AppTextStyles.tajawal,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(isDarkMode),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: [
                                if (aboutUs.facebook != null)
                                  _buildSocialButton(
                                    icon: Icons.facebook,
                                    label: 'فيسبوك',
                                    url: aboutUs.facebook!,
                                    isDarkMode: isDarkMode,
                                  ),
                                if (aboutUs.twitter != null)
                                  _buildSocialButton(
                                    icon: Icons.circle,
                                    label: 'تويتر',
                                    url: aboutUs.twitter!,
                                    isDarkMode: isDarkMode,
                                  ),
                                if (aboutUs.instagram != null)
                                  _buildSocialButton(
                                    icon: Icons.camera_alt,
                                    label: 'إنستغرام',
                                    url: aboutUs.instagram!,
                                    isDarkMode: isDarkMode,
                                  ),
                                if (aboutUs.youtube != null)
                                  _buildSocialButton(
                                    icon: Icons.play_circle_fill,
                                    label: 'يوتيوب',
                                    url: aboutUs.youtube!,
                                    isDarkMode: isDarkMode,
                                  ),
                                if (aboutUs.whatsapp != null)
                                  _buildSocialButton(
                                    icon: Icons.chat,
                                    label: 'واتساب',
                                    url: aboutUs.whatsapp!,
                                    isDarkMode: isDarkMode,
                                  ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            if (aboutUsController.aboutUs.value != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 28.w,
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  onPressed: () {
                                    Get.dialog(
                                      AlertDialog(
                                        title: Text('تأكيد الحذف'),
                                        content: Text('هل أنت متأكد من حذف محتوى "من نحن"؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text('إلغاء'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.error,
                                            ),
                                            onPressed: () {
                                              aboutUsController.deleteAboutUs(
                                                id: aboutUsController.aboutUs.value!.id,
                                              );
                                              Get.back();
                                            },
                                            child: Text('حذف'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.delete, size: 20.r),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'حذف المحتوى',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                        ),
                                      ),
                                    ],
                                  ),
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