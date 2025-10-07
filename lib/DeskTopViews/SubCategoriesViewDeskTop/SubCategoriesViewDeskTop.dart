import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/SubCategoryController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/category.dart' as categoryTras;
import '../ImageUploadWidget.dart';

import '../../core/data/model/subcategory_level_one.dart';

class SubCategoriesViewDeskTop extends StatefulWidget {
  const SubCategoriesViewDeskTop({Key? key}) : super(key: key);

  @override
  _SubCategoriesViewDeskTopState createState() => _SubCategoriesViewDeskTopState();
}

class _SubCategoriesViewDeskTopState extends State<SubCategoriesViewDeskTop> {
  final SubCategoryController controller = Get.put(SubCategoryController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _editNameController = TextEditingController();
  
  String _lang = 'ar';
  String _filter = 'الكل';
  SubcategoryLevelOne? _editingSubCat;
  int? _selectedCategoryId;
  int? _selectedFilterCategoryId;
  bool _isFilterLoading = false;
  

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await controller.fetchCategories(_lang);
    await controller.fetchSubCategories(categoryId: null, language: _lang);
  }

  void _showAddDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    controller.resetForm();
    _nameController.clear();
    _selectedCategoryId = null;

    Get.dialog(_buildDialog(
      title: 'إضافة تصنيف فرعي جديد',
      icon: Icons.category,
      nameController: _nameController,
      onSave: () async {
        if (_nameController.text.isEmpty) {
          Get.snackbar('تحذير', 'الرجاء إدخال اسم التصنيف الفرعي',
            backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
        if (_selectedCategoryId == null) {
          Get.snackbar('تحذير', 'الرجاء اختيار التصنيف الرئيسي',
            backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
        
        await controller.createSubCategory(_selectedCategoryId!, _nameController.text);
        Get.back();
        _applyFilter();
      },
      isDark: isDark,
      isAdd: true,
    ));
  }

  void _showEditDialog(SubcategoryLevelOne subCategory) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  _editingSubCat = subCategory;
  
  final arTr = subCategory.translations.firstWhere(
    (t) => t.language == 'ar', 
    orElse: () => Translation(id:0, subCategoryLevelOneId:0, language:'ar', name:'')
  );
  
  _editNameController.text = arTr.name;
  _selectedCategoryId = subCategory.categoryId;

  // تعيين القيم الحالية للحقول الإضافية
  controller.subSlugController.text = subCategory.slug ?? '';
  controller.subMetaTitleController.text = subCategory.metaTitle ?? '';
  controller.subMetaDescController.text = subCategory.metaDescription ?? '';

  // تحميل الصورة إذا كانت موجودة
  if (subCategory.image != null && subCategory.image!.isNotEmpty) {
    controller.loadImageFromUrl(subCategory.image!);
  } else {
    controller.imageBytes.value = null;
  }

  Get.dialog(_buildDialog(
    title: 'تعديل التصنيف الفرعي',
    icon: Icons.edit,
    nameController: _editNameController,
    onSave: () async {
      if (_editNameController.text.isEmpty) {
        Get.snackbar('تحذير', 'الرجاء إدخال اسم التصنيف الفرعي',
          backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }
      if (_editingSubCat != null) {
        await controller.updateSubCategory(
          _editingSubCat!, _selectedCategoryId!, _editNameController.text,);
      }
      Get.back();
      _applyFilter();
    },
    isDark: isDark,
    isAdd: false,
  ));
}
Widget _buildDialog({
  required String title,
  required IconData icon,
  required TextEditingController nameController,
  required VoidCallback onSave,
  required bool isDark,
  required bool isAdd,
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
              _buildTextField('اسم التصنيف الفرعي (العربية)', Icons.text_fields, nameController, isDark),
              
              // إضافة الحقول الجديدة في حالة التعديل فقط
              if (!isAdd) ...[
                SizedBox(height: 16.h),
                _buildTextField('Slug (العربية)', Icons.link, controller.subSlugController, isDark),
                SizedBox(height: 16.h),
                _buildTextField('Meta Title (العربية)', Icons.title, controller.subMetaTitleController, isDark),
                SizedBox(height: 16.h),
                _buildTextField('Meta Description (العربية)', Icons.description, controller.subMetaDescController, isDark,),
              ],
              
              SizedBox(height: 16.h),
              Text('صورة التصنيف الفرعي (اختياري)', style: TextStyle(
                fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              Obx(() => ImageUploadWidget(
                imageBytes: controller.imageBytes.value,
                onPickImage: controller.pickImage,
                onRemoveImage: controller.removeImage,
              )),
              SizedBox(height: 16.h),
              Text('التصنيف الرئيسي', style: TextStyle(
                fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              _buildCategoryDropdown(isDark),
              SizedBox(height: 24.h),
              _buildActionButtons(onSave, isDark, isAdd),
            ],
          ),
        ),
      ),
    ),
  );
}
  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool isDark) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      style: TextStyle(
        fontSize: 16.sp,
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

  Widget _buildCategoryDropdown(bool isDark) {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      
      int? selectedValue = _selectedCategoryId;
      if (selectedValue != null && 
          !controller.categoriesList.any((cat) => cat.id == selectedValue)) {
        selectedValue = null;
      }
      
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider(isDark))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedValue,
              isExpanded: true,
              hint: Text('اختر التصنيف الرئيسي', style: TextStyle(
                fontSize: 14.sp, 
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('اختر التصنيف الرئيسي', style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  ))),
                ...controller.categoriesList.map((category) {
                  final arTr = category.translations.firstWhere(
                    (t) => t.language == 'ar',
                    orElse: () =>  categoryTras.Translation(id:0, categoryId:0, language:'ar', name:'', description:'')
                  );
                  
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(arTr.name, style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark),
                    )));
                }).toList(),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _selectedCategoryId = newValue;
                });
              },
            ),
          ),
        ),
      );
    });
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
          ))),
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

  void _showDeleteDialog(int id, int categoryId) {
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
                  Text('هل أنت متأكد من حذف هذا التصنيف الفرعي؟', style: TextStyle(
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
                          controller.deleteSubCategory(id, categoryId);
                          Get.back();
                          _applyFilter();
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

  Future<void> _applyFilter() async {
    setState(() {
      _isFilterLoading = true;
    });
    
    try {
      await controller.fetchSubCategories(
        categoryId: _selectedFilterCategoryId, 
        language: _lang
      );
    } finally {
      setState(() {
        _isFilterLoading = false;
      });
    }
  }
  
  Widget _buildImageForSubCategory(SubcategoryLevelOne subCategory, int index) {
   if (subCategory.image != null && subCategory.image!.isNotEmpty) {
    // تحقق إذا كانت الصورة بصيغة SVG
    if (subCategory.image!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        subCategory.image!,
        width: 45.w,
        height: 45.h,
        placeholderBuilder: (context) => Container(
          padding: EdgeInsets.all(8.r),
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Image.network(
        subCategory.image!,
        fit: BoxFit.cover,
        width: 45.w,
        height: 45.h,
      );
    }
  } else {
    return Container(
      width: 45.w,
      height: 45.h,
      decoration: BoxDecoration(
        color: Colors.amber,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(Icons.warning, color: Colors.white, size: 24.r),
      ),
    );
  }
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
              Text('إدارة التصنيفات الفرعية', style: TextStyle(
                fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
              )),
              ElevatedButton.icon(
                icon: Icon(Icons.add, size:18.r),
                label: Text('إضافة تصنيف فرعي', style: TextStyle(
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
                      hintText: 'ابحث عن تصنيف فرعي...',
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
                    onPressed: () => controller.fetchSubCategories(categoryId:  null, language:  _lang,searchName:_searchController.text.toString() ),
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
            SizedBox(height:16.h),
            Center(child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth:600.w, minWidth:400.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal:16.w, vertical:8.h),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.divider(isDark))),
                child: Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('فلترة حسب التصنيف الرئيسي:', style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    )),
                    SizedBox(width:12.w),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoadingCategories.value) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedFilterCategoryId,
                            isExpanded: true,
                            hint: Text('جميع التصنيفات', style: TextStyle(
                              fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                            icon: Icon(Icons.arrow_drop_down, size:20.r),
                            style: TextStyle(
                              fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                              color: AppColors.primary),
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('جميع التصنيفات', style: TextStyle(fontSize:14.sp))),
                              ...controller.categoriesList.map((category) {
                                final arTr = category.translations.firstWhere(
                                  (t) => t.language == 'ar',
                                  orElse: () => categoryTras.Translation(
                                    id:0, 
                                    categoryId:0, 
                                    language:'ar', 
                                    name:'', 
                                    description:''
                                  )
                                );
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(arTr.name, style: TextStyle(fontSize:14.sp)),
                                );
                              }).toList(),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedFilterCategoryId = newValue;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                    SizedBox(width:16.w),
                    ElevatedButton(
                      onPressed: _isFilterLoading ? null : _applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal:20.w, vertical:8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                      child: _isFilterLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
                        : Text('تطبيق الفلترة', style: TextStyle(
                            fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                          )),
                    ),
                  ],
                ),
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
                      _buildHeaderCell("اسم التصنيف الفرعي", 2),
                      _buildHeaderCell("التصنيف الرئيسي", 2),
                      _buildHeaderCell("عدد الإعلانات", 1),
                      _buildHeaderCell("تاريخ الإنشاء", 1),
                      _buildHeaderCell("الإجراءات", 1),
                    ]),
                  )),
                  Obx(() {
                    if (controller.isLoadingSubCategories.value) {
                      return SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth:3.r)),
                      );
                    }
                    if (controller.subCategoriesList.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.category_outlined, size:64.r, color: AppColors.textSecondary(isDark)),
                          SizedBox(height:16.h),
                          Text('لا توجد تصنيفات فرعية', style: TextStyle(
                            fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )),
                        ]),
                      ));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSubCategoryRow(
                          controller.subCategoriesList[index], 
                          index, 
                          isDark,
                          index % 2 == 0 ? rowColor1 : rowColor2
                        ),
                        childCount: controller.subCategoriesList.length,
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
          controller.fetchSubCategories(categoryId:  _selectedFilterCategoryId, language:  lang);
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

  Widget _buildSubCategoryRow(SubcategoryLevelOne subCategory, int index, bool isDark, Color color) {
    final arTr = subCategory.translations.firstWhere(
      (t) => t.language == _lang,
      orElse: () => Translation(
        id:0, 
        subCategoryLevelOneId:0, 
        language:_lang, 
        name:'N/A'
      ));
    
    final createdAt = subCategory.date ?? DateTime.now().subtract(Duration(days: 1));
    final dateText = _formatDaysAgo(createdAt);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(subCategory.id.toString(), 1),
        Expanded(
          flex: 1,
          child: Center(
            child: _buildImageForSubCategory(subCategory, index),
          ),
        ),
        _buildCell(arTr.name, 2, fontWeight: FontWeight.w500),
        _buildCell(subCategory.categoryName, 2, fontWeight: FontWeight.w500),
        _buildCell(subCategory.adsCount.toString(), 1, 
          color: AppColors.primary, fontWeight: FontWeight.bold),
        _buildCell(dateText, 1, color: AppColors.textSecondary(isDark)),
        Expanded(flex:1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: Icon(Icons.edit, size:18.r, color: AppColors.primary),
            onPressed: () => _showEditDialog(subCategory),
          ),
          SizedBox(width:8.w),
          IconButton(
            icon: Icon(Icons.delete, size:18.r, color: AppColors.error),
            onPressed: () => _showDeleteDialog(subCategory.id, subCategory.categoryId),
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
  
  String _formatDaysAgo(DateTime date) {
    final now = DateTime.now();
    final days = now.difference(date).inDays;
    return 'منذ $days يوم';
  }
}