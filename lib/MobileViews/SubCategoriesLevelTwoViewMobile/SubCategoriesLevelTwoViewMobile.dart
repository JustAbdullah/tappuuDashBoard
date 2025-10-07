import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/SubCategoryLevelTwoController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/category.dart' as categoryTras;
import 'package:tappuu_dashboard/core/data/model/subcategory_level_two.dart';

import '../AdminSidebar.dart';

class SubCategoriesLevelTwoViewMobile extends StatefulWidget {
  const SubCategoriesLevelTwoViewMobile({Key? key}) : super(key: key);

  @override
  _SubCategoriesLevelTwoViewMobileState createState() => _SubCategoriesLevelTwoViewMobileState();
}

class _SubCategoriesLevelTwoViewMobileState extends State<SubCategoriesLevelTwoViewMobile> {
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
    _nameController.clear();
    _selectedCategoryId = null;
    _selectedParent1Id = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16.h,
              left: 16.w,
              right: 16.w,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary(isDark),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.add, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text('إضافة تصنيف فرعي ثاني جديد', style: TextStyle(
                        fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700, 
                        color: AppColors.textPrimary(isDark),
                      )),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildTextField('اسم التصنيف الفرعي الثاني (العربية)', 
                    Icons.text_fields, _nameController, isDark),
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
                  _buildActionButtons(() async {
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
                    Navigator.pop(context);
                    _applyFilter();
                  }, isDark, true),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _showEditDialog(SubcategoryLevelTwo subCategory) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _editNameController.text = subCategory.name;
    _selectedParent1Id = subCategory.subCategoryLevelOneId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16.h,
              left: 16.w,
              right: 16.w,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary(isDark),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.edit, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text('تعديل التصنيف الفرعي الثاني', style: TextStyle(
                        fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700, 
                        color: AppColors.textPrimary(isDark),
                      )),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildTextField('اسم التصنيف الفرعي الثاني (العربية)', 
                    Icons.text_fields, _editNameController, isDark),
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
                  _buildActionButtons(() async {
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
                    Navigator.pop(context);
                    _applyFilter();
                  }, isDark, false),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        }
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
    return Obx(() {
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
              value: _selectedParent1Id != null &&
                      controller.parentSubCategoriesList.any((subCat) => 
                          subCat.id == _selectedParent1Id)
                          ? _selectedParent1Id
                          : null,
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
      );
    });
  }

  Widget _buildActionButtons(VoidCallback onSave, bool isDark, bool isAdd) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
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
      AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error),
            SizedBox(width:10.w),
            Text('تأكيد الحذف', style: TextStyle(
              fontSize:15.sp, fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w700, color: AppColors.error,
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف هذا التصنيف الفرعي؟', style: TextStyle(
              fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark)),
            ),
            SizedBox(height: 8.h),
            Text('سيتم حذف جميع البيانات المرتبطة به!', style: TextStyle(
              fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.error.withOpacity(0.8),
            )),
          ],
        ),
        actions: [
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
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة التصنيفات الفرعية الثانية', style: TextStyle(
          fontSize: 16.sp, fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w700, 
        )),
       
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context), // دالة إغلاق الدرج
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              // شريط اللغة
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLangButton('ar', 'العربية', true),
                  SizedBox(width: 10.w),
                  _buildLangButton('en', 'English', false),
                ],
              ),
              SizedBox(height: 20.h),
              
              // شريط البحث
                Center(child: Container(
                  width: 300.w,
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
                )),
              SizedBox(height:20.h),
              
              // فلترة التصنيفات
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text('فلترة التصنيفات', style: TextStyle(
                      fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700, 
                      color: AppColors.textPrimary(isDark),
                    )),
                    SizedBox(height:16.h),
                    
                    // التصنيف الرئيسي
                    Text('التصنيف الرئيسي', style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    )),
                    SizedBox(height:8.h),
                    Obx(() => Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal:12.w),
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.divider(isDark))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedFilterCategoryId,
                          isExpanded: true,
                          hint: Text(
                            'اختر التصنيف الرئيسي',
                            style: TextStyle(
                              fontSize:14.sp, 
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                          icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
                          items: [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text('جميع التصنيفات', style: TextStyle(fontSize:14.sp)),
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
                                child: Text(arTr.name, style: TextStyle(fontSize:14.sp)),
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
                    )),
                    SizedBox(height:16.h),
                    
                    // التصنيف الفرعي الأول
                    Text('التصنيف الفرعي الأول', style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    )),
                    SizedBox(height:8.h),
                    Obx(() => Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal:12.w),
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.divider(isDark))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedFilterParent1Id != null &&
                                  controller.parentSubCategoriesList.any((subCat) =>
                                      subCat.id == _selectedFilterParent1Id)
                              ? _selectedFilterParent1Id
                              : null,
                          isExpanded: true,
                          hint: controller.isLoadingParentSubCategories.value
                              ? Text('جاري التحميل...', style: TextStyle(fontSize:14.sp))
                              : Text('اختر التصنيف الفرعي الأول', style: TextStyle(
                                  fontSize:14.sp, 
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDark),
                                )),
                          icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
                          items: controller.isLoadingParentSubCategories.value
                              ? [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('جاري التحميل...', style: TextStyle(fontSize:14.sp)),
                                  )
                                ]
                              : [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('جميع التصنيفات الفرعية', style: TextStyle(fontSize:14.sp)),
                                  ),
                                  ...controller.parentSubCategoriesList.map((subCat) {
                                    return DropdownMenuItem<int>(
                                      value: subCat.id,
                                      child: Text(subCat.name, style: TextStyle(fontSize:14.sp)),
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
                    )),
                    SizedBox(height:24.h),
                    
                    // أزرار الفلترة
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _isFilterLoading ? null : _applyFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: Size(150.w, 45.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: _isFilterLoading
                              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
                              : Text('تطبيق الفلترة', style: TextStyle(fontSize:14.sp)),
                        ),
                        ElevatedButton(
                          onPressed: _clearFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error.withOpacity(0.8),
                            foregroundColor: Colors.white,
                            minimumSize: Size(150.w, 45.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text('حذف الفلترة', style: TextStyle(fontSize:14.sp)),
                        ),
                      ],
                    ),
                    if (_showFilterWarning)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
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
              ),
              SizedBox(height:24.h),
              
              // قائمة التصنيفات
              Obx(() {
                if (controller.isLoadingSubCategoriesLevelTwo.value) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (controller.subCategoriesLevelTwoList.isEmpty) {
                  return Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size:64.r, color: AppColors.textSecondary(isDark)),
                      SizedBox(height:16.h),
                      Text('لا توجد تصنيفات فرعية', style: TextStyle(
                        fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                      )),
                    ],
                  ));
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.subCategoriesLevelTwoList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final subCategory = controller.subCategoriesLevelTwoList[index];
                    final createdAt = DateTime.parse(subCategory.date);
                    final dateText = '${createdAt.day}/${createdAt.month}/${createdAt.year}';
                    
                    return Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(subCategory.name, style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary(isDark),
                              )),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text('ID: ${subCategory.id}', style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.sp,
                                )),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(Icons.category, size: 16.r, color: AppColors.textSecondary(isDark)),
                              SizedBox(width: 4.w),
                              Text('الفرعي الأول: ${subCategory.parent1Name}', style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary(isDark),
                              )),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(Icons.category, size: 16.r, color: AppColors.textSecondary(isDark)),
                              SizedBox(width: 4.w),
                              Text('الرئيسي: ${subCategory.parentCategoryName}', style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary(isDark),
                              )),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Icon(Icons.date_range, size: 16.r, color: AppColors.textSecondary(isDark)),
                                  SizedBox(width: 4.w),
                                  Text(dateText, style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary(isDark),
                                  )),
                                ],
                              ),
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Icon(Icons.ad_units, size: 16.r, color: AppColors.primary),
                                  SizedBox(width: 4.w),
                                  Text('${subCategory.adsCount} إعلان', style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  )),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, size: 20.r, color: AppColors.primary),
                                onPressed: () => _showEditDialog(subCategory),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 20.r, color: AppColors.error),
                                onPressed: () => _showDeleteDialog(
                                  subCategory.id, 
                                  subCategory.subCategoryLevelOneId
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}