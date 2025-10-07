import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/CategoriesController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../core/data/model/category.dart';
import '../ImageUploadWidget.dart';

class CategoriesViewDeskTop extends StatefulWidget {
  const CategoriesViewDeskTop({Key? key}) : super(key: key);

  @override
  _CategoriesViewDeskTopState createState() => _CategoriesViewDeskTopState();
}

class _CategoriesViewDeskTopState extends State<CategoriesViewDeskTop> {
  final CategoriesController controller = Get.put(CategoriesController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editDescController = TextEditingController();
  
  String _lang = 'ar';
  String _filter = 'الكل';
  Category? _editingCat;
  
  final List<Color> iconColors = [
    const Color(0xFFFF754B),
    const Color(0xFF3BB8C8),
    const Color(0xFF85BE44),
    const Color(0xFFECA02F),
    const Color(0xFFF48FB1),
    const Color(0xFF90CAF9),
    const Color(0xFFA5D6A7),
    const Color(0xFFCE93D8),
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchCategories(language:  _lang);
  }

  Color _getIconColor(int index) => iconColors[index % iconColors.length];

  void _showAddDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    controller.resetForm();
    _nameController.clear();
    _descController.clear();

    Get.dialog(_buildDialog(
      title: 'إضافة تصنيف جديد',
      icon: Icons.category,
      nameController: _nameController,
      descController: _descController,
      onSave: () async {
        if (_nameController.text.isEmpty) {
          Get.snackbar('تحذير', 'الرجاء إدخال اسم التصنيف',
            backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
        await controller.createCategory(
          _nameController.text, _descController.text);
        Get.back();
      },
      isDark: isDark,
      isEdit: false,
    ));
  }

  void _showEditDialog(Category category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _editingCat = category;
    
    final arTr = category.translations.firstWhere(
      (t) => t.language == 'ar', 
      orElse: () => Translation(id:0, categoryId:0, language:'ar', name:'', description:'')
    );
    
    _editNameController.text = arTr.name;
    _editDescController.text = arTr.description ?? '';
    
    // تعيين القيم الحالية للحقول الإضافية
    controller.slugController.text = category.slug ?? '';
    controller.metaTitleController.text = category.metaTitle ?? '';
    controller.metaDescController.text = category.metaDescription ?? '';
    
    if (category.image != null && category.image!.isNotEmpty) {
      controller.loadImageFromUrl(category.image!);
    } else {
      controller.imageBytes.value = null;
    }

    Get.dialog(_buildDialog(
      title: 'تعديل التصنيف',
      icon: Icons.edit,
      nameController: _editNameController,
      descController: _editDescController,
      onSave: () async {
        if (_editNameController.text.isEmpty) {
          Get.snackbar('تحذير', 'الرجاء إدخال اسم التصنيف',
            backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
        if (_editingCat != null) {
          await controller.updateCategory(
            _editingCat!, _editNameController.text, _editDescController.text);
        }
        Get.back();
      },
      isDark: isDark,
      isEdit: true,
    ));
  }

  Widget _buildDialog({
    required String title,
    required IconData icon,
    required TextEditingController nameController,
    required TextEditingController descController,
    required VoidCallback onSave,
    required bool isDark,
    required bool isEdit,
  }) {
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
                    Icon(icon, size: 24.r, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Text(title, style: TextStyle(
                      fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700, 
                      color: AppColors.textPrimary(isDark),
                    )),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildTextField('اسم التصنيف (العربية)', Icons.text_fields, nameController, isDark),
                SizedBox(height: 16.h),
                _buildTextField('وصف التصنيف (العربية)', Icons.description, descController, isDark, maxLines: 2),
                
                // إضافة الحقول الجديدة في حالة التعديل فقط
                if (isEdit) ...[
                  SizedBox(height: 16.h),
                  _buildTextField('Slug (الإنجليزية)', Icons.link, controller.slugController, isDark),
                  SizedBox(height: 16.h),
                  _buildTextField('Meta Title (العربية)', Icons.title, controller.metaTitleController, isDark),
                  SizedBox(height: 16.h),
                  _buildTextField('Meta Description (العربية)', Icons.description, controller.metaDescController, isDark, maxLines: 2),
                ],
                
                SizedBox(height: 16.h),
                Text('صورة التصنيف (اختياري)', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                )),
                SizedBox(height: 8.h),
                Obx(() => ImageUploadWidget(
                  imageBytes: controller.imageBytes.value,
                  onPickImage: controller.pickImage,
                  onRemoveImage: controller.removeImage,
                )),
                SizedBox(height: 24.h),
                _buildActionButtons(onSave, isDark, !isEdit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, 
      bool isDark, {int maxLines = 1}) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: maxLines == 1 ? 16.sp : 14.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
          color: AppColors.textSecondary(isDark)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: AppColors.card(isDark),
        prefixIcon: Icon(icon, size: 22.r),
      ),
    );
  }

  Widget _buildActionButtons(VoidCallback onSave, bool isDark, bool isAdd) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('إلغاء', style: TextStyle(
            fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          )),
        ),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          onPressed: controller.isSaving.value ? null : onSave,
          child: controller.isSaving.value
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isAdd ? Icons.add : Icons.save, size: 20.r),
                SizedBox(width: 8.w),
                Text(isAdd ? 'إضافة' : 'حفظ التعديلات', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                )),
              ]),
        )),
      ],
    );
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
                  Text('هل أنت متأكد من حذف هذا التصنيف؟', style: TextStyle(
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
                          controller.deleteCategory(id);
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
              Text('إدارة التصنيفات', style: TextStyle(
                fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
              )),
              ElevatedButton.icon(
                icon: Icon(Icons.add, size:18.r),
                label: Text('إضافة تصنيف', style: TextStyle(
                  fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.w600,
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical:12.h, horizontal:20.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                onPressed: _showAddDialog,
              ),
            ]),
            SizedBox(height:16.h),
            Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.end, children: [
              _buildLangButton('ar', 'العربية', true),
              SizedBox(width:10.w),
              _buildLangButton('en', 'English', false),
            ]),
            SizedBox(height:16.h),
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
                      hintText: 'ابحث عن تصنيف...',
                      hintStyle: TextStyle(
                        fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark)),
                      prefixIcon: Icon(Icons.search, size:22.r),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  )),
                  SizedBox(width:12.w),
                
                  SizedBox(width:8.w),
                  ElevatedButton(
                    onPressed: () => controller.fetchCategories(language:  _lang,searchName:_searchController.text.toString() ),
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
                      _buildHeaderCell("المعرف", 1),
                      _buildHeaderCell("الصورة", 1),
                      _buildHeaderCell("الاسم", 2),
                      _buildHeaderCell("الوصف", 2),
                      _buildHeaderCell("عدد الإعلانات", 1),
                      _buildHeaderCell("تاريخ الإنشاء", 1),
                      _buildHeaderCell("الإجراءات", 1),
                    ]),
                  )),
                  Obx(() {
                    if (controller.isLoadingCategories.value) {
                      return SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth:3.r)),
                      );
                    }
                    if (controller.categoriesList.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.category_outlined, size:64.r, color: AppColors.textSecondary(isDark)),
                          SizedBox(height:16.h),
                          Text('لا توجد تصنيفات', style: TextStyle(
                            fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )),
                        ]),
                      ));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildCategoryRow(
                          controller.categoriesList[index], 
                          index, 
                          isDark,
                          index % 2 == 0 ? rowColor1 : rowColor2
                        ),
                        childCount: controller.categoriesList.length,
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
          controller.fetchCategories(language:  lang);
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

  Widget _buildCategoryRow(Category category, int index, bool isDark, Color color) {
    final tr = category.translations.firstWhere(
      (t) => t.language == _lang,
      orElse: () => Translation(
        id:0, categoryId:0, 
        language:_lang, 
        name:'N/A', 
        description:'N/A'
      ));
final createdAt = _parseDate(category.date) ?? DateTime.now().subtract(Duration(days: 1));
final dateText = _formatDaysAgo(createdAt);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(category.id.toString(), 1),
        Expanded(flex:1, child: Center(child: Container(
          width:45.w, height:45.h,
          decoration: BoxDecoration(
            color: _getIconColor(index),
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Center(child: category.image != null && category.image!.isNotEmpty
              ? Image.network(category.image!, width:30.r, height:30.r, fit: BoxFit.cover)
              : Container(
                  width:30.r, height:30.r,
                  decoration: BoxDecoration(
                    color: _getIconColor(index),
                    borderRadius: BorderRadius.circular(8.r)),
                  child: Icon(Icons.category, color: Colors.white),
                ),
          )),
        ))),
        _buildCell(tr.name, 2, fontWeight: FontWeight.w500),
        _buildCell(tr.description ?? 'لا يوجد وصف', 2, 
          color: AppColors.textSecondary(isDark), 
          maxLines:2, fontWeight: FontWeight.w500),
        _buildCell(category.adsCount.toString(), 1, 
          color: AppColors.primary, fontWeight: FontWeight.bold),
        _buildCell(dateText, 1, color: AppColors.textSecondary(isDark)),
        Expanded(flex:1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: Icon(Icons.edit, size:18.r, color: AppColors.primary),
            onPressed: () => _showEditDialog(category),
          ),
          SizedBox(width:8.w),
          IconButton(
            icon: Icon(Icons.delete, size:18.r, color: AppColors.error),
            onPressed: () => _showDeleteDialog(category.id),
          ),
        ])),
      ]),
    );
  }

  Widget _buildCell(String text, int flex, {
    Color? color, 
    FontWeight fontWeight = FontWeight.normal,
    int maxLines = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Text(text, 
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
          fontWeight: fontWeight, color: color,
        )),
    );
  }
}
 
 String _formatDaysAgo(DateTime date) {
  final now = DateTime.now();
  final days = now.difference(date).inDays;
  return 'منذ $days يوم';
}

DateTime? _parseDate(String dateString) {
  try {
    return DateTime.parse(dateString);
  } catch (_) {
    return null;
  }
}