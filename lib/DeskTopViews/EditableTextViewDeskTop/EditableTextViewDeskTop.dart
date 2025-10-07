import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/EditableTextModel.dart';

import '../../controllers/EditableTextController.dart';

class EditableTextViewDeskTop extends StatefulWidget {
  const EditableTextViewDeskTop({Key? key}) : super(key: key);

  @override
  _EditableTextViewDeskTopState createState() => _EditableTextViewDeskTopState();
}

class _EditableTextViewDeskTopState extends State<EditableTextViewDeskTop> {
  final EditableTextController controller = Get.put(EditableTextController());
  final TextEditingController _keyNameController = TextEditingController();
  final TextEditingController _textContentController = TextEditingController();
  final TextEditingController _fontSizeController = TextEditingController();
  
  final TextEditingController _editKeyNameController = TextEditingController();
  final TextEditingController _editTextContentController = TextEditingController();
  final TextEditingController _editFontSizeController = TextEditingController();
  
  Color _selectedColor = Colors.black;
  Color _editSelectedColor = Colors.black;
  


  @override
  void initState() {
    super.initState();
    controller.fetchAll();
  }


  void _showAddDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    controller.removeFontFile();
    _keyNameController.clear();
    _textContentController.clear();
    _fontSizeController.clear();
    _selectedColor = Colors.black;

