import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/AttributeController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/Attribute.dart';
import 'package:tappuu_dashboard/core/data/model/category.dart' as categoryTras;

class AttributesViewDeskTop extends StatefulWidget {
  const AttributesViewDeskTop({Key? key}) : super(key: key);

  @override
  _AttributesViewDeskTopState createState() => _AttributesViewDeskTopState();
}

class _AttributesViewDeskTopState extends State<AttributesViewDeskTop> {
  final AttributeController controller = Get.put(AttributeController());
  final TextEditingController _searchController = TextEditingController();
  
  String _lang = 'ar';
  String _filter = 'الكل';
  int? _selectedFilterCategoryId;
  bool _isFilterLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await controller.fetchCategories(_lang);
    await controller.fetchAttributes(lang: _lang);
  }

  void _showAddDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final nameController = TextEditingController();
    String? selectedType;
    int? selectedCategoryId;
    List<TextEditingController> optionControllers = [];
    bool attributeIsRequired = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return _buildDialog(
            title: 'إضافة خاصية جديدة',
            icon: Icons.tune,
            nameController: nameController,
            onSave: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar('تحذير', 'الرجاء إدخال اسم الخاصية',
                  backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }
              if (selectedType == null) {
                Get.snackbar('تحذير', 'الرجاء اختيار نوع الخاصية',
                  backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }
              
              List<String> options = [];
              if (selectedType == 'options') {
                options = optionControllers.map((c) => c.text).toList();
                if (options.isEmpty) {
                  Get.snackbar('تحذير', 'الرجاء إدخال خيار واحد على الأقل',
                    backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
              }
              
              await controller.createAttribute(
                nameAr: nameController.text,
                valueType: selectedType!,
                isShared: selectedCategoryId == null,
                optionsAr: selectedType == 'options' ? options : null,
                categoryId: selectedCategoryId,
                attributeIsRequired: attributeIsRequired,
              );
              
              Get.back();
              _applyFilter();
            },
            isDark: isDark,
            isAdd: true,
            selectedType: selectedType,
            onTypeChanged: (newValue) {
              setState(() {
                selectedType = newValue;
                if (newValue == 'options' && optionControllers.isEmpty) {
                  optionControllers.add(TextEditingController());
                }
              });
            },
            optionControllers: optionControllers,
            onOptionAdded: () => setState(() => optionControllers.add(TextEditingController())),
            onOptionRemoved: (index) => setState(() => optionControllers.removeAt(index)),
            selectedCategoryId: selectedCategoryId,
            onCategoryChanged: (newId) => setState(() => selectedCategoryId = newId),
            attributeIsRequired: attributeIsRequired,
            onRequiredChanged: (value) => setState(() => attributeIsRequired = value),
          );
        },
      ),
    );
  }

  void _showEditDialog(Attribute attribute) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final nameController = TextEditingController(text: attribute.name);
    String? selectedType = attribute.type;
    int? selectedCategoryId;
    List<TextEditingController> optionControllers = [];
    bool attributeIsRequired = attribute.required;

    if (attribute.type == 'options') {
      for (var option in attribute.options) {
        optionControllers.add(TextEditingController(text: option.value));
      }
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return _buildDialog(
            title: 'تعديل الخاصية',
            icon: Icons.edit,
            nameController: nameController,
            onSave: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar('تحذير', 'الرجاء إدخال اسم الخاصية',
                  backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }
              
              List<String> options = [];
              if (selectedType == 'options') {
                options = optionControllers.map((c) => c.text).toList();
                if (options.isEmpty) {
                  Get.snackbar('تحذير', 'الرجاء إدخال خيار واحد على الأقل',
                    backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
              }
              
              await controller.updateAttribute(
                id: attribute.id,
                nameAr: nameController.text,
                valueType: selectedType!,
                optionsAr: selectedType == 'options' ? options : null,
                attributeIsRequired: attributeIsRequired,
              );
              
              Get.back();
              _applyFilter();
            },
            isDark: isDark,
            isAdd: false,
            selectedType: selectedType,
            onTypeChanged: (newValue) {
              setState(() {
                selectedType = newValue;
                if (newValue == 'options' && optionControllers.isEmpty) {
                  optionControllers.add(TextEditingController());
                }
              });
            },
            optionControllers: optionControllers,
            onOptionAdded: () => setState(() => optionControllers.add(TextEditingController())),
            onOptionRemoved: (index) => setState(() => optionControllers.removeAt(index)),
            selectedCategoryId: selectedCategoryId,
            onCategoryChanged: (newId) => setState(() => selectedCategoryId = newId),
            attributeIsRequired: attributeIsRequired,
            onRequiredChanged: (value) => setState(() => attributeIsRequired = value),
          );
        },
      ),
    );
  }

  Widget _buildDialog({
    required String title,
    required IconData icon,
    required TextEditingController nameController,
    required VoidCallback onSave,
    required bool isDark,
    required bool isAdd,
    required String? selectedType,
    required Function(String?) onTypeChanged,
    required List<TextEditingController> optionControllers,
    required Function() onOptionAdded,
    required Function(int) onOptionRemoved,
    required int? selectedCategoryId,
    required Function(int?) onCategoryChanged,
    required bool attributeIsRequired,
    required Function(bool) onRequiredChanged,
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
                _buildTextField('اسم الخاصية (العربية)', Icons.text_fields, nameController, isDark),
                SizedBox(height: 16.h),
                Text('نوع الخاصية', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                )),
                SizedBox(height: 8.h),
                _buildTypeDropdown(isDark, selectedType: selectedType, onChanged: onTypeChanged),
                SizedBox(height: 16.h),
                
                // حقل "مطلوبة"
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Checkbox(
                      value: attributeIsRequired,
                      onChanged: (value) => onRequiredChanged(value ?? false),
                    ),
                    Text('مطلوبة', style: TextStyle(
                      fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark),
                    )),
                  ],
                ),
                SizedBox(height: 16.h),
                
                if (selectedType == 'options') ...[
                  Text('خيارات الخاصية', style: TextStyle(
                    fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  )),
                  SizedBox(height: 8.h),
                  _buildOptionsSection(optionControllers, onOptionAdded: onOptionAdded, onOptionRemoved: onOptionRemoved, isDark: isDark),
                  SizedBox(height: 16.h),
                ],
                Text('ربط بالتصنيف الرئيسي', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                )),
                SizedBox(height: 8.h),
                _buildCategoryDropdown(isDark, selectedCategoryId: selectedCategoryId, onChanged: onCategoryChanged),
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

  Widget _buildTypeDropdown(bool isDark, {required String? selectedType, required Function(String?) onChanged}) {
    final types = [
      {'value': 'number', 'label': 'رقمية'},
      {'value': 'text', 'label': 'نصية'},
      {'value': 'boolean', 'label': 'نعم/لا'},
      {'value': 'options', 'label': 'خيارات متعددة'},
    ];
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.divider(isDark))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedType,
            isExpanded: true,
            hint: Text('اختر نوع الخاصية', style: TextStyle(
              fontSize: 14.sp, 
              fontFamily: AppTextStyles.tajawal,
              color: AppColors.textSecondary(isDark),
            )),
            icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
            items: [
              ...types.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Text(type['label']!, style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDark),
                  )));
              }).toList(),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(
    List<TextEditingController> controllers, {
    required VoidCallback onOptionAdded,
    required Function(int) onOptionRemoved,
    required bool isDark,
  }) {
    return Column(
      children: [
        ...controllers.asMap().entries.map((entry) {
          int idx = entry.key;
          TextEditingController c = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: TextField(
                    textDirection: TextDirection.rtl,
                    controller: c,
                    decoration: InputDecoration(
                      hintText: 'إدخال قيمة الخيار ${idx + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                      filled: true,
                      fillColor: AppColors.card(isDark),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: AppColors.error),
                  onPressed: () => onOptionRemoved(idx),
                ),
              ],
            ),
          );
        }).toList(),
        ElevatedButton.icon(
          icon: Icon(Icons.add, size: 16.r),
          label: Text('إضافة خيار جديد'),
          onPressed: onOptionAdded,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool isDark, {required int? selectedCategoryId, required Function(int?) onChanged}) {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      
      int? selectedValue = selectedCategoryId;
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
              hint: Text('اختياري (لربط الخاصية بتصنيف)', style: TextStyle(
                fontSize: 14.sp, 
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('عام (لجميع التصنيفات)', style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  ))),
                ...controller.categoriesList.map((category) {
                  final arTr = category.translations.firstWhere(
                    (t) => t.language == 'ar',
                    orElse: () =>  categoryTras.Translation(
                      id:0, categoryId:0, language:'ar', name:'', description:''
                    )
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
              onChanged: onChanged,
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
                  Text('هل أنت متأكد من حذف هذه الخاصية؟', style: TextStyle(
                    fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDark)),
                  ),
                  Text('سيتم حذف جميع البيانات المرتبطة بها!', style: TextStyle(
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
                        onPressed: controller.isSaving.value ? null : () {
                          controller.deleteAttribute(id);
                          Get.back();
                          _applyFilter();
                        },
                        child: controller.isSaving.value
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
            ),
          ),
        ),
      ),
    );
  }
  
  void _showLinkDialog(int attributeId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    int? linkCategoryId;
    bool isRequired = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Center(
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
                        Icon(Icons.link, size:24.r, color: AppColors.primary),
                        SizedBox(width:10.w),
                        Text('ربط الخاصية بتصنيف', style: TextStyle(
                          fontSize:15.sp, fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700, color: AppColors.primary,
                        )),
                      ]),
                      SizedBox(height:16.h),

                      // Dropdown الربط
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.card(isDark),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.divider(isDark))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: linkCategoryId,
                              isExpanded: true,
                              hint: Text('اختر التصنيف الرئيسي', style: TextStyle(
                                fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDark),
                              )),
                              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
                              items: controller.categoriesList.map((category) {
                                final arTr = category.translations.firstWhere(
                                  (t) => t.language == 'ar',
                                  orElse: () => categoryTras.Translation(
                                    id:0, categoryId:0, language:'ar', name:'', description:''
                                  )
                                );
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(arTr.name, style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    color: AppColors.textPrimary(isDark),
                                  )),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => linkCategoryId = value);
                              },
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height:16.h),

                      // Checkbox المطلوبة
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Checkbox(
                            value: isRequired,
                            onChanged: (value) => setState(() {
                              isRequired = value ?? false;
                            }),
                          ),
                          Text('مطلوبة في التصنيف', style: TextStyle(
                            fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textPrimary(isDark),
                          )),
                        ],
                      ),

                      SizedBox(height:24.h),

                      // أزرار الإلغاء والربط
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
                          Obx(() {
                            final saving = controller.isSaving.value;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              onPressed: saving
                                ? null
                                : () {
                                    if (linkCategoryId == null) {
                                      Get.snackbar('تحذير', 'الرجاء اختيار تصنيف',
                                        backgroundColor: Colors.orange, colorText: Colors.white);
                                      return;
                                    }
                                    controller.attachAttribute(
                                      attributeId: attributeId,
                                      categoryId: linkCategoryId!,
                                      isRequired: isRequired,
                                    );
                                    Get.back();
                                  },
                              child: saving
                                ? CircularProgressIndicator(color: Colors.white, strokeWidth:2.r)
                                : Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.link, size:20.r),
                                    SizedBox(width:8.w),
                                    Text('ربط', style: TextStyle(
                                      fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                                      fontWeight: FontWeight.bold,
                                    )),
                                  ]),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _applyFilter() async {
    setState(() {
      _isFilterLoading = true;
    });
    
    try {
      await controller.fetchAttributes(
        lang: _lang,
        categoryId: _selectedFilterCategoryId,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
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
    });
    _applyFilter();
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
              Text('إدارة الخصائص', style: TextStyle(
                fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
              )),
              ElevatedButton.icon(
                icon: Icon(Icons.add, size:18.r),
                label: Text('إضافة خاصية', style: TextStyle(
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
                      hintText: 'ابحث عن خاصية...',
                      hintStyle: TextStyle(
                        fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark)),
                      prefixIcon: Icon(Icons.search, size:22.r),
                      border: InputBorder.none,
                      isDense: true,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 18.r),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                _applyFilter();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  )),
                  SizedBox(width:12.w),
                  Container(
                    height:36.h,
                    padding: EdgeInsets.symmetric(horizontal:12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filter,
                        icon: Icon(Icons.arrow_drop_down, size:20.r),
                        style: TextStyle(
                          fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                          color: AppColors.primary),
                        items: <String>['الكل','الأكثر استخداماً','الأحدث'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => _filter = newValue!),
                      ),
                    ),
                  ),
                  SizedBox(width:8.w),
                  ElevatedButton(
                    onPressed: _applyFilter,
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
            // فلترة حسب التصنيف الرئيسي
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
                    SizedBox(width:8.w),
                    ElevatedButton(
                      onPressed: _isFilterLoading ? null : _applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal:16.w, vertical:8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                      child: _isFilterLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
                        : Text('فلترة', style: TextStyle(
                            fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                          )),
                    ),
                    SizedBox(width:8.w),
                    ElevatedButton(
                      onPressed: _isFilterLoading ? null : _clearFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        padding: EdgeInsets.symmetric(horizontal:16.w, vertical:8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                      child: Text('إلغاء', style: TextStyle(
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
                      _buildHeaderCell("اسم الخاصية", 2),
                      _buildHeaderCell("نوع الخاصية", 1),
                      _buildHeaderCell("مطلوبة", 1),
                      _buildHeaderCell("الخيارات", 2),
                      _buildHeaderCell("التصنيفات المربوطة", 2),
                      _buildHeaderCell("الإجراءات", 1),
                    ]),
                  )),
                  Obx(() {
                    if (controller.isLoadingAttributes.value) {
                      return SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth:3.r)),
                      );
                    }
                    if (controller.attributesList.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.tune, size:64.r, color: AppColors.textSecondary(isDark)),
                          SizedBox(height:16.h),
                          Text('لا توجد خصائص', style: TextStyle(
                            fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )),
                        ]),
                      ));
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAttributeRow(
                          controller.attributesList[index], 
                          index, 
                          isDark,
                          index % 2 == 0 ? rowColor1 : rowColor2
                        ),
                        childCount: controller.attributesList.length,
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
          controller.fetchAttributes(lang: lang);
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

  Widget _buildAttributeRow(Attribute attribute, int index, bool isDark, Color color) {
    final typeLabels = {
      'number': 'رقمية',
      'text': 'نصية',
      'boolean': 'نعم/لا',
      'options': 'خيارات متعددة',
    };
    
    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(attribute.id.toString(), 1),
        _buildCell(attribute.name, 2, fontWeight: FontWeight.w500),
        _buildCell(typeLabels[attribute.type] ?? attribute.type, 1, fontWeight: FontWeight.w500),
        _buildCell(attribute.required ? "نعم" : "لا", 1),
        Expanded(
          flex: 2,
          child: attribute.type == 'options'
            ? _buildOptionsDropdown(attribute.options, isDark)
            : Center(child: Text('-', style: TextStyle(
                fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark)),
              )),
        ),
        Expanded(
          flex: 2,
          child: _buildLinkedCategories(attribute.categories, isDark),
        ),
        Expanded(flex:1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: Icon(Icons.edit, size:18.r, color: AppColors.primary),
            onPressed: () => _showEditDialog(attribute),
          ),
          SizedBox(width:8.w),
          IconButton(
            icon: Icon(Icons.link, size:18.r, color: AppColors.info),
            onPressed: () => _showLinkDialog(attribute.id),
          ),
          SizedBox(width:8.w),
          IconButton(
            icon: Icon(Icons.delete, size:18.r, color: AppColors.error),
            onPressed: () => _showDeleteDialog(attribute.id),
          ),
        ])),
      ]),
    );
  }

  Widget _buildOptionsDropdown(List<AttributeOption> options, bool isDark) {
    return DropdownButton<String>(
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, size: 18.r),
      hint: Text('عرض الخيارات', style: TextStyle(
        fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
        color: AppColors.textSecondary(isDark)),
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.value, style: TextStyle(
            fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
            color: AppColors.textPrimary(isDark)),
          ),
        );
      }).toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildLinkedCategories(List<CategoryRef> categories, bool isDark) {
    if (categories.isEmpty) {
      return Center(
        child: Text('عام لجميع التصنيفات', 
          style: TextStyle(
            fontSize:12.sp, 
            fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      );
    }

    return Tooltip(
      message: categories.map((c) => c.name).join(', '),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < categories.length; i++)
              if (i < 2)
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Chip(
                    label: Text(
                      categories[i].name,
                      style: TextStyle(
                        fontSize:11.sp,
                        fontFamily: AppTextStyles.tajawal,
                      ),
                    ),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),
            if (categories.length > 2)
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: Chip(
                  label: Text(
                    '+${categories.length - 2}',
                    style: TextStyle(
                      fontSize:11.sp,
                      fontFamily: AppTextStyles.tajawal,
                    ),
                  ),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                ),
              ),
          ],
        ),
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