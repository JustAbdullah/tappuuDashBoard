// lib/DeskTopViews/post_categories_view_desktop.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/PostCategoryModel.dart';

import '../../controllers/PostCategoryController.dart';

class PostCategoriesViewDeskTop extends StatefulWidget {
  const PostCategoriesViewDeskTop({Key? key}) : super(key: key);

  @override
  _PostCategoriesViewDeskTopState createState() => _PostCategoriesViewDeskTopState();
}

class _PostCategoriesViewDeskTopState extends State<PostCategoriesViewDeskTop> {
  final PostCategoryController controller = Get.put(PostCategoryController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // متحكمات النماذج
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // للمراقبة أثناء البحث
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    controller.fetchCategories();
    
    // إضافة مستمع للبحث مع تأخير
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text;
      });
      controller.fetchCategories(q: _searchController.text.isNotEmpty ? _searchController.text : null);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ------------------- Dialog إضافة تصنيف -------------------
  void _showAddCategoryDialog() {
    _nameController.clear();
    _slugController.clear();
    _descriptionController.clear();
    
    _showCategoryDialog(isEdit: false);
  }

  // ------------------- Dialog تعديل تصنيف -------------------
  void _showEditCategoryDialog(PostCategoryModel category) {
    _nameController.text = category.name;
    _slugController.text = category.slug;
    _descriptionController.text = category.description ?? '';
    
    _showCategoryDialog(isEdit: true, editingCategory: category);
  }

  void _showCategoryDialog({required bool isEdit, PostCategoryModel? editingCategory}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w, minWidth: 500.w, maxHeight: 700.h),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الهيدر
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'تعديل التصنيف' : 'إضافة تصنيف جديد',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 24.r),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // حقل الاسم
                  TextField(
                    controller: _nameController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: 'اسم التصنيف *',
                      labelStyle: TextStyle(fontFamily: AppTextStyles.tajawal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      filled: true,
                      fillColor: AppColors.card(isDark),
                    ),
                    style: TextStyle(fontFamily: AppTextStyles.tajawal),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // حقل الرابط (Slug)
                  TextField(
                    controller: _slugController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: 'رابط التصنيف (Slug)',
                      labelStyle: TextStyle(fontFamily: AppTextStyles.tajawal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      filled: true,
                      fillColor: AppColors.card(isDark),
                      hintText: 'سيتم إنشاؤه تلقائياً إذا تركت فارغاً',
                    ),
                    style: TextStyle(fontFamily: AppTextStyles.tajawal),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // حقل الوصف
                  TextField(
                    controller: _descriptionController,
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'وصف التصنيف',
                      labelStyle: TextStyle(fontFamily: AppTextStyles.tajawal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      filled: true,
                      fillColor: AppColors.card(isDark),
                      alignLabelWithHint: true,
                    ),
                    style: TextStyle(fontFamily: AppTextStyles.tajawal),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // أزرار الحفظ والإلغاء
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // زر الإلغاء
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grey500,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // زر الحفظ
                      Obx(() => ElevatedButton(
                        onPressed: controller.isSaving.value ? null : () async {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) {
                            Get.snackbar(
                              'تحذير',
                              'الرجاء إدخال اسم التصنيف',
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          
                          bool success;
                          if (isEdit) {
                            success = await controller.updateCategory(
                              editingCategory!.id,
                              name: name,
                              slug: _slugController.text.trim().isNotEmpty ? _slugController.text.trim() : null,
                              description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
                            );
                          } else {
                            success = await controller.createCategory(
                              name: name,
                              slug: _slugController.text.trim().isNotEmpty ? _slugController.text.trim() : null,
                              description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
                            );
                          }
                          
                          if (success) {
                            Get.back();
                            controller.fetchCategories();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: controller.isSaving.value
                            ? SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.r,
                                ),
                              )
                            : Text(
                                isEdit ? 'تحديث' : 'إنشاء',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  // ------------------- تأكيد الحذف -------------------
  void _showDeleteDialog(int id, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w, minWidth: 400.w, maxHeight: 300.h),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  // الهيدر
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 24.r, color: AppColors.error),
                      SizedBox(width: 10.w),
                      Text(
                        'تأكيد الحذف',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // نص التأكيد
                  Text(
                    'هل أنت متأكد من حذف التصنيف "$name"؟',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  
                  Text(
                    'لا يمكن التراجع عن هذا الإجراء!',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.error.withOpacity(0.8),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // أزرار الإجراءات
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر الإلغاء
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                      
                      // زر الحذف
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () {
                          controller.deleteCategory(id);
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
        ),
      ),
    );
  }

  // ------------------- واجهة التفاصيل -------------------
  void _showDetailsDialog(PostCategoryModel category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w, minWidth: 500.w, maxHeight: 600.h),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الهيدر
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تفاصيل التصنيف',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 24.r),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // معلومات التصنيف
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        _buildDetailRow('المعرف', category.id.toString(), isDark),
                        _buildDetailRow('الاسم', category.name, isDark),
                        _buildDetailRow('الرابط', category.slug, isDark),
                        if (category.description != null && category.description!.isNotEmpty)
                          _buildDetailRow('الوصف', category.description!, isDark),
                        if (category.createdAt != null)
                          _buildDetailRow('تاريخ الإنشاء', _formatDate(category.createdAt!), isDark),
                        if (category.updatedAt != null)
                          _buildDetailRow('تاريخ التحديث', _formatDate(category.updatedAt!), isDark),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // أزرار الإجراءات
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grey500,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'إغلاق',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _showEditCategoryDialog(category);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'تعديل التصنيف',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  // ------------------- دوال مساعدة -------------------
  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      final formattedTime = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      return '$formattedDate - $formattedTime';
    } catch (e) {
      return dateString;
    }
  }

  // ------------------- بناء الواجهة الرئيسية -------------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor1 = isDark ? AppColors.grey900 : AppColors.grey50;
    final rowColor2 = isDark ? AppColors.grey800 : AppColors.grey100;

    return Scaffold(
      body: Row(
        children: [
          // الشريط الجانبي
          AdminSidebarDeskTop(),
          
          // المحتوى الرئيسي
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  // الهيدر الرئيسي
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إدارة تصنيفات المنشورات',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                      
                      // زر الإضافة
                      ElevatedButton.icon(
                        icon: Icon(Icons.add, size: 18.r),
                        label: Text(
                          'إضافة تصنيف',
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
                        onPressed: _showAddCategoryDialog,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // شريط البحث
                
                  
                  SizedBox(height: 24.h),
                  
                  // جدول التصنيفات
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CustomScrollView(
                          slivers: [
                            // رأس الجدول
                            SliverToBoxAdapter(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                                ),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    _buildHeaderCell("المعرف", 1),
                                    _buildHeaderCell("اسم التصنيف", 2),
                                    _buildHeaderCell("الرابط", 2),
                                    _buildHeaderCell("الوصف", 2),
                                    _buildHeaderCell("تاريخ الإنشاء", 1),
                                    _buildHeaderCell("الإجراءات", 1),
                                  ],
                                ),
                              ),
                            ),
                            
                            // محتوى الجدول
                            Obx(() {
                              if (controller.isLoading.value) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 3.r,
                                    ),
                                  ),
                                );
                              }
                              
                              if (controller.items.isEmpty) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.category_outlined,
                                          size: 64.r,
                                          color: AppColors.textSecondary(isDark),
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'لا توجد تصنيفات',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: AppTextStyles.tajawal,
                                            color: AppColors.textSecondary(isDark),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'انقر على "إضافة تصنيف" لإنشاء أول تصنيف',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: AppTextStyles.tajawal,
                                            color: AppColors.textSecondary(isDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildCategoryRow(
                                    controller.items[index],
                                    index,
                                    isDark,
                                    index % 2 == 0 ? rowColor1 : rowColor2,
                                  ),
                                  childCount: controller.items.length,
                                ),
                              );
                            }),
                          ],
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
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(isDark),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(PostCategoryModel category, int index, bool isDark, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      color: color,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _buildCell(category.id.toString(), 1),
          _buildCell(category.name, 2, fontWeight: FontWeight.w500),
          _buildCell(category.slug, 2, color: AppColors.textSecondary(isDark)),
          _buildCell(
            category.description ?? 'لا يوجد وصف',
            2,
            color: AppColors.textSecondary(isDark),
            maxLines: 1,
          ),
          _buildCell(
            category.createdAt != null ? _formatDate(category.createdAt!) : 'غير محدد',
            1,
            color: AppColors.textSecondary(isDark),
          ),
          
          // أزرار الإجراءات
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر التفاصيل
                IconButton(
                  icon: Icon(Icons.visibility, size: 18.r, color: Colors.blue),
                  onPressed: () => _showDetailsDialog(category),
                  tooltip: 'عرض التفاصيل',
                ),
                
                SizedBox(width: 4.w),
                
                // زر التعديل
                IconButton(
                  icon: Icon(Icons.edit, size: 18.r, color: AppColors.primary),
                  onPressed: () => _showEditCategoryDialog(category),
                  tooltip: 'تعديل التصنيف',
                ),
                
                SizedBox(width: 4.w),
                
                // زر الحذف
                IconButton(
                  icon: Icon(Icons.delete, size: 18.r, color: AppColors.error),
                  onPressed: () => _showDeleteDialog(category.id, category.name),
                  tooltip: 'حذف التصنيف',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, int flex, {
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    int maxLines = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}