    Get.dialog(
      _buildDialog(
        title: 'إضافة نص جديد',
        icon: Icons.text_fields,
        keyNameController: _keyNameController,
        textContentController: _textContentController,
        fontSizeController: _fontSizeController,
        selectedColor: _selectedColor,
        onColorChanged: (color) {
          setState(() {
            _selectedColor = color;
          });
        },
        onSave: () async {
          if (_keyNameController.text.isEmpty || _textContentController.text.isEmpty) {
            Get.snackbar('تحذير', 'الرجاء إدخال المفتاح والنص',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          final fontSize = int.tryParse(_fontSizeController.text) ?? 16;
          
          await controller.createEditableText(
            keyName: _keyNameController.text,
            textContent: _textContentController.text,
            fontSize: fontSize,
            color: _colorToHex(_selectedColor),
          );
          Get.back();
        },
        isDark: isDark,
        isEdit: false,
      ),
      barrierDismissible: false,
    );
  }

  void _showEditDialog(EditableTextModel text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    _editKeyNameController.text = text.keyName;
    _editTextContentController.text = text.textContent;
    _editFontSizeController.text = text.fontSize.toString();
    _editSelectedColor = _hexToColor(text.color);

    Get.dialog(
      _buildDialog(
        title: 'تعديل النص',
        icon: Icons.edit,
        keyNameController: _editKeyNameController,
        textContentController: _editTextContentController,
        fontSizeController: _editFontSizeController,
        selectedColor: _editSelectedColor,
        onColorChanged: (color) {
          setState(() {
            _editSelectedColor = color;
          });
        },
        onSave: () async {
          if (_editKeyNameController.text.isEmpty || _editTextContentController.text.isEmpty) {
            Get.snackbar('تحذير', 'الرجاء إدخال المفتاح والنص',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          final fontSize = int.tryParse(_editFontSizeController.text) ?? 16;
          
          await controller.updateEditableText(
            id: text.id,
            textContent: _editTextContentController.text,
            fontSize: fontSize,
            color: _colorToHex(_editSelectedColor),
          );
          Get.back();
        },
        isDark: isDark,
        isEdit: true,
      ),
      barrierDismissible: false,
    );
  }

  void _showPreviewDialog(EditableTextModel text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600.w,
              minWidth: 400.w,
              minHeight: 400.h,
            ),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.preview, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text('معاينة النص', style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700, 
                        color: AppColors.textPrimary(isDark),
                      )),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  // معاينة النص مع التنسيق
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('المفتاح:', style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                            Text(text.keyName, style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary(isDark),
                            )),
                            SizedBox(height: 16.h),
                            
                            // معاينة باللون الأسود الافتراضي
                            Text('المعاينة باللون الأسود الافتراضي:', style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                            Container(
                              padding: EdgeInsets.all(12.r),
                              margin: EdgeInsets.only(bottom: 16.h),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Obx(() => Text(
                                text.textContent,
                                style: TextStyle(
                                  fontSize: text.fontSize.toDouble(),
                                  color: Colors.black,
                                  fontFamily: text.fontUrl != null && controller.previewedFamily.value.isNotEmpty 
                                      ? controller.previewedFamily.value 
                                      : AppTextStyles.tajawal,
                                ),
                              )),
                            ),
                            
                            // معاينة باللون المختار
                            Text('المعاينة باللون المختار:', style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                            Container(
                              padding: EdgeInsets.all(12.r),
                              margin: EdgeInsets.only(bottom: 16.h),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Obx(() => Text(
                                text.textContent,
                                style: TextStyle(
                                  fontSize: text.fontSize.toDouble(),
                                  color: _hexToColor(text.color),
                                  fontFamily: text.fontUrl != null && controller.previewedFamily.value.isNotEmpty 
                                      ? controller.previewedFamily.value 
                                      : AppTextStyles.tajawal,
                                ),
                              )),
                            ),
                            
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Text('حجم الخط: ${text.fontSize}', style: TextStyle(
                                  fontSize: 12.sp, 
                                  color: AppColors.textSecondary(isDark),
                                )),
                                SizedBox(width: 16.w),
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    color: _hexToColor(text.color),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text('اللون المختار', style: TextStyle(
                                  fontSize: 12.sp, 
                                  color: AppColors.textSecondary(isDark),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  if (text.fontUrl != null && text.fontUrl!.isNotEmpty) ...[
                    Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                      ),
                      onPressed: controller.isPreviewingFont.value ? null : () async {
                        await controller.loadFontForPreview(
                          fontUrl: text.fontUrl!,
                          familyName: 'custom_font_${text.id}',
                        );
                      },
                      child: controller.isPreviewingFont.value
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.r,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.font_download, size: 20.r),
                                SizedBox(width: 8.w),
                                Text('معاينة الخط المخصص', style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                )),
                              ],
                            ),
                    )),
                    SizedBox(height: 16.h),
                  ],
                  
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text('إغلاق', style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.primary,
                      )),
                    ),
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

  Widget _buildDialog({
    required String title,
    required IconData icon,
    required TextEditingController keyNameController,
    required TextEditingController textContentController,
    required TextEditingController fontSizeController,
    required Color selectedColor,
    required ValueChanged<Color> onColorChanged,
    required VoidCallback onSave,
    required bool isDark,
    required bool isEdit,
  }) {
    return Dialog(
      backgroundColor: AppColors.surface(isDark),
      insetPadding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 50.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600.w,
          minWidth: 500.w,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
                  fontSize: 18.sp,
                  fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.w700, 
                  color: AppColors.textPrimary(isDark),
                )),
              ],
            ),
            SizedBox(height: 24.h),
            
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // صف الحقول الأساسية
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: _buildTextField('المفتاح', Icons.vpn_key, keyNameController, isDark),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField('حجم الخط', Icons.format_size, fontSizeController, isDark,
                              keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    
                    _buildTextField('النص', Icons.text_fields, textContentController, isDark, maxLines: 3),
                    SizedBox(height: 16.h),
                    
                    // اختيار اللون ورفع الخط
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('اختر اللون:', style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDark),
                              )),
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: () => _showColorPicker(isDark, onColorChanged, initialColor: selectedColor),
                                child: Container(
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.card(isDark),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Container(
                                        width: 30.w,
                                        height: 30.h,
                                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                                        decoration: BoxDecoration(
                                          color: selectedColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          _colorToHex(selectedColor),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.textPrimary(isDark),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                                        child: Icon(Icons.color_lens, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('رفع ملف الخط:', style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDark),
                              )),
                              SizedBox(height: 8.h),
                              Obx(() => Container(
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: AppColors.card(isDark),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: controller.fontFileBytes.value != null
                                    ? Row(
                                        textDirection: TextDirection.rtl,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                                              child: Text(
                                                controller.pickedFileName ?? 'ملف الخط',
                                                style: TextStyle(fontSize: 12.sp),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: AppColors.error, size: 18.r),
                                            onPressed: controller.removeFontFile,
                                          ),
                                        ],
                                      )
                                    : TextButton.icon(
                                        onPressed: controller.pickFontFile,
                                        icon: Icon(Icons.upload_file, size: 18.r),
                                        label: Text('اختر ملف الخط', style: TextStyle(fontSize: 12.sp)),
                                      ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            _buildActionButtons(onSave, isDark, !isEdit),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(bool isDark, ValueChanged<Color> onColorChanged, {Color initialColor = Colors.black}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر اللون', textDirection: TextDirection.rtl),
        content: Container(
          width: 400.w,
          height: 500.h,
          child: AdvancedColorPicker(
            initialColor: initialColor,
            onColorSelected: (color) {
              onColorChanged(color);
              Get.back();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, 
      bool isDark, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: maxLines == 1 ? 16.sp : 14.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontFamily: AppTextStyles.tajawal,
          color: AppColors.textSecondary(isDark)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: AppColors.card(isDark),
        prefixIcon: Icon(icon, size: 22.r),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
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
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.r,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isAdd ? Icons.add : Icons.save, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(isAdd ? 'إضافة' : 'حفظ التعديلات', style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                  )),
                ],
              ),
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
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500.w,
              minWidth: 300.w,
              maxHeight: 300.h,
            ),
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
                      fontSize:15.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    )),
                  ],
                ),
                SizedBox(height:16.h),
                Text('هل أنت متأكد من حذف هذا النص؟', style: TextStyle(
                  fontSize:13.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textPrimary(isDark)),
                ),
                Text('سيتم حذف جميع البيانات المرتبطة به!', style: TextStyle(
                  fontSize:12.sp,
                  fontFamily: AppTextStyles.tajawal,
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
                        fontSize:13.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                      )),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                      onPressed: () {
                        controller.deleteItem(id);
                        Get.back();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete, size:20.r),
                          SizedBox(width:8.w),
                          Text('حذف', style: TextStyle(
                            fontSize:13.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          )),
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
      barrierDismissible: false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor1 = isDark ? AppColors.grey900 : AppColors.grey50;
    final rowColor2 = isDark ? AppColors.grey800 : AppColors.grey100;
    
    return Scaffold(
      body: Row(
        children: [
          AdminSidebarDeskTop(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:24.w, vertical:16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('إدارة النصوص القابلة للتعديل', style: TextStyle(
                        fontSize:19.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      )),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add, size:18.r),
                        label: Text('إضافة نص', style: TextStyle(
                          fontSize:14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w600,
                        )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(vertical:12.h, horizontal:20.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                        onPressed: _showAddDialog,
                      ),
                    ],
                  ),
                  SizedBox(height:24.h),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius:12,
                          offset: Offset(0,4),
                        )]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical:16.h, horizontal:16.w),
                                decoration: BoxDecoration(color: isDark ? AppColors.grey800 : AppColors.grey200),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    _buildHeaderCell("المعرف", 1),
                                    _buildHeaderCell("المفتاح", 2),
                                    _buildHeaderCell("النص", 3),
                                    _buildHeaderCell("حجم الخط", 1),
                                    _buildHeaderCell("اللون", 1),
                                    _buildHeaderCell("تاريخ الإنشاء", 1),
                                    _buildHeaderCell("الإجراءات", 2),
                                  ],
                                ),
                              ),
                            ),
                            Obx(() {
                              if (controller.isLoading.value) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth:3.r,
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
                                        Icon(Icons.text_fields_outlined, size:64.r, color: AppColors.textSecondary(isDark)),
                                        SizedBox(height:16.h),
                                        Text('لا توجد نصوص', style: TextStyle(
                                          fontSize:16.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildTextRow(
                                    controller.items[index], 
                                    index, 
                                    isDark,
                                    index % 2 == 0 ? rowColor1 : rowColor2
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
    return Expanded(
      flex: flex,
      child: Text(
        text, 
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize:13.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w700, 
          color: AppColors.textPrimary(Theme.of(context).brightness == Brightness.dark),
        ),
      ),
    );
  }

  Widget _buildTextRow(EditableTextModel text, int index, bool isDark, Color color) {
    final createdAt = _parseDate(text.createdAt ?? '') ?? DateTime.now().subtract(Duration(days: 1));
    final dateText = _formatDaysAgo(createdAt);
    
    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w),
      color: color,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _buildCell(text.id.toString(), 1),
          _buildCell(text.keyName, 2, fontWeight: FontWeight.w500),
          _buildCell(
            text.textContent.length > 50 
              ? '${text.textContent.substring(0, 50)}...' 
              : text.textContent, 
            3, 
            maxLines: 2
          ),
          _buildCell(text.fontSize.toString(), 1, fontWeight: FontWeight.bold),
          Expanded(
            flex:1,
            child: Center(
              child: Container(
                width:20.w,
                height:20.h,
                decoration: BoxDecoration(
                  color: _hexToColor(text.color),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
          ),
          _buildCell(dateText, 1, color: AppColors.textSecondary(isDark)),
          Expanded(
            flex:2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.preview, size:18.r, color: AppColors.primary),
                  onPressed: () => _showPreviewDialog(text),
                ),
                SizedBox(width:8.w),
                IconButton(
                  icon: Icon(Icons.edit, size:18.r, color: Colors.blue),
                  onPressed: () => _showEditDialog(text),
                ),
                SizedBox(width:8.w),
                IconButton(
                  icon: Icon(Icons.delete, size:18.r, color: AppColors.error),
                  onPressed: () => _showDeleteDialog(text.id),
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
          fontSize:12.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}

// منتقي ألوان متقدم مع إمكانية الاختيار اليدوي
class AdvancedColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const AdvancedColorPicker({Key? key, required this.onColorSelected, this.initialColor = Colors.black}) : super(key: key);

  @override
  _AdvancedColorPickerState createState() => _AdvancedColorPickerState();
}

class _AdvancedColorPickerState extends State<AdvancedColorPicker> {
  late Color _selectedColor;
  final TextEditingController _hexController = TextEditingController();
  final List<Color> _presetColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _hexController.text = _colorToHex(widget.initialColor);
  }

  void _updateColor(Color color) {
    setState(() {
      _selectedColor = color;
      _hexController.text = _colorToHex(color);
    });
    widget.onColorSelected(color);
  }

  void _onHexChanged(String value) {
    if (value.length == 7 && value.startsWith('#')) {
      try {
        final color = _hexToColor(value);
        setState(() {
          _selectedColor = color;
        });
        widget.onColorSelected(color);
      } catch (_) {
        // تجاهل في حالة عدم صحة اللون
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // معاينة اللون المختار
        Container(
          width: double.infinity,
          height: 80.h,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              'معاينة اللون',
              style: TextStyle(
                color: _selectedColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        
        // إدخال hex يدوي
        TextField(
          controller: _hexController,
          onChanged: _onHexChanged,
          decoration: InputDecoration(
            labelText: 'أدخل كود اللون HEX',
            prefixText: '#',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          textDirection: TextDirection.ltr,
        ),
        SizedBox(height: 16.h),
        
        // الألوان المسبقة
        Text('الألوان المسبقة:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: _presetColors.length,
            itemBuilder: (context, index) {
              final color = _presetColors[index];
              return GestureDetector(
                onTap: () => _updateColor(color),
                child: Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color == Colors.white ? Colors.grey : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: _selectedColor.value == color.value
                      ? Icon(Icons.check, 
                          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          size: 16.r)
                      : null,
                ),
              );
            },
          ),
        ),
        
        // منتقي الألوان من Flutter المدمج (اختياري)
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: () async {
            final Color? pickedColor = await showDialog<Color>(
              context: context,
              builder: (context) => Dialog(
                child: ColorPicker(
                  color: _selectedColor,
                  onColorChanged: _updateColor,
                  showLabel: true,
                  pickerColor: _selectedColor,
                ),
              ),
            );
            if (pickedColor != null) {
              _updateColor(pickedColor);
            }
          },
          child: Text('منتقي الألوان المتقدم'),
        ),
      ],
    );
  }
}

// منتقي الألوان الأساسي من Flutter (يمكن استبداله بحزمة خارجية لمزيد من الميزات)
class ColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool showLabel;
  final Color pickerColor;

  const ColorPicker({
    Key? key,
    required this.color,
    required this.onColorChanged,
    required this.showLabel,
    required this.pickerColor,
  }) : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('اختر اللون', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            child: ColorPickerArea(
              color: _currentColor,
              onColorChanged: (color) {
                setState(() {
                  _currentColor = color;
                });
                widget.onColorChanged(color);
              },
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onColorChanged(_currentColor);
                  Navigator.of(context).pop(_currentColor);
                },
                child: Text('موافق'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ColorPickerArea extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerArea({Key? key, required this.color, required this.onColorChanged}) : super(key: key);

  @override
  _ColorPickerAreaState createState() => _ColorPickerAreaState();
}

class _ColorPickerAreaState extends State<ColorPickerArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      height: 200.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: GestureDetector(
        onPanDown: (details) => _selectColor(details),
       // onPanUpdate: (details) => _selectColor(details),
        child: CustomPaint(
          painter: _ColorPickerPainter(
            onColorSelected: (color) {
              widget.onColorChanged(color);
            },
          ),
        ),
      ),
    );
  }

  void _selectColor(DragDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    
    final double x = localPosition.dx.clamp(0, box.size.width);
    final double y = localPosition.dy.clamp(0, box.size.height);
    
    final Color selectedColor = _getColorAtPosition(x, y, box.size);
    widget.onColorChanged(selectedColor);
  }

  Color _getColorAtPosition(double x, double y, Size size) {
    final double hue = (x / size.width) * 360;
    final double saturation = (y / size.height);
    
    return HSLColor.fromAHSL(1.0, hue, saturation, 0.5).toColor();
  }
}

class _ColorPickerPainter extends CustomPainter {
  final ValueChanged<Color> onColorSelected;

  _ColorPickerPainter({required this.onColorSelected});

  @override
  void paint(Canvas canvas, Size size) {
    // رسم تدرج الألوان
    final Rect rect = Offset.zero & size;
    const List<Color> colors = [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red];
    
    final Gradient gradient = LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _formatDaysAgo(DateTime date) {
  final now = DateTime.now();
  final days = now.difference(date).inDays;
  if (days == 0) {
    return 'اليوم';
  } else if (days == 1) {
    return 'منذ يوم';
  } else {
    return 'منذ $days يوم';
  }
}

DateTime? _parseDate(String dateString) {
  try {
    return DateTime.parse(dateString);
  } catch (_) {
    return null;
  }
}

String _colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
}

Color _hexToColor(String hexColor) {
  try {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  } catch (_) {
    return Colors.black;
  }
}