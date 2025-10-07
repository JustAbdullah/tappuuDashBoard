import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/SubCategoryLevelTwoController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/core/data/model/category.dart' as categoryTras;
import 'package:tappuu_dashboard/core/data/model/subcategory_level_two.dart';
import '../ImageUploadWidget.dart';

class SubCategoriesLevelTwoViewDeskTop extends StatefulWidget {
  const SubCategoriesLevelTwoViewDeskTop({Key? key}) : super(key: key);

  @override
  _SubCategoriesLevelTwoViewDeskTopState createState() => _SubCategoriesLevelTwoViewDeskTopState();
}

class _SubCategoriesLevelTwoViewDeskTopState extends State<SubCategoriesLevelTwoViewDeskTop> {
  final SubCategoryLevelTwoController controller = Get.put(SubCategoryLevelTwoController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _editNameController = TextEditingController();
  
  String _lang = 'ar';
  String _filter = 'الكل';
  int? _selectedCategoryId;
  int? _selectedParent1Id;
  int? _selectedFilterCategoryId;
  int? _selectedFilterParent1Id;
  bool _showFilterWarning = false;
  bool _isFilterLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await controller.fetchSubCategoriesLevelTwo(language: _lang);
    await controller.fetchCategories(_lang);
  }

  void _showAddDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    controller.resetForm();
    _nameController.clear();
    _selectedCategoryId = null;
    _selectedParent1Id = null;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return _buildDialog(
            context: context,
            setState: setState,
            title: 'إضافة تصنيف فرعي ثاني جديد',
            icon: Icons.category,
            nameController: _nameController,
            onSave: () async {
              if (_nameController.text.isEmpty) {
                Get.snackbar('تحذير', 'الرجاء إدخال اسم التصنيف الفرعي الثاني',
                  backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }
              if (_selectedCategoryId == null || _selectedParent1Id == null) {
                Get.snackbar('تحذير', 'الرجاء اختيار التصنيف الرئيسي والفرعي الأول',
                  backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }
              
              await controller.createSubCategoryLevelTwo(_selectedParent1Id!, _nameController.text);
              Get.back();
              _applyFilter();
            },
            isDark: isDark,
            isAdd: true,
          );
        }
      )
    );
  }
