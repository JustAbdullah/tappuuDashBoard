import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/SubCategoryController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/subcategory_level_one.dart';
import 'package:tappuu_dashboard/core/data/model/category.dart' as categoryTras;

import '../AdminSidebar.dart';

class SubCategoriesViewMobile extends StatefulWidget {
  const SubCategoriesViewMobile({Key? key}) : super(key: key);

  @override
  _SubCategoriesViewMobileState createState() => _SubCategoriesViewMobileState();
}

class _SubCategoriesViewMobileState extends State<SubCategoriesViewMobile> {
  final SubCategoryController controller = Get.put(SubCategoryController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _editNameController = TextEditingController();
  
  String _lang = 'ar';
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
    
    final arTr = subCategory.translations.firstWhere(
      (t) => t.language == 'ar', 
      orElse: () => Translation(id:0, subCategoryLevelOneId:0, language:'ar', name:'')
    );
    
    _editNameController.text = arTr.name;
    _selectedCategoryId = subCategory.categoryId;

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
        await controller.updateSubCategory(
          subCategory, _selectedCategoryId!, _editNameController.text,);
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
    return Dialog(
      backgroundColor: AppColors.surface(isDark),
      insetPadding: EdgeInsets.all(16.r),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.r),
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
              SizedBox(height: 16.h),
              _buildTextField('اسم التصنيف الفرعي (العربية)', Icons.text_fields, nameController, isDark),
              SizedBox(height: 12.h),
              Text('التصنيف الرئيسي', style: TextStyle(
                fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              _buildCategoryDropdown(isDark),
              SizedBox(height: 20.h),
              _buildActionButtons(onSave, isDark, isAdd),
            ],
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          onPressed: controller.isSaving.value ? null : onSave,
          child: controller.isSaving.value
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isAdd ? Icons.add : Icons.save, size: 18.r),
                SizedBox(width: 6.w),
                Text(isAdd ? 'إضافة' : 'حفظ', style: TextStyle(
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
      Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.all(16.r),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error),
                  SizedBox(width:10.w),
                  Text('تأكيد الحذف', style: TextStyle(
                    fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.w700, color: AppColors.error,
                  )),
                ],
              ),
              SizedBox(height:16.h),
              Text('هل أنت متأكد من حذف هذا التصنيف الفرعي؟', style: TextStyle(
                fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                color: AppColors.textPrimary(isDark)),
              ),
              SizedBox(height:8.h),
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
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    )),
                  ),
                  Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal:20.w, vertical:10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                    onPressed: controller.isDeleting.value ? null : () {
                      controller.deleteSubCategory(id, categoryId);
                      Get.back();
                      _applyFilter();
                    },
                    child: controller.isDeleting.value
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.delete, size:18.r),
                          SizedBox(width:6.w),
                          Text('حذف', style: TextStyle(
                            fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
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
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
     drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context), // دالة إغلاق الدرج
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.appBar(isDark),
        elevation: 2,
     
        title: Text('التصنيفات الفرعية', style: TextStyle(
          fontSize: 18.sp, 
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w800, 
          color: AppColors.onPrimary,
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            // Language Toggle
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLangButton('ar', 'العربية', true),
                SizedBox(width: 10.w),
                _buildLangButton('en', 'English', false),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Search Field
            Center(child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth:400.w, minWidth:200.w),
              child: Container(
                height:50.h,
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
            SizedBox(height: 16.h),
            
            // Filter Section
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text('فلترة حسب التصنيف الرئيسي:', style: TextStyle(
                    fontSize: 14.sp, 
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  )),
                  SizedBox(height: 10.h),
                  Obx(() {
                    if (controller.isLoadingCategories.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.divider(isDark))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedFilterCategoryId,
                            isExpanded: true,
                            hint: Text('جميع التصنيفات', style: TextStyle(
                              fontSize: 14.sp, 
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                            icon: Icon(Icons.arrow_drop_down, size: 20.r),
                            style: TextStyle(
                              fontSize: 14.sp, 
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.primary),
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text('جميع التصنيفات', style: TextStyle(fontSize: 14.sp))),
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
                                  child: Text(arTr.name, style: TextStyle(fontSize: 14.sp)),
                                );
                              }).toList(),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                _selectedFilterCategoryId = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                );
                  }),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: _isFilterLoading ? null : _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: Size(double.infinity, 45.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                    )),
                    child: _isFilterLoading
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                      : Text('تطبيق الفلترة', style: TextStyle(
                          fontSize: 16.sp, 
                          fontFamily: AppTextStyles.tajawal,
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            
            // Sub Categories List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingSubCategories.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary, 
                      strokeWidth: 3.r,
                    ),
                  );
                }
                
                if (controller.subCategoriesList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined, 
                          size: 64.r, 
                          color: AppColors.textSecondary(isDark)),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد تصنيفات فرعية',
                          style: TextStyle(
                            fontSize: 16.sp, 
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                        ),
                    )],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: controller.subCategoriesList.length,
                  itemBuilder: (context, index) {
                    final subCategory = controller.subCategoriesList[index];
                    final arTr = subCategory.translations.firstWhere(
                      (t) => t.language == _lang,
                      orElse: () => Translation(
                        id:0, 
                        subCategoryLevelOneId:0, 
                        language:_lang, 
                        name:'N/A'
                      ),
                    );
                    
                    final createdAt = subCategory.date ?? DateTime.now().subtract(Duration(days: 1));
                    final dateText = _formatDaysAgo(createdAt);
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Container(
                                  width: 40.r,
                                  height: 40.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(Icons.category, color: AppColors.primary),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    arTr.name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: AppTextStyles.tajawal,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary(isDark),
                                  )),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Divider(height: 1, color: AppColors.divider(isDark)),
                            SizedBox(height: 12.h),
                            
                            // Details
                            _buildDetailRow('التصنيف الرئيسي', subCategory.categoryName),
                            SizedBox(height: 8.h),
                            _buildDetailRow('عدد الإعلانات', subCategory.adsCount.toString()),
                            SizedBox(height: 8.h),
                            _buildDetailRow('تاريخ الإنشاء', dateText),
                            SizedBox(height: 16.h),
                            
                            // Action Buttons
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: Icon(Icons.edit, size: 18.r, color: AppColors.primary),
                                    label: Text('تعديل', style: TextStyle(
                                      fontSize: 14.sp, 
                                      fontFamily: AppTextStyles.tajawal,
                                      color: AppColors.primary,
                                    )),
                                    onPressed: () => _showEditDialog(subCategory),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 8.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      side: BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: Icon(Icons.delete, size: 18.r, color: AppColors.error),
                                    label: Text('حذف', style: TextStyle(
                                      fontSize: 14.sp, 
                                      fontFamily: AppTextStyles.tajawal,
                                      color: AppColors.error,
                                    )),
                                    onPressed: () => _showDeleteDialog(subCategory.id, subCategory.categoryId),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 8.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      side: BorderSide(color: AppColors.error),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Text('$label: ', style: TextStyle(
          fontSize: 14.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary(isDark),
        )),
        Expanded(
          child: Text(value, 
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark),
          )),
        ),
      ],
    );
  }

  Widget _buildLangButton(String lang, String text, bool isLeft) {
    final isSelected = _lang == lang;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _lang = lang;
            controller.fetchSubCategories(categoryId: _selectedFilterCategoryId, language: lang);
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
              bottomLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
              topRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
              bottomRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
          ),
        ),
      ),
    );
  }
  
  String _formatDaysAgo(DateTime date) {
    final now = DateTime.now();
    final days = now.difference(date).inDays;
    return 'منذ $days يوم';
  }
}