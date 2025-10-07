// lib/views/AboutUsViewMobile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/AboutUsController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../AdminSidebar.dart';

class AboutUsViewMobile extends StatefulWidget {
  const AboutUsViewMobile({Key? key}) : super(key: key);

  @override
  _AboutUsViewMobileState createState() => _AboutUsViewMobileState();
}

class _AboutUsViewMobileState extends State<AboutUsViewMobile> {
  final AboutUsController aboutUsController = Get.put(AboutUsController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    aboutUsController.fetchAboutUs();
  }

  void _showEditDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // تعبئة البيانات إذا كان هناك محتوى موجود
    if (aboutUsController.aboutUs.value != null) {
      final aboutUs = aboutUsController.aboutUs.value!;
      _titleController.text = aboutUs.title;
      _descriptionController.text = aboutUs.description;
      _facebookController.text = aboutUs.facebook ?? '';
      _twitterController.text = aboutUs.twitter ?? '';
      _instagramController.text = aboutUs.instagram ?? '';
      _youtubeController.text = aboutUs.youtube ?? '';
      _whatsappController.text = aboutUs.whatsapp ?? '';
      _contactNumberController.text = aboutUs.contactNumber ?? '';
      _contactEmailController.text = aboutUs.contactEmail ?? '';
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _facebookController.clear();
      _twitterController.clear();
      _instagramController.clear();
      _youtubeController.clear();
      _whatsappController.clear();
      _contactNumberController.clear();
      _contactEmailController.clear();
    }

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
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
                maxLines: 5,
              ),
              SizedBox(height: 16.h),
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
                        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
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
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (_descriptionController.text.isEmpty) {
                          Get.snackbar(
                            'تحذير',
                            'يرجى إدخال الوصف',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
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
                            contactNumber: _contactNumberController.text.isNotEmpty ? _contactNumberController.text : null,
                            contactEmail: _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,
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
                            contactNumber: _contactNumberController.text.isNotEmpty ? _contactNumberController.text : null,
                            contactEmail: _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,
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

  void _showDeleteDialog(int id) {
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
                'هل أنت متأكد من حذف محتوى "من نحن"؟',
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
                      aboutUsController.deleteAboutUs(id: id);
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
          onClose: () => Navigator.pop(context),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'إدارة محتوى من نحن',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, size: 22.r),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                    'انقر على زر الإضافة لبدء الإضافة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: _showEditDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    ),
                    child: Text(
                      'إضافة محتوى',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: AppTextStyles.tajawal,
                      ),
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
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aboutUs.title,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          aboutUs.description,
                          style: TextStyle(
                            fontSize: 14.sp,
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
                
                // معلومات الاتصال
                if (aboutUs.contactNumber != null || aboutUs.contactEmail != null) ...[
                  Text(
                    'معلومات الاتصال',
                    style: TextStyle(
                      fontSize: 18.sp,
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
                
                // وسائل التواصل الاجتماعي
                Text(
                  'وسائل التواصل الاجتماعي',
                  style: TextStyle(
                    fontSize: 18.sp,
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
                
                // زر الحذف
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    ),
                    onPressed: () {
                      _showDeleteDialog(aboutUs.id);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete, size: 20.r),
                        SizedBox(width: 8.w),
                        Text(
                          'حذف المحتوى',
                          style: TextStyle(
                            fontSize: 16.sp,
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
    );
  }
}