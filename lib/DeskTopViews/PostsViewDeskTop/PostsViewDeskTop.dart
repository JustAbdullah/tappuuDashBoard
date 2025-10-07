// lib/DeskTopViews/posts_view_desktop.dart
// Improved version: full-screen, professional editor UI, better RTL/Arabic support,
// extended toolbar (font-size, font-name, direction), preview, publish controls,
// better layout for desktop (two-column), sticky toolbar and responsive sizing.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/PostsController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../core/data/model/Post.dart';
import '../ImageUploadWidget.dart';
import 'package:html/parser.dart' show parse;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PostsViewDeskTop extends StatefulWidget {
  const PostsViewDeskTop({Key? key}) : super(key: key);

  @override
  _PostsViewDeskTopState createState() => _PostsViewDeskTopState();
}

class _PostsViewDeskTopState extends State<PostsViewDeskTop> {
  final PostsController controller = Get.put(PostsController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _excerptController = TextEditingController();
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editExcerptController = TextEditingController();

  String _statusFilter = 'الكل';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    controller.fetchPosts();
    controller.fetchCategories();
  }

  // ------------------- تفاصيل المنشور (Dialog) -------------------
  void _showPostDetailsDialog(Post post) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final publicUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/blog/${post.slug}';

    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000.w, minWidth: 700.w, maxHeight: 800.h),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تفاصيل المنشور',
                            style: TextStyle(fontSize: 22.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))),
                        IconButton(icon: Icon(Icons.close, size: 24.r), onPressed: () => Get.back()),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    _buildSectionTitle('المعلومات الأساسية'),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(12.r)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl,
                        children: [
                          _buildDetailRow('المعرف', post.id.toString(), isDark),
                          _buildDetailRow('العنوان', post.title, isDark),
                          _buildDetailRow('الرابط (Slug)', post.slug, isDark),
                          _buildDetailRow('التصنيف', post.category?.name ?? 'بدون تصنيف', isDark),
                          _buildDetailRow('الحالة', _getStatusText(post.status), isDark, valueColor: _getStatusColor(post.status)),
                          _buildDetailRow('تاريخ الإنشاء', _formatDateFull(post.createdAt), isDark),
                          _buildDetailRow('تاريخ التحديث', _formatDateFull(post.updatedAt), isDark),
                          _buildDetailRow('تاريخ النشر', _formatDateFull(post.publishedAt), isDark),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    if (post.featuredImage != null && post.featuredImage!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl,
                        children: [
                          _buildSectionTitle('الصورة الرئيسية'),
                          SizedBox(height: 12.h),
                          Center(
                            child: Container(
                              width: 350.w, height: 250.h,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))
                              ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: CachedNetworkImage(
                                  imageUrl: post.featuredImage!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Center(child: CircularProgressIndicator(color: AppColors.primary)),
                                  errorWidget: (_, __, ___) => Icon(Icons.error, size: 40.r, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Center(
                            child: Text(post.featuredImage!,
                                style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)),
                                textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),

                    // TOC (إن وجد)
                    if (post.toc != null && post.toc!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl,
                        children: [
                          _buildSectionTitle('جدول المحتويات'),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(12.r)),
                            child: Column(
                              children: post.toc!.map((t) {
                                // t.tag, t.text, t.id
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(t.text ?? '', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                                  leading: Text(t.tag?.toUpperCase() ?? '', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(isDark))),
                                  onTap: () async {
                                    final anchorUrl = '$publicUrl#${t.id}';
                                    if (await canLaunch(anchorUrl)) {
                                      await launch(anchorUrl);
                                    } else {
                                      // fallback: افتح الصفحة الأساسية
                                      if (await canLaunch(publicUrl)) await launch(publicUrl);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),

                    if (post.excerpt != null && post.excerpt!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl,
                        children: [
                          _buildSectionTitle('ملخص المنشور'),
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity, padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(12.r)),
                            child: Text(post.excerpt!, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),

                    // محتوى المنشور (نعرض HTML بشكل جيد بواسطة flutter_html)
                    if (post.content != null && post.content!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl,
                        children: [
                          _buildSectionTitle('محتوى المنشور'),
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity, padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(12.r)),
                            child: Html(
                              data: post.content!,
                              // يمكنك ضبط عناصر render/customRender لو احتجت
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),

                    // بيانات SEO
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl,
                      children: [
                        _buildSectionTitle('إعدادات SEO'),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity, padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(12.r)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl, children: [
                            if (post.metaTitle != null && post.metaTitle!.isNotEmpty)
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('عنوان Meta:', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))),
                                SizedBox(height: 4.h),
                                Text(post.metaTitle!, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                                SizedBox(height: 16.h),
                              ]),
                            if (post.metaDescription != null && post.metaDescription!.isNotEmpty)
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('وصف Meta:', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))),
                                SizedBox(height: 4.h),
                                Text(post.metaDescription!, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                              ]),
                            if ((post.metaTitle == null || post.metaTitle!.isEmpty) && (post.metaDescription == null || post.metaDescription!.isEmpty))
                              Text('لا توجد إعدادات SEO مخصصة', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                          ]),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // أزرار الإجراءات
                    Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.grey500, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        child: Text('إغلاق', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _showEditDialog(post);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        child: Text('تعديل المنشور', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- UI Helpers ----------------
  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(title, style: TextStyle(fontSize: 18.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)));
  }

  Widget _buildDetailRow(String label, String? value, bool isDark, {Color? valueColor}) {
    if (value == null || value.isEmpty) return SizedBox();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(textDirection: TextDirection.rtl, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 2, child: Text('$label:', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark)))),
        SizedBox(width: 16.w),
        Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: valueColor ?? AppColors.textSecondary(isDark)), textDirection: TextDirection.rtl)),
      ]),
    );
  }

  String _formatDateFull(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString);
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      final formattedTime = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      return '$formattedDate - $formattedTime';
    } catch (e) {
      return dateString;
    }
  }

  String _parseHtmlString(String htmlString) {
    try {
      final document = parse(htmlString);
      return document.body?.text ?? htmlString;
    } catch (e) {
      return htmlString;
    }
  }

  Widget _buildInfoChip(String text, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: color, fontWeight: FontWeight.w500)),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'published':
        return 'منشور';
      case 'draft':
        return 'مسودة';
      case 'archived':
        return 'مؤرشف';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'archived':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // ---------------- Add / Edit Dialogs (improved editor UI) ----------------
  void _showAddDialog() {
    controller.resetForm(); // إعادة تعيين النموذج بما في ذلك التصنيف
    _titleController.clear();
    _excerptController.clear();
    _openEditorDialog(isEdit: false);
  }

  void _showEditDialog(Post post) {
    controller.populateFormFromPost(post); // تعبئة النموذج بالبيانات بما في ذلك التصنيف
    _editTitleController.text = post.title;
    _editExcerptController.text = post.excerpt ?? '';
    _openEditorDialog(isEdit: true, editingPost: post);
  }

  // Centralized editor dialog used for both add and edit; full-screen, two-column layout
  void _openEditorDialog({required bool isEdit, Post? editingPost}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final HtmlEditorController htmlController = HtmlEditorController();

    // local controllers (separate from class-level to avoid conflicts between add/edit)
    final TextEditingController titleCtl = TextEditingController(text: isEdit ? (editingPost?.title ?? '') : _titleController.text);
    final TextEditingController excerptCtl = TextEditingController(text: isEdit ? (editingPost?.excerpt ?? '') : _excerptController.text);
    
    // Controllers for SEO fields
    final TextEditingController slugCtl = TextEditingController(text: editingPost?.slug ?? '');
    final TextEditingController metaTitleCtl = TextEditingController(text: editingPost?.metaTitle ?? '');
    final TextEditingController metaDescriptionCtl = TextEditingController(text: editingPost?.metaDescription ?? '');

    // تعيين المحتوى الأولي للمحرر
    if (isEdit && editingPost != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        htmlController.setText(editingPost.content ?? '');
      });
    }

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: Row(
                children: [
                  // Sidebar metadata column
                  Container(
                    width: 420.w,
                    height: MediaQuery.of(context).size.height,
                    color: AppColors.surface(isDark),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Row(children: [  
                            IconButton(icon: Icon(Icons.close), onPressed: () => Get.back()), 
                            Spacer(),
                            Icon(isEdit ? Icons.edit : Icons.post_add, color: AppColors.primary, size: 22.r),
                            SizedBox(width: 8.w),
                            Text(isEdit ? 'تعديل المنشور' : 'إضافة منشور جديد', style: TextStyle(fontSize: 18.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))),
                          ]),
                          SizedBox(height: 16.h),

                          TextField(
                            controller: titleCtl,
                            textDirection: TextDirection.rtl,
                            decoration: InputDecoration(labelText: 'عنوان المنشور', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), filled: true, fillColor: AppColors.card(isDark)),
                            style: TextStyle(fontFamily: AppTextStyles.tajawal),
                          ),
                          SizedBox(height: 12.h),

                          TextField(
                            controller: excerptCtl,
                            textDirection: TextDirection.rtl,
                            maxLines: 3,
                            decoration: InputDecoration(labelText: 'ملخص المنشور', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), filled: true, fillColor: AppColors.card(isDark)),
                            style: TextStyle(fontFamily: AppTextStyles.tajawal),
                          ),

                          SizedBox(height: 12.h),

                          // تصنيف المنشور - النسخة المصححة
                          Obx(() {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text('تصنيف المنشور', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                                SizedBox(height: 8.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.card(isDark),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: AppColors.divider(isDark)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int?>(
                                      value: controller.formCategoryId.value == 0 ? null : controller.formCategoryId.value,
                                      isExpanded: true,
                                      hint: Text('اختر تصنيف', style: TextStyle(fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                                      items: [
                                        DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text('بدون تصنيف', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                                        ),
                                        ...controller.items.map((category) {
                                          return DropdownMenuItem<int?>(
                                            value: category.id,
                                            child: Text(category.name, style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                                          );
                                        }).toList(),
                                      ],
                                      onChanged: (int? newValue) {
                                        controller.setFormCategoryId(newValue);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),

                          SizedBox(height: 12.h),

                          Text('صورة المنشور', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                          SizedBox(height: 8.h),
                          Obx(() => ImageUploadWidget(imageBytes: controller.imageBytes.value, onPickImage: controller.pickImage, onRemoveImage: controller.removeImage)),

                          SizedBox(height: 12.h),

                          _buildSectionTitle('إعدادات SEO'),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: slugCtl,
                            textDirection: TextDirection.rtl, 
                            decoration: InputDecoration(
                              labelText: 'رابط (Slug)', 
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), 
                              filled: true, 
                              fillColor: AppColors.card(isDark)
                            ), 
                            style: TextStyle(fontFamily: AppTextStyles.tajawal)
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: metaTitleCtl,
                            textDirection: TextDirection.rtl, 
                            decoration: InputDecoration(
                              labelText: 'Meta Title', 
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), 
                              filled: true, 
                              fillColor: AppColors.card(isDark)
                            ), 
                            style: TextStyle(fontFamily: AppTextStyles.tajawal)
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: metaDescriptionCtl,
                            textDirection: TextDirection.rtl, 
                            maxLines: 3, 
                            decoration: InputDecoration(
                              labelText: 'Meta Description', 
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)), 
                              filled: true, 
                              fillColor: AppColors.card(isDark)
                            ), 
                            style: TextStyle(fontFamily: AppTextStyles.tajawal)
                          ),

                          SizedBox(height: 22.h),

                          // Save buttons
                          Obx(() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.public),
                              label: Text(isEdit ? 'تطبيق ونشر' : 'نشر الآن', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                              onPressed: controller.isSaving.value
                                ? null
                                : () async {
                                    try {
                                      print('BTN: One - show loading dialog');
                                      // افتح dialog تحميل (إذا ليس مفتوح)
                                      if (!(Get.isDialogOpen ?? false)) {
                                        Get.dialog(Center(child: CircularProgressIndicator()), barrierDismissible: false);
                                      }

                                      print('BTN: Two - getting html from editor (with timeout)');
                                      String html = '';
                                      try {
                                        // انتظر نص المحرر بمهلة 10 ثواني لتجنّب التعليق
                                        html = await htmlController.getText().timeout(Duration(seconds: 10));
                                      } on TimeoutException catch (te) {
                                        print('BTN: getText timed out: $te');
                                        // محاولة ثانية بدون انتظار طويل (أو اعتبره نص فارغ)
                                        try {
                                          html = await htmlController.getText();
                                        } catch (e) {
                                          print('BTN: second getText failed: $e');
                                          html = ''; // fallback
                                        }
                                      } catch (e) {
                                        print('BTN: getText threw: $e');
                                        html = '';
                                      }

                                      print('BTN: Three - html length = ${html?.length ?? 0}');
                                      final title = titleCtl.text.trim();
                                      final excerpt = excerptCtl.text.trim();

                                      if (title.isEmpty) {
                                        // أغلق dialog التحميل بأمان ثم أعلم المستخدم
                                        if (Get.isDialogOpen ?? false) Get.back();
                                        Get.snackbar('تحذير', 'الرجاء إدخال عنوان المنشور', backgroundColor: Colors.orange, colorText: Colors.white);
                                        return;
                                      }

                                      final normalized = _ensureRtlWrapper(html ?? '');
                                      controller.formTitle.value = title;
                                      controller.formExcerpt.value = excerpt;
                                      controller.formContentHtml.value = normalized;
                                      controller.formStatus.value = 'published';
                                      
                                      // استخدام القيم من المتحكمات الجديدة بدلاً من القيم القديمة
                                      controller.formSlug.value = slugCtl.text.trim();
                                      controller.formMetaTitle.value = metaTitleCtl.text.trim();
                                      controller.formMetaDescription.value = metaDescriptionCtl.text.trim();
                                      // التصنيف يتم تعيينه تلقائياً عبر الـ Obx

                                      print('BTN: Four - calling controller method (awaiting result)');
                                      bool success = false;
                                      if (isEdit) {
                                        success = await controller.updatePost(editingPost!.id); // **هنا ننتظر**
                                      } else {
                                        success = await controller.createPost(); // **هنا ننتظر**
                                      }
                                      print('BTN: Five - controller returned success = $success');

                                      // أغلِق dialog التحميل إن كان مفتوح
                                      if (Get.isDialogOpen ?? false) {
                                        Get.back();
                                      }

                                      if (success) {
                                        // استخدام الدالة المركزية للخروج الآمن
                                        handleSuccessAndExit();
                                      } else {
                                        // خطأ: أظهِر رسالة لو لم تُظهر داخل controller
                                        Get.snackbar('خطأ', 'فشل في إتمام العملية', backgroundColor: Colors.red, colorText: Colors.white);
                                      }
                                    } catch (e, st) {
                                      print('BTN: Caught error: $e\n$st');
                                      if (Get.isDialogOpen ?? false) Get.back();
                                      Get.snackbar('خطأ', 'حدث خطأ غير متوقع: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
                                    }
                                  },
                            )
                          ])),

                          SizedBox(height: 24.h),

                          // small hint
                          Text('ملاحظة:قم بسحب شريط الأدوات في الإتجاه الأيسر لمشاهدة بقية الأدوات', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(isDark), fontFamily: AppTextStyles.tajawal)),

                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),

                  // Editor column (takes rest of screen) -- keep toolbar sticky at top
                  Expanded(
                    child: Container(
                      color: AppColors.background(isDark),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        children: [
                          // Top toolbar row with preview and fullscreen toggle
                          Row(
                            children: [
                              Text('محرّر المحتوى', style: TextStyle(fontSize: 16.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark))),
                              Spacer(),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final html = await htmlController.getText();
                                  _showPreviewDialog(html ?? '', isDark);
                                },
                                icon: Icon(Icons.visibility),
                                label: Text('معاينة', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // The editor itself: full height
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(12.r)),
                              padding: EdgeInsets.all(12.r),
                              child: HtmlEditor(
                                controller: htmlController,
                                htmlEditorOptions: HtmlEditorOptions(
                                  hint: 'اكتب محتوى المنشور هنا...',
                                  shouldEnsureVisible: true,
                                  // initialText - if editing, set initial content wrapped with RTL wrapper so the editor shows right alignment
                                  initialText: isEdit ? (editingPost?.content ?? '') : null,
                                  darkMode: isDark,
                                ),
                                htmlToolbarOptions: HtmlToolbarOptions(
                                  toolbarPosition: ToolbarPosition.aboveEditor,
                                  toolbarType: ToolbarType.nativeScrollable,
                                  defaultToolbarButtons: [
                                    StyleButtons(),
                                    FontSettingButtons(fontName: true, fontSize: true, fontSizeUnit: true),
                                    FontButtons(clearAll: false),
                                    ListButtons(listStyles: true),
                                    ParagraphButtons(textDirection: true, lineHeight: true, caseConverter: true),
                                    InsertButtons(video: true, audio: false, table: true, picture: true, link: true, otherFile: false, hr: true),
                                    ColorButtons(highlightColor: true),
                                  ],
                                  renderSeparatorWidget: true,
                                ),
                                otherOptions: OtherOptions(
                                  height: double.maxFinite,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Function to handle successful operation and exit
  void handleSuccessAndExit() {
    // Close any loading dialogs first
    if (Get.isDialogOpen ?? false) {
      Get.back(); // Close loading dialog
    }
    
    // Close the main editor dialog
    if (Get.isDialogOpen ?? false) {
      Get.back(); // Close editor dialog
    }
    
    // Update the posts list
    controller.fetchPosts();
    
    // Show success message
    Get.snackbar('نجاح', 'تمت العملية بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
  }

  // Preview dialog (renders HTML using flutter_html)
  void _showPreviewDialog(String html, bool isDark) {
    final normalized = _ensureRtlWrapper(html);
    Get.dialog(Dialog(
      backgroundColor: AppColors.surface(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1000.w, maxHeight: 800.h),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text('معاينة المحتوى', style: TextStyle(fontSize: 18.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold, color: AppColors.textPrimary(isDark))), Spacer(), IconButton(icon: Icon(Icons.close), onPressed: () => Get.back())]),
            SizedBox(height: 12.h),
            Expanded(child: SingleChildScrollView(child: Html(data: normalized))),
            SizedBox(height: 12.h),
            Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: () => Get.back(), child: Text('إغلاق'))),
          ]),
        ),
      ),
    ));
  }

  // Ensure saved HTML has RTL wrapper (so Arabic content types and alignment are preserved when displayed)
  String _ensureRtlWrapper(String html) {
    if (html.trim().isEmpty) return '';
    final lc = html.toLowerCase();
    if (lc.contains('dir="rtl"') || lc.contains('dir=\'rtl\'')) return html;
    // wrap with a simple div that sets dir and alignment
    return '<div dir="rtl" style="text-align: right;">$html</div>';
  }

  // ---------------- SEO Dialog ----------------
  void _showSeoDialog(Post post) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.textPrimary(isDark);
    final bgColor = AppColors.card(isDark);
    final accentColor = AppColors.primary;

    // متحكمات النصوص
    TextEditingController slugController = TextEditingController(text: post.slug ?? '');
    TextEditingController metaTitleController = TextEditingController(text: post.metaTitle ?? '');
    TextEditingController metaDescriptionController = TextEditingController(text: post.metaDescription ?? '');

    Get.dialog(
      Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تحسين محركات البحث (SEO)',
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
              SizedBox(height: 20.h),
              _buildSeoField('Slug (رابط المنشور)', slugController, Icons.link),
              SizedBox(height: 16.h),
              _buildSeoField('Meta Title', metaTitleController, Icons.title),
              SizedBox(height: 16.h),
              _buildSeoField('Meta Description', metaDescriptionController, Icons.description, maxLines: 3),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('إلغاء', style: TextStyle(fontSize: 14.sp)),
                  ),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                await controller.updatePostSeo(
                                  post.id,
                                  slug: slugController.text.trim().isNotEmpty ? slugController.text.trim() : null,
                                  metaTitle: metaTitleController.text.trim().isNotEmpty ? metaTitleController.text.trim() : null,
                                  metaDescription: metaDescriptionController.text.trim().isNotEmpty ? metaDescriptionController.text.trim() : null,
                                );
                                Get.back();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: controller.isSaving.value ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)) : Text('حفظ', style: TextStyle(fontSize: 14.sp)),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeoField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.textPrimary(isDark);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      style: TextStyle(fontSize: 14.sp, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14.sp, color: textColor),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.divider(isDark))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.divider(isDark))),
      ),
    );
  }

  // ---------------- باقي الشاشة — الجدول، البحث، الفلاتر ----------------
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
              Text('إدارة المنشورات', style: TextStyle(fontSize:19.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark))),
              ElevatedButton.icon(
                icon: Icon(Icons.add, size:18.r),
                label: Text('إضافة منشور', style: TextStyle(fontSize:14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: EdgeInsets.symmetric(vertical:12.h, horizontal:20.w), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                onPressed: _showAddDialog,
              ),
            ]),
            SizedBox(height:16.h),
            Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.end, children: [
              _buildFilterButton('الكل', _statusFilter == 'الكل'),
              SizedBox(width:10.w),
              _buildFilterButton('منشور', _statusFilter == 'published'),
              SizedBox(width:10.w),
              _buildFilterButton('مسودة', _statusFilter == 'draft'),
              SizedBox(width:10.w),
              _buildFilterButton('أرشيف', _statusFilter == 'archived'),
            ]),
            SizedBox(height:16.h),
            Center(child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth:600.w, minWidth:400.w),
              child: Container(
                height:56.h,
                padding: EdgeInsets.symmetric(horizontal:16.w),
                decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius:12, offset: Offset(0,4))]),
                child: Row(textDirection: TextDirection.rtl, children: [
                  Expanded(child: TextField(textDirection: TextDirection.rtl, controller: _searchController, onChanged: (value) { setState(() { _searchQuery = value; }); }, style: TextStyle(fontSize:14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark)), decoration: InputDecoration(hintText: 'ابحث عن منشور...', hintStyle: TextStyle(fontSize:14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)), prefixIcon: Icon(Icons.search, size:22.r), border: InputBorder.none, isDense: true))),
                  SizedBox(width:12.w),
                ]),
              ),
            )),
            SizedBox(height:24.h),
            Expanded(child: Container(
              decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius:12, offset: Offset(0,4))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: Container(padding: EdgeInsets.symmetric(vertical:16.h, horizontal:16.w), decoration: BoxDecoration(color: isDark ? AppColors.grey800 : AppColors.grey200), child: Row(textDirection: TextDirection.rtl, children: [
                    _buildHeaderCell("المعرف", 1),
                    _buildHeaderCell("الصورة", 1),
                    _buildHeaderCell("العنوان", 2),
                    _buildHeaderCell("التصنيف", 1),
                    _buildHeaderCell("الحالة", 1),
                    _buildHeaderCell("تاريخ النشر", 1),
                    _buildHeaderCell("تاريخ الإنشاء", 1),
                    _buildHeaderCell("إعدادات SEO", 1),
                    _buildHeaderCell("الإجراءات", 1),
                  ]))),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth:3.r)));
                    }
                    if (controller.postsList.isEmpty) {
                      return SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.article_outlined, size:64.r, color: AppColors.textSecondary(isDark)), SizedBox(height:16.h), Text('لا توجد منشورات', style: TextStyle(fontSize:16.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)))])));
                    }
                    return SliverList(delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPostRow(controller.postsList[index], index, isDark, index % 2 == 0 ? rowColor1 : rowColor2),
                      childCount: controller.postsList.length,
                    ));
                  }),
                ]),
              ),
            )),
          ]),
        )),
      ]),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _statusFilter = isSelected ? 'الكل' : text;
        });
      },
      style: OutlinedButton.styleFrom(foregroundColor: isSelected ? Colors.white : AppColors.primary, backgroundColor: isSelected ? AppColors.primary : Colors.transparent, side: BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)), padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)),
      child: Text(text, style: TextStyle(fontSize:12.sp, fontFamily: AppTextStyles.tajawal)),
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(flex: flex, child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize:13.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark))));
  }

  Widget _buildPostRow(Post post, int index, bool isDark, Color color) {
    final createdAt = _parseDate(post.createdAt) ?? DateTime.now().subtract(Duration(days: 1));
    final publishedAt = _parseDate(post.publishedAt);
    final dateText = _formatDaysAgo(createdAt);
    final publishedText = publishedAt != null ? _formatDaysAgo(publishedAt) : 'لم ينشر بعد';

    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w), color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(post.id.toString(), 1),
        Expanded(flex:1, child: Center(child: Container(width:45.w, height:45.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8.r)), child: ClipRRect(borderRadius: BorderRadius.circular(8.r), child: post.featuredImage != null && post.featuredImage!.isNotEmpty ? CachedNetworkImage(imageUrl: post.featuredImage!, fit: BoxFit.cover, placeholder: (context, url) => Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.r)), errorWidget: (context, url, error) => Icon(Icons.image, size: 24.r, color: Colors.grey)) : Icon(Icons.image, size: 24.r, color: Colors.grey))))),
        _buildCell(post.title, 2, fontWeight: FontWeight.w500, maxLines: 2),
        _buildCell(post.category?.name ?? 'بدون تصنيف', 1),
        _buildStatusCell(post.status, 1),
        _buildCell(publishedText, 1, color: AppColors.textSecondary(isDark)),
        _buildCell(dateText, 1, color: AppColors.textSecondary(isDark)),

        // عمود SEO
        Expanded(
          flex: 1,
          child: Center(
            child: IconButton(
              icon: Icon(Icons.search, size:18.r, color: Colors.blue),
              onPressed: () => _showSeoDialog(post),
              tooltip: 'إعدادات SEO',
            ),
          ),
        ),

        Expanded(flex:1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: Icon(Icons.visibility, size: 18.r, color: Colors.blue), onPressed: () => _showPostDetailsDialog(post)),
          SizedBox(width: 4.w),
          IconButton(icon: Icon(Icons.edit, size: 18.r, color: AppColors.primary), onPressed: () => _showEditDialog(post)),
          SizedBox(width: 4.w),
          IconButton(icon: Icon(Icons.delete, size: 18.r, color: AppColors.error), onPressed: () => _showDeleteDialog(post.id)),
          SizedBox(width: 4.w),
          GestureDetector(onTapDown: (TapDownDetails details) { _showStatusMenu(context, details.globalPosition, post); }, child: _getStatusIcon(post.status)),
        ])),
      ]),
    );
  }

  Widget _buildCell(String text, int flex, {Color? color, FontWeight fontWeight = FontWeight.normal, int maxLines = 1}) {
    return Expanded(flex: flex, child: Text(text, textAlign: TextAlign.center, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize:12.sp, fontFamily: AppTextStyles.tajawal, fontWeight: fontWeight, color: color)));
  }

  Widget _buildStatusCell(String status, int flex) {
    Color statusColor;
    String statusText;
    switch (status) {
      case 'published': statusColor = Colors.green; statusText = 'منشور'; break;
      case 'draft': statusColor = Colors.orange; statusText = 'مسودة'; break;
      case 'archived': statusColor = Colors.grey; statusText = 'أرشيف'; break;
      default: statusColor = Colors.grey; statusText = status;
    }
    return Expanded(flex: flex, child: Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: statusColor.withOpacity(0.3))), child: Text(statusText, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, fontFamily: AppTextStyles.tajawal, color: statusColor, fontWeight: FontWeight.w600))));
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'published': return Icon(Icons.public, size: 18.r, color: Colors.green);
      case 'draft': return Icon(Icons.edit, size: 18.r, color: Colors.orange);
      case 'archived': return Icon(Icons.archive, size: 18.r, color: Colors.grey);
      default: return Icon(Icons.circle, size: 18.r, color: Colors.grey);
    }
  }

  void _showDeleteDialog(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(Center(child: Dialog(backgroundColor: AppColors.surface(isDark), insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)), child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 500.w, minWidth: 300.w, maxHeight: 300.h), child: Padding(padding: EdgeInsets.all(20.r), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(textDirection: TextDirection.rtl, children: [Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error), SizedBox(width:10.w), Text('تأكيد الحذف', style: TextStyle(fontSize:15.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.error))]),
      SizedBox(height:16.h),
      Text('هل أنت متأكد من حذف هذا المنشور؟', style: TextStyle(fontSize:13.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
      Text('سيتم حذف جميع البيانات المرتبطة به!', style: TextStyle(fontSize:12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.error.withOpacity(0.8))),
      SizedBox(height:24.h),
      Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: TextStyle(fontSize:13.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)))),
        Obx(() => ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))), onPressed: controller.isDeleting.value ? null : () { controller.deletePost(id); Get.back(); }, child: controller.isDeleting.value ? CircularProgressIndicator(color: Colors.white, strokeWidth:2.r) : Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.delete, size:20.r), SizedBox(width:8.w), Text('حذف', style: TextStyle(fontSize:13.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold))]))) ]), ]))))));
  }

  void _showStatusMenu(BuildContext context, Offset tapPosition, Post post) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(Rect.fromPoints(tapPosition, tapPosition), Offset.zero & overlay.size);
    showMenu<String>(context: context, position: position, items: [
      PopupMenuItem(value: 'draft', child: Row(textDirection: TextDirection.rtl, children: [Icon(Icons.edit, size: 18.r, color: Colors.orange), SizedBox(width: 8.w), Text('مسودة', style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal))])),
      PopupMenuItem(value: 'published', child: Row(textDirection: TextDirection.rtl, children: [Icon(Icons.public, size: 18.r, color: Colors.green), SizedBox(width: 8.w), Text('منشور', style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal))])),
      PopupMenuItem(value: 'archived', child: Row(textDirection: TextDirection.rtl, children: [Icon(Icons.archive, size: 18.r, color: Colors.grey), SizedBox(width: 8.w), Text('أرشفة', style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal))])),
    ]).then((value) { if (value != null) controller.togglePublish(post.id); });
  }
}

// ---------------- Helper functions منفصلة ----------------
String _formatDaysAgo(DateTime date) {
  final now = DateTime.now();
  final days = now.difference(date).inDays;
  if (days == 0) return 'اليوم';
  if (days == 1) return 'أمس';
  return 'منذ $days يوم';
}

DateTime? _parseDate(String? dateString) {
  if (dateString == null) return null;
  try {
    return DateTime.parse(dateString);
  } catch (_) { return null; }
}