import 'dart:convert'; // اختياري

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

  String _lang = 'ar';
  int? _selectedFilterCategoryId;
  bool _isFilterLoading = false;

  // Snackbar موحّد للنجاح
  void _showSuccess(String title, String message) {
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green, colorText: Colors.white,
      margin: const EdgeInsets.all(12), borderRadius: 10,
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
          return _buildDialog(
            title: 'إضافة خاصية جديدة',
            icon: Icons.tune,
            nameController: nameController,
            onSave: () async {
              if (nameController.text.trim().isEmpty) {
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
                options = optionControllers
                    .map((c) => c.text.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();
                if (options.isEmpty) {
                  Get.snackbar('تحذير', 'الرجاء إدخال خيار واحد على الأقل',
                      backgroundColor: Colors.orange, colorText: Colors.white);
                  return;
                }
              }

              await controller.createAttribute(
                nameAr: nameController.text.trim(),
                valueType: selectedType!,
                isShared: selectedCategoryId == null,
                optionsAr: selectedType == 'options' ? options : null,
                categoryId: selectedCategoryId,
                attributeIsRequired: attributeIsRequired,
              );

              Get.back();
              _applyFilter();
              Future.microtask(() => _showSuccess('تمت الإضافة', 'تمت إضافة الخاصية بنجاح'));
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
            onOptionAdded: () =>
                setState(() => optionControllers.add(TextEditingController())),
            onOptionRemoved: (index) =>
                setState(() => optionControllers.removeAt(index)),
            selectedCategoryId: selectedCategoryId,
            onCategoryChanged: (newId) => setState(() => selectedCategoryId = newId),
            attributeIsRequired: attributeIsRequired,
            onRequiredChanged: (value) =>
                setState(() => attributeIsRequired = value),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showEditDialog(Attribute attribute) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nameController = TextEditingController(text: attribute.name);
    String? selectedType = attribute.type;
    int? selectedCategoryId;

    final List<TextEditingController> optionControllers = [];
    final List<int?> optionIds = []; // يوازي optionControllers
    bool attributeIsRequired = attribute.required;

    bool sendOptions = false; // لا نرسل الخيارات إلا إذا تغيّرت

    if (attribute.type == 'options') {
      for (var option in attribute.options) {
        optionControllers.add(TextEditingController(text: option.value));
        optionIds.add(option.id);
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
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('تحذير', 'الرجاء إدخال اسم الخاصية',
                    backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }

              List<Map<String, dynamic>>? optionsWithIds;
              if (selectedType == 'options') {
                optionsWithIds = [];
                for (int i = 0; i < optionControllers.length; i++) {
                  final text = optionControllers[i].text.trim();
                  final id = optionIds.length > i ? optionIds[i] : null;

                  if (text.isNotEmpty) {
                    optionsWithIds.add({
                      if (id != null) 'id': id,
                      'value_ar': text,
                      'value_en': text,
                      'display_order': i,
                    });
                  } else {
                    // لو خيار أصبح فارغًا اعتبره تغيير
                    sendOptions = true;
                  }
                }
              }

              await controller.updateAttribute(
                id: attribute.id,
                nameAr: nameController.text.trim(),
                valueType: selectedType!,
                attributeIsRequired: attributeIsRequired,
                optionsWithIds: optionsWithIds,
                sendOptions: sendOptions,
              );

              Get.back();
              _applyFilter();
              Future.microtask(() => _showSuccess('تم الحفظ', 'تم تحديث الخاصية بنجاح'));
            },
            isDark: isDark,
            isAdd: false,
            selectedType: selectedType,
            onTypeChanged: (newValue) {
              setState(() {
                selectedType = newValue;
                if (newValue == 'options' && optionControllers.isEmpty) {
                  optionControllers.add(TextEditingController());
                  optionIds.add(null);
                }
                sendOptions = true;
              });
            },
            optionControllers: optionControllers,
            onOptionAdded: () {
              setState(() {
                optionControllers.add(TextEditingController());
                optionIds.add(null); // جديد بلا id
                sendOptions = true;
              });
            },
            onOptionRemoved: (index) {
              setState(() {
                optionControllers.removeAt(index);
                optionIds.removeAt(index);
                sendOptions = true;
              });
            },
            selectedCategoryId: selectedCategoryId,
            onCategoryChanged: (newId) => setState(() => selectedCategoryId = newId),
            attributeIsRequired: attributeIsRequired,
            onRequiredChanged: (value) =>
                setState(() => attributeIsRequired = value),
            onAnyOptionChanged: () => setState(() => sendOptions = true),
          );
        },
      ),
      barrierDismissible: false,
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
    VoidCallback? onAnyOptionChanged,
  }) {
    final dialogScrollCtrl = ScrollController();
    final optionsScrollCtrl = ScrollController();
    final maxH = MediaQuery.of(context).size.height * 0.85;

    return Center(
      child: Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 80.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560.w, minWidth: 420.w, maxHeight: maxH),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Scrollbar(
              controller: dialogScrollCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: dialogScrollCtrl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(textDirection: TextDirection.rtl, children: [
                      Icon(icon, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text(title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(isDark),
                          )),
                    ]),
                    SizedBox(height: 24.h),

                    _buildTextField('اسم الخاصية (العربية)', Icons.text_fields, nameController, isDark),
                    SizedBox(height: 16.h),

                    Text('نوع الخاصية',
                        style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                    SizedBox(height: 8.h),
                    _buildTypeDropdown(isDark, selectedType: selectedType, onChanged: onTypeChanged),
                    SizedBox(height: 16.h),

                    Row(textDirection: TextDirection.rtl, children: [
                      Checkbox(value: attributeIsRequired, onChanged: (v) => onRequiredChanged(v ?? false)),
                      Text('مطلوبة',
                          style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                    ]),
                    SizedBox(height: 16.h),

                    if (selectedType == 'options') ...[
                      Text('خيارات الخاصية',
                          style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                      SizedBox(height: 8.h),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 360.h),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.card(isDark),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.divider(isDark)),
                          ),
                          child: Scrollbar(
                            controller: optionsScrollCtrl,
                            thumbVisibility: true,
                            child: ListView.separated(
                              controller: optionsScrollCtrl,
                              padding: EdgeInsets.all(12.r),
                              itemCount: optionControllers.length,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              separatorBuilder: (_, __) => SizedBox(height: 8.h),
                              itemBuilder: (context, idx) {
                                final c = optionControllers[idx];
                                return Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        textDirection: TextDirection.rtl,
                                        controller: c,
                                        onChanged: (_) => onAnyOptionChanged?.call(),
                                        decoration: InputDecoration(
                                          hintText: 'قيمة الخيار ${idx + 1}',
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                                          filled: true,
                                          fillColor: AppColors.card(isDark),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle, color: AppColors.error),
                                      onPressed: () => onOptionRemoved(idx),
                                      tooltip: 'حذف الخيار',
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.add, size: 16.r),
                          label: Text('إضافة خيار جديد'),
                          onPressed: onOptionAdded,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    Text('ربط بالتصنيف الرئيسي',
                        style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                    SizedBox(height: 8.h),
                    _buildCategoryDropdown(isDark, selectedCategoryId: selectedCategoryId, onChanged: onCategoryChanged),

                    SizedBox(height: 24.h),
                    _buildActionButtons(onSave, isDark, isAdd),
                  ],
                ),
              ),
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
      style: TextStyle(fontSize: 16.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)),
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
        border: Border.all(color: AppColors.divider(isDark)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedType,
            isExpanded: true,
            hint: Text('اختر نوع الخاصية',
                style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
            icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
            items: types
                .map((type) => DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(type['label']!, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                    ))
                .toList(),
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
          border: Border.all(color: AppColors.divider(isDark)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: selectedValue,
              isExpanded: true,
              hint: Text('اختياري (لربط الخاصية بتصنيف)',
                  style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('عام (لجميع التصنيفات)',
                      style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                ),
                ...controller.categoriesList.map((category) {
                  final arTr = category.translations.firstWhere(
                    (t) => t.language == 'ar',
                    orElse: () => categoryTras.Translation(id: 0, categoryId: 0, language: 'ar', name: '', description: ''),
                  );
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(arTr.name, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                  );
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
          child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
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
                      Text(isAdd ? 'إضافة' : 'حفظ التعديلات',
                          style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold)),
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
                    Icon(Icons.warning_amber_rounded, size: 24.r, color: AppColors.error),
                    SizedBox(width: 10.w),
                    Text('تأكيد الحذف',
                        style: TextStyle(fontSize: 15.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.error)),
                  ]),
                  SizedBox(height: 16.h),
                  Text('هل أنت متأكد من حذف هذه الخاصية؟',
                      style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                  Text('سيتم حذف جميع البيانات المرتبطة بها!',
                      style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.error.withOpacity(0.8))),
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('إلغاء', style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                      ),
                      Obx(() => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                            onPressed: controller.isSaving.value
                                ? null
                                : () async {
                                    await controller.deleteAttribute(id);
                                    Get.back();
                                    _applyFilter();
                                    Future.microtask(() => _showSuccess('تم الحذف', 'تم حذف الخاصية بنجاح'));
                                  },
                            child: controller.isSaving.value
                                ? SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                                : Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.delete, size: 20.r),
                                    SizedBox(width: 8.w),
                                    Text('حذف', style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold)),
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
      barrierDismissible: false,
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
                constraints: BoxConstraints(maxWidth: 500.w, minWidth: 300.w, maxHeight: 420.h),
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
                            style: TextStyle(fontSize: 15.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: linkCategoryId,
                              isExpanded: true,
                              hint: Text('اختر التصنيف الرئيسي',
                                  style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary(isDark)),
                              items: controller.categoriesList.map((category) {
                                final arTr = category.translations.firstWhere(
                                  (t) => t.language == 'ar',
                                  orElse: () => categoryTras.Translation(id: 0, categoryId: 0, language: 'ar', name: '', description: ''),
                                );
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(arTr.name,
                                      style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => linkCategoryId = value),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Row(textDirection: TextDirection.rtl, children: [
                        Checkbox(value: isRequired, onChanged: (v) => setState(() => isRequired = v ?? false)),
                        Text('مطلوبة في التصنيف',
                            style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
                      ]),

                      SizedBox(height: 24.h),

                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('إلغاء', style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                          ),
                          Obx(() {
                            final saving = controller.isSaving.value;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
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
                                      Future.microtask(() => _showSuccess('تم الربط', 'تم ربط الخاصية بالتصنيف'));
                                    },
                              child: saving
                                  ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
                                  : Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.link, size: 20.r),
                                      SizedBox(width: 8.w),
                                      Text('ربط', style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold)),
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
      barrierDismissible: false,
    );
  }

  Future<void> _applyFilter() async {
    setState(() => _isFilterLoading = true);
    try {
      await controller.fetchAttributes(lang: _lang, categoryId: _selectedFilterCategoryId);
    } finally {
      setState(() => _isFilterLoading = false);
    }
  }

  void _clearFilter() {
    setState(() => _selectedFilterCategoryId = null);
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
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('إدارة الخصائص',
                        style: TextStyle(fontSize: 19.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark))),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add, size: 18.r),
                      label: Text('إضافة خاصية', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: _showAddDialog,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.end, children: [
                  _buildLangButton('ar', 'العربية', true),
                  SizedBox(width: 10.w),
                  _buildLangButton('en', 'English', false),
                ]),
                SizedBox(height: 16.h),

                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600.w, minWidth: 400.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.divider(isDark)),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Text('فلترة حسب التصنيف الرئيسي:',
                              style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(() {
                              if (controller.isLoadingCategories.value) {
                                return Center(child: CircularProgressIndicator());
                              }
                              return DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedFilterCategoryId,
                                  isExpanded: true,
                                  hint: Text('جميع التصنيفات',
                                      style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                                  icon: Icon(Icons.arrow_drop_down, size: 20.r),
                                  style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.primary),
                                  items: [
                                    DropdownMenuItem<int>(value: null, child: Text('جميع التصنيفات', style: TextStyle(fontSize: 14.sp))),
                                    ...controller.categoriesList.map((category) {
                                      final arTr = category.translations.firstWhere(
                                        (t) => t.language == 'ar',
                                        orElse: () => categoryTras.Translation(id: 0, categoryId: 0, language: 'ar', name: '', description: ''),
                                      );
                                      return DropdownMenuItem<int>(value: category.id, child: Text(arTr.name, style: TextStyle(fontSize: 14.sp)));
                                    }).toList(),
                                  ],
                                  onChanged: (int? newValue) => setState(() => _selectedFilterCategoryId = newValue),
                                ),
                              );
                            }),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton(
                            onPressed: _isFilterLoading ? null : _applyFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: _isFilterLoading
                                ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                                : Text('فلترة', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal)),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton(
                            onPressed: _isFilterLoading ? null : _clearFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.onSecondary,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
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
                            ),
                          ),
                          Obx(() {
                            if (controller.isLoadingAttributes.value) {
                              return SliverFillRemaining(
                                child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.r)),
                              );
                            }
                            if (controller.attributesList.isEmpty) {
                              return SliverFillRemaining(
                                child: Center(
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.tune, size: 64.r, color: AppColors.textSecondary(isDark)),
                                    SizedBox(height: 16.h),
                                    Text('لا توجد خصائص',
                                        style: TextStyle(fontSize: 16.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                                  ]),
                                ),
                              );
                            }
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildAttributeRow(
                                  controller.attributesList[index],
                                  index,
                                  isDark,
                                  index % 2 == 0 ? rowColor1 : rowColor2,
                                ),
                                childCount: controller.attributesList.length,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
            bottomLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
            topRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
            bottomRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
          ),
        ),
      ),
      child: Text(text, style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal)),
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark)),
      ),
    );
  }

  Widget _buildAttributeRow(Attribute attribute, int index, bool isDark, Color color) {
    final typeLabels = {'number': 'رقمية', 'text': 'نصية', 'boolean': 'نعم/لا', 'options': 'خيارات متعددة'};
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
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
              : Center(child: Text('-', style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)))),
        ),
        Expanded(flex: 2, child: _buildLinkedCategories(attribute.categories, isDark)),
        Expanded(
          flex: 1,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: Icon(Icons.edit, size: 18.r, color: AppColors.primary), onPressed: () => _showEditDialog(attribute)),
            SizedBox(width: 8.w),
            IconButton(icon: Icon(Icons.link, size: 18.r, color: AppColors.info), onPressed: () => _showLinkDialog(attribute.id)),
            SizedBox(width: 8.w),
            IconButton(icon: Icon(Icons.delete, size: 18.r, color: AppColors.error), onPressed: () => _showDeleteDialog(attribute.id)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildOptionsDropdown(List<AttributeOption> options, bool isDark) {
    return DropdownButton<String>(
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, size: 18.r),
      hint: Text('عرض الخيارات',
          style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
      items: options
          .map((option) => DropdownMenuItem<String>(
                value: option.value,
                child: Text(option.value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
              ))
          .toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildLinkedCategories(List<CategoryRef> categories, bool isDark) {
    if (categories.isEmpty) {
      return Center(
        child: Text('عام لجميع التصنيفات',
            style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
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
                    label: Text(categories[i].name, style: TextStyle(fontSize: 11.sp, fontFamily: AppTextStyles.tajawal)),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),
            if (categories.length > 2)
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: Chip(
                  label: Text('+${categories.length - 2}', style: TextStyle(fontSize: 11.sp, fontFamily: AppTextStyles.tajawal)),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(String text, int flex, {Color? color, FontWeight fontWeight = FontWeight.normal, int maxLines = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, fontWeight: fontWeight, color: color),
      ),
    );
  }
}
