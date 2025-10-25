import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/AttributeController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/Attribute.dart';
import 'package:tappuu_dashboard/core/data/model/category.dart' as categoryTras;

import '../AdminSidebar.dart';

class AttributesViewMobile extends StatefulWidget {
  const AttributesViewMobile({Key? key}) : super(key: key);

  @override
  _AttributesViewMobileState createState() => _AttributesViewMobileState();
}

class _AttributesViewMobileState extends State<AttributesViewMobile> {
  final AttributeController controller = Get.put(AttributeController());
  final TextEditingController _searchController = TextEditingController();

  String _lang = 'ar';
  int? _selectedFilterCategoryId;
  bool _isFilterLoading = false;

  // Snackbar موحّد للنجاح
  void _showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

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
    final List<TextEditingController> optionControllers = [];
    bool attributeIsRequired = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
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
                        Icon(Icons.tune, size: 24.r, color: AppColors.primary),
                        SizedBox(width: 10.w),
                        Text('إضافة خاصية جديدة',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(isDark),
                            )),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField('اسم الخاصية (العربية)', Icons.text_fields, nameController, isDark),
                    SizedBox(height: 12.h),

                    Text('نوع الخاصية',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                    SizedBox(height: 8.h),
                    _buildTypeDropdown(isDark, selectedType: selectedType, onChanged: (newValue) {
                      setState(() {
                        selectedType = newValue;
                        if (newValue == 'options' && optionControllers.isEmpty) {
                          optionControllers.add(TextEditingController());
                        }
                      });
                    }),
                    SizedBox(height: 12.h),

                    // مطلوبة (على مستوى الخاصية)
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Checkbox(
                          value: attributeIsRequired,
                          onChanged: (v) => setState(() => attributeIsRequired = v ?? false),
                        ),
                        Text('مطلوبة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textPrimary(isDark),
                            )),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    if (selectedType == 'options') ...[
                      Text('خيارات الخاصية',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )),
                      SizedBox(height: 8.h),
                      ...optionControllers.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final c = entry.value;
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
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                                    filled: true,
                                    fillColor: AppColors.card(isDark),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: AppColors.error),
                                onPressed: () => setState(() => optionControllers.removeAt(idx)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add, size: 16.r),
                        label: Text('إضافة خيار جديد'),
                        onPressed: () => setState(() => optionControllers.add(TextEditingController())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    Text('ربط بالتصنيف الرئيسي',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                    SizedBox(height: 8.h),
                    _buildCategoryDropdown(isDark,
                        selectedCategoryId: selectedCategoryId,
                        onChanged: (newId) => setState(() => selectedCategoryId = newId)),
                    SizedBox(height: 20.h),

                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('إلغاء',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDark),
                              )),
                        ),
                        Obx(() => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () async {
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
                                      Future.microtask(
                                          () => _showSuccess('تمت الإضافة', 'تمت إضافة الخاصية بنجاح'));
                                    },
                              child: controller.isSaving.value
                                  ? SizedBox(
                                      width: 20.r,
                                      height: 20.r,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                                  : Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.add, size: 18.r),
                                      SizedBox(width: 6.w),
                                      Text('إضافة',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: AppTextStyles.tajawal,
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
        },
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool isDark) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      style: TextStyle(fontSize: 16.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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
            hint: Text('اختر نوع الخاصية',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                )),
            icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
            items: [
              ...types.map((type) {
                return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label']!,
                        style: TextStyle(
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

  Widget _buildCategoryDropdown(bool isDark, {required int? selectedCategoryId, required Function(int?) onChanged}) {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      int? selectedValue = selectedCategoryId;
      if (selectedValue != null && !controller.categoriesList.any((cat) => cat.id == selectedValue)) {
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
              hint: Text('اختياري (لربط الخاصية بتصنيف)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  )),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
              items: [
                DropdownMenuItem<int>(
                    value: null,
                    child: Text('عام (لجميع التصنيفات)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        ))),
                ...controller.categoriesList.map((category) {
                  final arTr = category.translations.firstWhere((t) => t.language == 'ar',
                      orElse: () =>
                          categoryTras.Translation(id: 0, categoryId: 0, language: 'ar', name: '', description: ''));
                  return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(arTr.name,
                          style: TextStyle(
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

  void _showEditDialog(Attribute attribute) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nameController = TextEditingController(text: attribute.name);
    String? selectedType = attribute.type;
    final List<TextEditingController> optionControllers = [];
    bool attributeIsRequired = attribute.required;

    if (attribute.type == 'options') {
      for (var option in attribute.options) {
        optionControllers.add(TextEditingController(text: option.value));
      }
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
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
                        Icon(Icons.edit, size: 24.r, color: AppColors.primary),
                        SizedBox(width: 10.w),
                        Text('تعديل الخاصية',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(isDark),
                            )),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField('اسم الخاصية (العربية)', Icons.text_fields, nameController, isDark),
                    SizedBox(height: 12.h),

                    Text('نوع الخاصية',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                    SizedBox(height: 8.h),
                    _buildTypeDropdown(isDark, selectedType: selectedType, onChanged: (newValue) {
                      setState(() {
                        selectedType = newValue;
                        if (newValue == 'options' && optionControllers.isEmpty) {
                          optionControllers.add(TextEditingController());
                        }
                      });
                    }),
                    SizedBox(height: 12.h),

                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Checkbox(
                          value: attributeIsRequired,
                          onChanged: (v) => setState(() => attributeIsRequired = v ?? false),
                        ),
                        Text('مطلوبة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textPrimary(isDark),
                            )),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    if (selectedType == 'options') ...[
                      Text('خيارات الخاصية',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )),
                      SizedBox(height: 8.h),
                      ...optionControllers.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final c = entry.value;
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
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                                    filled: true,
                                    fillColor: AppColors.card(isDark),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: AppColors.error),
                                onPressed: () => setState(() => optionControllers.removeAt(idx)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add, size: 16.r),
                        label: Text('إضافة خيار جديد'),
                        onPressed: () => setState(() => optionControllers.add(TextEditingController())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text('إلغاء',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDark),
                              )),
                        ),
                        Obx(() => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () async {
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
                                        attributeIsRequired: attributeIsRequired,
                                      );

                                      Get.back();
                                      _applyFilter();
                                      Future.microtask(
                                          () => _showSuccess('تم الحفظ', 'تم تحديث الخاصية بنجاح'));
                                    },
                              child: controller.isSaving.value
                                  ? SizedBox(
                                      width: 20.r,
                                      height: 20.r,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                                  : Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.save, size: 18.r),
                                      SizedBox(width: 6.w),
                                      Text('حفظ',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: AppTextStyles.tajawal,
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
        },
      ),
    );
  }

  void _showDeleteDialog(int id) {
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
                  Icon(Icons.warning_amber_rounded, size: 24.r, color: AppColors.error),
                  SizedBox(width: 10.w),
                  Text('تأكيد الحذف',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      )),
                ],
              ),
              SizedBox(height: 16.h),
              Text('هل أنت متأكد من حذف هذه الخاصية؟',
                  style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
              SizedBox(height: 8.h),
              Text('سيتم حذف جميع البيانات المرتبطة بها!',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.error.withOpacity(0.8),
                  )),
              SizedBox(height: 24.h),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('إلغاء',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                  ),
                  Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        onPressed: controller.isSaving.value
                            ? null
                            : () async {
                                await controller.deleteAttribute(id);
                                Get.back();
                                _applyFilter();
                                Future.microtask(
                                    () => _showSuccess('تم الحذف', 'تم حذف الخاصية بنجاح'));
                              },
                        child: controller.isSaving.value
                            ? SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                            : Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.delete, size: 18.r),
                                SizedBox(width: 6.w),
                                Text('حذف',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: AppTextStyles.tajawal,
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

  void _showLinkDialog(int attributeId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int? linkCategoryId;
    bool isRequired = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: AppColors.surface(isDark),
            insetPadding: EdgeInsets.all(16.r),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(textDirection: TextDirection.rtl, children: [
                    Icon(Icons.link, size: 24.r, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Text('ربط الخاصية بتصنيف',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        )),
                  ]),
                  SizedBox(height: 16.h),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.divider(isDark))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Obx(() {
                        if (controller.isLoadingCategories.value) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: linkCategoryId,
                            isExpanded: true,
                            hint: Text('اختر التصنيف الرئيسي',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDark),
                                )),
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
                            items: controller.categoriesList.map((category) {
                              final arTr = category.translations.firstWhere((t) => t.language == 'ar',
                                  orElse: () => categoryTras.Translation(
                                      id: 0, categoryId: 0, language: 'ar', name: '', description: ''));
                              return DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(arTr.name,
                                    style: TextStyle(
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
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Checkbox(
                        value: isRequired,
                        onChanged: (value) => setState(() => isRequired = value ?? false),
                      ),
                      Text('مطلوبة في التصنيف',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textPrimary(isDark),
                          )),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('إلغاء',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                      ),
                      Obx(() {
                        final saving = controller.isSaving.value;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          onPressed: saving
                              ? null
                              : () async {
                                  if (linkCategoryId == null) {
                                    Get.snackbar('تحذير', 'الرجاء اختيار تصنيف',
                                        backgroundColor: Colors.orange, colorText: Colors.white);
                                    return;
                                  }
                                  await controller.attachAttribute(
                                    attributeId: attributeId,
                                    categoryId: linkCategoryId!,
                                    isRequired: isRequired,
                                  );
                                  Get.back();
                                  Future.microtask(
                                      () => _showSuccess('تم الربط', 'تم ربط الخاصية بالتصنيف'));
                                },
                          child: saving
                              ? SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                              : Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.link, size: 18.r),
                                  SizedBox(width: 6.w),
                                  Text('ربط',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: AppTextStyles.tajawal,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeLabels = {
      'number': 'رقمية',
      'text': 'نصية',
      'boolean': 'نعم/لا',
      'options': 'خيارات متعددة',
    };

    return Scaffold(
      drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context),
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.appBar(isDark),
        elevation: 2,
        title: Text('إدارة الخصائص',
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w800,
              color: AppColors.onPrimary,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.onPrimary),
            onPressed: _showAddDialog,
            tooltip: 'إضافة خاصية',
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
              children: [
                Expanded(child: _buildLangButton('ar', 'العربية', true)),
                SizedBox(width: 10.w),
                Expanded(child: _buildLangButton('en', 'English', false)),
              ],
            ),
            SizedBox(height: 16.h),

            // Search Field
            Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: TextField(
                textDirection: TextDirection.rtl,
                controller: _searchController,
                style: TextStyle(
                    fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark)),
                decoration: InputDecoration(
                  hintText: 'ابحث عن خاصية...',
                  hintStyle: TextStyle(
                      fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)),
                  prefixIcon: Icon(Icons.search, size: 22.r),
                  border: InputBorder.none,
                ),
                onChanged: (value) => _applyFilter(),
              ),
            ),
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
                  Text('فلترة حسب التصنيف الرئيسي:',
                      style: TextStyle(
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
                            hint: Text('جميع التصنيفات',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDark),
                                )),
                            icon: Icon(Icons.arrow_drop_down, size: 20.r),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.primary,
                            ),
                            items: [
                              DropdownMenuItem<int>(
                                  value: null, child: Text('جميع التصنيفات', style: TextStyle(fontSize: 14.sp))),
                              ...controller.categoriesList.map((category) {
                                final arTr = category.translations.firstWhere((t) => t.language == 'ar',
                                    orElse: () => categoryTras.Translation(
                                        id: 0, categoryId: 0, language: 'ar', name: '', description: ''));
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                    child: _isFilterLoading
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                        : Text('تطبيق الفلترة',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppTextStyles.tajawal,
                            )),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Attributes List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingAttributes.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.r),
                  );
                }

                if (controller.attributesList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune, size: 64.r, color: AppColors.textSecondary(isDark)),
                        SizedBox(height: 16.h),
                        Text('لا توجد خصائص',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.attributesList.length,
                  itemBuilder: (context, index) {
                    final attribute = controller.attributesList[index];

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
                                  child: Icon(Icons.tune, color: AppColors.primary),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(attribute.name,
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

                            _buildDetailRow('المعرف', attribute.id.toString()),
                            SizedBox(height: 8.h),
                            _buildDetailRow('نوع الخاصية', typeLabels[attribute.type] ?? attribute.type),
                            SizedBox(height: 8.h),
                            _buildDetailRow('مطلوبة', attribute.required ? 'نعم' : 'لا'),
                            SizedBox(height: 8.h),

                            if (attribute.type == 'options') _buildOptionsSection(attribute.options),
                            SizedBox(height: 8.h),
                            _buildLinkedCategories(attribute.categories),
                            SizedBox(height: 16.h),

                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(Icons.edit, 'تعديل', AppColors.primary,
                                    () => _showEditDialog(attribute)),
                                _buildActionButton(Icons.link, 'ربط', AppColors.info,
                                    () => _showLinkDialog(attribute.id)),
                                _buildActionButton(Icons.delete, 'حذف', AppColors.error,
                                    () => _showDeleteDialog(attribute.id)),
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
        Text('$label: ',
            style: TextStyle(
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

  Widget _buildOptionsSection(List<AttributeOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Text('الخيارات:',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w600,
            )),
        SizedBox(height: 4.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          textDirection: TextDirection.rtl,
          children: options
              .map((option) => Chip(
                    label: Text(option.value),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLinkedCategories(List<CategoryRef> categories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (categories.isEmpty) {
      return Text('عام لجميع التصنيفات',
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Text('التصنيفات المربوطة:',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w600,
            )),
        SizedBox(height: 4.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          textDirection: TextDirection.rtl,
          children: categories.take(3).map((c) {
            return Chip(
              label: Text(c.name),
              backgroundColor: AppColors.secondary.withOpacity(0.1),
            );
          }).toList(),
        ),
        if (categories.length > 3)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text('+${categories.length - 3} تصنيفات أخرى',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                )),
          )
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18.r, color: color),
      label: Text(label,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
            color: color,
          )),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        side: BorderSide(color: color),
      ),
    );
  }

  Widget _buildLangButton(String lang, String text, bool isLeft) {
    final isSelected = _lang == lang;
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _lang = lang;
          controller.fetchAttributes(lang: lang);
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
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: AppTextStyles.tajawal,
        ),
      ),
    );
  }
}