void _showEditDialog(SubcategoryLevelTwo subCategory) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  _editNameController.text = subCategory.name;
  _selectedParent1Id = subCategory.subCategoryLevelOneId;

  // تعيين القيم الحالية للحقول الإضافية
  controller.levelTwoSlugController.text = subCategory.slug ?? '';
  controller.levelTwoMetaTitleController.text = subCategory.metaTitle ?? '';
  controller.levelTwoMetaDescController.text = subCategory.metaDescription ?? '';

  // تحميل الصورة إذا كانت موجودة
  if (subCategory.image != null && subCategory.image!.isNotEmpty) {
    controller.loadImageFromUrl(subCategory.image!);
  } else {
    controller.imageBytes.value = null;
  }

  Get.dialog(
    StatefulBuilder(
      builder: (context, setState) {
        return _buildDialog(
          context: context,
          setState: setState,
          title: 'تعديل التصنيف الفرعي الثاني',
          icon: Icons.edit,
          nameController: _editNameController,
          onSave: () async {
            if (_editNameController.text.isEmpty) {
              Get.snackbar('تحذير', 'الرجاء إدخال اسم التصنيف الفرعي الثاني',
                backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }
            if (_selectedCategoryId == null || _selectedParent1Id == null) {
              Get.snackbar('تحذير', 'الرجاء اختيار التصنيف الرئيسي والفرعي الأول',
                backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }
            
            await controller.updateSubCategoryLevelTwo(
              subCategory, 
              _selectedParent1Id!, 
              _editNameController.text
            );
            Get.back();
            _applyFilter();
          },
          isDark: isDark,
          isAdd: false,
        );
      }
    )
  );
}  
Widget _buildDialog({
  required BuildContext context,
  required void Function(void Function()) setState,
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
              _buildTextField('اسم التصنيف الفرعي الثاني (العربية)', 
                Icons.text_fields, nameController, isDark),
              
              // إضافة الحقول الجديدة في حالة التعديل فقط
              if (!isAdd) ...[
                SizedBox(height: 16.h),
                _buildTextField('Slug (العربية)', Icons.link, controller.levelTwoSlugController, isDark),
                SizedBox(height: 16.h),
                _buildTextField('Meta Title (العربية)', Icons.title, controller.levelTwoMetaTitleController, isDark),
                SizedBox(height: 16.h),
                _buildTextField('Meta Description (العربية)', Icons.description, controller.levelTwoMetaDescController, isDark,),
              ],
              
              SizedBox(height: 16.h),
              Text('صورة التصنيف الفرعي الثاني (اختياري)', style: TextStyle(
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
              _buildCategoryDropdown(context, setState, isDark),
              SizedBox(height: 16.h),
              _buildParentSubCategoryDropdown(context, setState, isDark),
              SizedBox(height: 24.h),
              _buildActionButtons(onSave, isDark, isAdd),
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

  Widget _buildCategoryDropdown(
    BuildContext context, 
    void Function(void Function()) setState, 
    bool isDark
  ) {
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
            value: _selectedCategoryId,
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
                  orElse: () => categoryTras.Translation(id: 0, categoryId: 0, language: 'ar', name: 'غير معروف', description: '')
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
                _selectedParent1Id = null;
                if (newValue != null) {
                  controller.fetchSubCategories(categoryId:  newValue, language:  _lang);
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildParentSubCategoryDropdown(
    BuildContext context, 
    void Function(void Function()) setState, 
    bool isDark
  ) {
    final validSelectedValue = _selectedParent1Id != null &&
        controller.parentSubCategoriesList.any((subCat) => subCat.id == _selectedParent1Id)
            ? _selectedParent1Id
            : null;

    return Obx(() => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider(isDark))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: validSelectedValue,
            isExpanded: true,
            hint: controller.isLoadingParentSubCategories.value
                ? Text('جاري التحميل...', style: TextStyle(
                    fontSize: 14.sp, 
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  ))
                : Text('اختر التصنيف الفرعي الأول', style: TextStyle(
                    fontSize: 14.sp, 
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  )),
            icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
            items: controller.isLoadingParentSubCategories.value
                ? [
                    DropdownMenuItem<int>(
                      value: null,
                      child: Text('جاري التحميل...', style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                    )))
                  ]
                : [
                    DropdownMenuItem<int>(
                      value: null,
                      child: Text('اختر التصنيف الفرعي الأول', style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                    ))),
                    ...controller.parentSubCategoriesList.map((subCat) {
                      return DropdownMenuItem<int>(
                        value: subCat.id,
                        child: Text(subCat.name, style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textPrimary(isDark),
                      )));
                    }).toList(),
                  ],
            onChanged: controller.isLoadingParentSubCategories.value
                ? null
                : (int? newValue) {
                    setState(() {
                      _selectedParent1Id = newValue;
                    });
                  },
          ),
        ),
      ),
    ));
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

  void _showDeleteDialog(int id, int parent1Id) {
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
                      ))),
                      Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        onPressed: controller.isDeleting.value ? null : () {
                          controller.deleteSubCategoryLevelTwo(id, parent1Id);
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
    if (_selectedFilterCategoryId == null || _selectedFilterParent1Id == null) {
      setState(() {
        _showFilterWarning = true;
      });
      return;
    }

    setState(() {
      _isFilterLoading = true;
      _showFilterWarning = false;
    });
    
    try {
      await controller.fetchSubCategoriesLevelTwo(
        parent1Id: _selectedFilterParent1Id, 
        language: _lang
      );
    } finally {
      setState(() {
        _isFilterLoading = false;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedFilterCategoryId = null;
      _selectedFilterParent1Id = null;
      _showFilterWarning = false;
    });
    controller.fetchSubCategoriesLevelTwo(language: _lang);
  }
Widget _buildImageForSubCategoryLevelTwo(SubcategoryLevelTwo subCategory, int index) {
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, 
            textDirection: TextDirection.rtl, children: [
            Row(textDirection: TextDirection.rtl, 
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
              Text('إدارة التصنيفات الفرعية الثانية', style: TextStyle(
                fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
              )),
              ElevatedButton.icon(
                icon: Icon(Icons.add, size:18.r),
                label: Text('إضافة تصنيف فرعي ثاني', style: TextStyle(
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
            Row(textDirection: TextDirection.rtl, 
              mainAxisAlignment: MainAxisAlignment.end, 
              children: [
              _buildLangButton('ar', 'العربية', true),
              SizedBox(width:10.w),
              _buildLangButton('en', 'English', false),
            ]),
            SizedBox(height:16.h),
            // شريط البحث
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
                      hintText: 'ابحث عن تصنيف فرعي ثاني...',
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
                    onPressed: () => controller.fetchSubCategoriesLevelTwo(
                      parent1Id: _selectedFilterParent1Id, 
                      language: _lang,
                      searchName: _searchController.text.toString(),
                    ),
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
           Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 900.w, minWidth: 400.w),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          // صف واحد يحتوي على التصنيف الرئيسي والفرعي جنبًا إلى جنب
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'التصنيف الرئيسي',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              SizedBox(width: 5.w),

              // Expanded حول Dropdown الأول
              Expanded(
                child: Obx(() {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.divider(isDark)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedFilterCategoryId,
                        isExpanded: true,
                        hint: Text(
                          'اختر التصنيف الرئيسي',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                        icon: Icon(Icons.arrow_drop_down, size: 20.r),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.primary,
                        ),
                        items: [
                          DropdownMenuItem<int>(
                            value: null,
                            child: Text(
                              'جميع التصنيفات',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          ...controller.categoriesList.map((category) {
                            final arTr = category.translations.firstWhere(
                              (t) => t.language == 'ar',
                              orElse: () => categoryTras.Translation(
                                id: 0,
                                categoryId: 0,
                                language: 'ar',
                                name: 'غير معروف',
                                description: '',
                              ),
                            );
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(arTr.name, style: TextStyle(fontSize: 14.sp)),
                            );
                          }).toList(),
                        ],
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedFilterCategoryId = newValue;
                            _selectedFilterParent1Id = null;
                            if (newValue != null) {
                              controller.fetchSubCategories(
                                categoryId: newValue,
                                language: _lang,
                              );
                            }
                          });
                        },
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(width: 10.w),

              Text(
                'التصنيف الفرعي الأول',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              SizedBox(width: 5.w),

              // Expanded حول Dropdown الثاني
              Expanded(
                child: Obx(() {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.divider(isDark)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedFilterParent1Id != null &&
                                controller.parentSubCategoriesList.any((subCat) =>
                                    subCat.id == _selectedFilterParent1Id)
                            ? _selectedFilterParent1Id
                            : null,
                        isExpanded: true,
                        hint: controller.isLoadingParentSubCategories.value
                            ? Text(
                                'جاري التحميل...',
                                style: TextStyle(fontSize: 14.sp),
                              )
                            : Text(
                                'اختر التصنيف الفرعي الأول',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                        icon: Icon(Icons.arrow_drop_down, size: 20.r),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.primary,
                        ),
                        items: controller.isLoadingParentSubCategories.value
                            ? [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text(
                                    'جاري التحميل...',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                )
                              ]
                            : [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text(
                                    'جميع التصنيفات الفرعية',
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                ...controller.parentSubCategoriesList.map((subCat) {
                                  return DropdownMenuItem<int>(
                                    value: subCat.id,
                                    child: Text(subCat.name,
                                        style: TextStyle(fontSize: 14.sp)),
                                  );
                                }).toList(),
                              ],
                        onChanged: controller.isLoadingParentSubCategories.value
                            ? null
                            : (int? newValue) {
                                setState(() {
                                  _selectedFilterParent1Id = newValue;
                                });
                              },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // أزرار الفلترة
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isFilterLoading ? null : _applyFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: _isFilterLoading
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.r),
                      )
                    : Text(
                        'تطبيق الفلترة',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                        ),
                      ),
              ),
              SizedBox(width: 16.w),
              ElevatedButton(
                onPressed: _clearFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text(
                  'حذف الفلترة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                  ),
                ),
              ),
              if (_showFilterWarning)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    'يجب اختيار التصنيف الرئيسي والفرعي الأول معاً لتطبيق الفلترة',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12.sp,
                      fontFamily: AppTextStyles.tajawal,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  ),
)
,
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
                      _buildHeaderCell("الصورة", 1), // عمود الصورة الجديد
                      _buildHeaderCell("اسم التصنيف الفرعي الثاني", 2),
                      _buildHeaderCell("الفرعي الأول", 1),
                      _buildHeaderCell("الرئيسي", 1),
                      _buildHeaderCell("عدد الإعلانات", 1),
                      _buildHeaderCell("تاريخ الإنشاء", 1),
                      _buildHeaderCell("الإجراءات", 1),
                    ]),
                  )),
                  Obx(() {
                    if (controller.isLoadingSubCategoriesLevelTwo.value) {
                      return SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth:3.r)),
                      );
                    }
                    if (controller.subCategoriesLevelTwoList.isEmpty) {
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
                          controller.subCategoriesLevelTwoList[index], 
                          index, 
                          isDark,
                          index % 2 == 0 ? rowColor1 : rowColor2
                        ),
                        childCount: controller.subCategoriesLevelTwoList.length,
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
          if (_selectedFilterCategoryId != null) {
            controller.fetchSubCategories(categoryId:  _selectedFilterCategoryId!,language:  _lang);
          }
          controller.fetchSubCategoriesLevelTwo(
            parent1Id: _selectedFilterParent1Id, 
            language: _lang
          );
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

  Widget _buildSubCategoryRow(SubcategoryLevelTwo subCategory, int index, 
      bool isDark, Color color) {
    final createdAt = DateTime.parse(subCategory.date);
    final dateText = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    
    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(subCategory.id.toString(), 1),
        // خلية الصورة
        Expanded(
          flex: 1,
          child: Center(
            child: _buildImageForSubCategoryLevelTwo(subCategory, index),
          ),
        ),
        _buildCell(subCategory.name, 2, fontWeight: FontWeight.w500),
        _buildCell(subCategory.parent1Name, 1, fontWeight: FontWeight.w500),
        _buildCell(subCategory.parentCategoryName, 1, fontWeight: FontWeight.w500),
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
            onPressed: () => _showDeleteDialog(
              subCategory.id, 
              subCategory.subCategoryLevelOneId
            ),
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