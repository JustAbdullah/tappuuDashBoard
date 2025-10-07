// lib/views/FontManagementViewDeskTop.dart
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/FontController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../core/data/model/FontModel.dart';
import '../../core/data/model/FontSizeModel.dart';
import '../../core/data/model/FontWeightModel.dart';

class FontManagementViewDeskTop extends StatefulWidget {
  const FontManagementViewDeskTop({Key? key}) : super(key: key);

  @override
  _FontManagementViewDeskTopState createState() => _FontManagementViewDeskTopState();
}

class _FontManagementViewDeskTopState extends State<FontManagementViewDeskTop> {
  final FontController controller = Get.put(FontController());
  final TextEditingController _fontNameController = TextEditingController();
  final TextEditingController _sizeNameController = TextEditingController();
  final TextEditingController _sizeValueController = TextEditingController();
  final TextEditingController _sizeDescController = TextEditingController();
  final TextEditingController _weightNameController = TextEditingController();
  final TextEditingController _weightValueController = TextEditingController();

  int _selectedTab = 0; // 0: أحجام، 1: خطوط، 2: أوزان

  // بيانات الملف المختار محليًا (لـ UI)
  String? _pickedFileName;
  int? _pickedFileSize; // bytes

  @override
  void initState() {
    super.initState();
    controller.initializeFontData();
  }

  @override
  void dispose() {
    _fontNameController.dispose();
    _sizeNameController.dispose();
    _sizeValueController.dispose();
    _sizeDescController.dispose();
    _weightNameController.dispose();
    _weightValueController.dispose();
    super.dispose();
  }

  // ------------------ File picking (.ttf) ------------------
  // نستخدم FilePicker هنا لالتقاط ملفات الخطوط (.ttf)
  Future<void> _pickTtfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes == null) {
          Get.snackbar('خطأ', 'تعذر قراءة الملف. حاول مرة أخرى.',
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        // خزّن البايت في الكنترولر (الكنترولر يستعملها للرفع)
        controller.fontFileBytes.value = Uint8List.fromList(bytes);
        // امسح أي روابط سابقة
        controller.uploadedFontPath.value = '';
        controller.uploadedFontUrl.value = '';

        setState(() {
          _pickedFileName = file.name;
          _pickedFileSize = file.size;
        });
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في اختيار الملف: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _removePickedFile() {
    controller.fontFileBytes.value = null;
    controller.uploadedFontPath.value = '';
    controller.uploadedFontUrl.value = '';
    setState(() {
      _pickedFileName = null;
      _pickedFileSize = null;
    });
  }

  // ------------------ Dialog helpers ------------------

  void _showAddFontDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _fontNameController.clear();
    Get.dialog(_buildFontDialog(isDark: isDark, isEdit: false));
  }

  void _showEditFontDialog(FontModel font) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _fontNameController.text = font.familyName;
    Get.dialog(_buildFontDialog(isDark: isDark, isEdit: true, font: font));
  }

  void _showAddSizeDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _sizeNameController.clear();
    _sizeValueController.clear();
    _sizeDescController.clear();
    Get.dialog(_buildSizeDialog(isDark: isDark, isEdit: false));
  }

  void _showEditSizeDialog(FontSizeModel size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _sizeNameController.text = size.sizeName;
    _sizeValueController.text = size.sizeValue.toString();
    _sizeDescController.text = size.description ?? '';
    Get.dialog(_buildSizeDialog(isDark: isDark, isEdit: true, size: size));
  }

  void _showAddWeightDialog(FontModel font) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _weightNameController.clear();
    _weightValueController.clear();
    _removePickedFile();
    Get.dialog(_buildWeightDialog(isDark: isDark, isEdit: false, font: font));
  }

  void _showEditWeightDialog(FontWeightModel weight, FontModel font) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _weightNameController.text = weight.weightName;
    _weightValueController.text = weight.weightValue.toString();
    _removePickedFile();
    Get.dialog(_buildWeightDialog(isDark: isDark, isEdit: true, font: font, weight: weight));
  }

  // ------------------ Build Dialogs ------------------

  Widget _buildFontDialog({required bool isDark, bool isEdit = false, FontModel? font}) {
    return Center(
      child: Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.symmetric(horizontal: 120.w, vertical: 80.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520.w, minWidth: 420.w),
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(textDirection: TextDirection.rtl, children: [
                  Icon(Icons.font_download, size: 22.r, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Text(
                    isEdit ? 'تعديل الخط' : 'إضافة خط جديد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ]),
                SizedBox(height: 16.h),
                _buildTextField('اسم عائلة الخط', Icons.text_fields, _fontNameController, isDark),
                SizedBox(height: 18.h),
                _buildFontActionButtons(isDark, isEdit, font),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeDialog({required bool isDark, bool isEdit = false, FontSizeModel? size}) {
    return Center(
      child: Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.symmetric(horizontal: 120.w, vertical: 80.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520.w, minWidth: 420.w),
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(textDirection: TextDirection.rtl, children: [
                  Icon(Icons.format_size, size: 22.r, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Text(
                    isEdit ? 'تعديل حجم الخط' : 'إضافة حجم جديد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ]),
                SizedBox(height: 14.h),
                _buildTextField('اسم الحجم (مثال: medium)', Icons.title, _sizeNameController, isDark),
                SizedBox(height: 12.h),
                _buildTextField('قيمة الحجم (رقم)', Icons.format_size, _sizeValueController, isDark, isNumber: true),
                SizedBox(height: 12.h),
                _buildTextField('وصف الحجم (اختياري)', Icons.description, _sizeDescController, isDark, maxLines: 3),
                SizedBox(height: 16.h),
                _buildSizeActionButtons(isDark, isEdit, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightDialog({required bool isDark, bool isEdit = false, required FontModel font, FontWeightModel? weight}) {
    return Center(
      child: Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.symmetric(horizontal: 120.w, vertical: 80.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640.w, minWidth: 480.w),
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(textDirection: TextDirection.rtl, children: [
                    Icon(Icons.format_bold, size: 22.r, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Text(
                      isEdit ? 'تعديل وزن الخط' : 'إضافة وزن جديد',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ]),
                  SizedBox(height: 12.h),
                  Text(
                    'العائلة: ${font.familyName}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildTextField('اسم الوزن', Icons.text_fields, _weightNameController, isDark),
                  SizedBox(height: 12.h),
                  _buildTextField('قيمة الوزن (100-900)', Icons.format_bold, _weightValueController, isDark, isNumber: true),
                  SizedBox(height: 12.h),
                  Text('ملف الخط (.ttf)', style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  )),
                  SizedBox(height: 8.h),
                  _buildFileUploadSection(isDark),
                  SizedBox(height: 16.h),
                  _buildWeightActionButtons(isDark, isEdit, font, weight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ Sub-widgets ------------------

  Widget _buildFileUploadSection(bool isDark) {
    return Obx(() => Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.fontFileBytes.value != null || _pickedFileName != null)
            Row(
              children: [
                Icon(Icons.font_download, size: 28.r, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pickedFileName ?? 'ملف خط (مختار)',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _pickedFileSize != null ? '${(_pickedFileSize! / 1024).toStringAsFixed(1)} KB' : '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _removePickedFile,
                  tooltip: 'إزالة الملف',
                ),
              ],
            ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.upload_file, size: 16.r),
                label: Text('اختر ملف (.ttf)', style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                onPressed: _pickTtfFile,
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildTextField(String label, IconData icon,
      TextEditingController textController, bool isDark,
      {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: textController,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: false) : TextInputType.text,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 15.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDark),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontFamily: AppTextStyles.tajawal,
          color: AppColors.textSecondary(isDark),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppColors.card(isDark),
        prefixIcon: Icon(icon, size: 20.r),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      ),
    );
  }

  Widget _buildFontActionButtons(bool isDark, bool isEdit, FontModel? font) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(isDark)))),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          onPressed: controller.isSaving.value ? null : () async {
            if (_fontNameController.text.isEmpty) {
              Get.snackbar('تحذير', 'الرجاء إدخال اسم عائلة الخط', backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }

            bool success = false;
            if (isEdit && font != null) {
              success = await controller.updateFont(fontId: font.id, familyName: _fontNameController.text, isActive: font.isActive);
            } else {
              success = await controller.createFont(familyName: _fontNameController.text, isActive: false);
            }

            if (success) {
              Get.back();
              await controller.fetchAllFonts();
              await controller.fetchActiveFont();
            }
          },
          child: controller.isSaving.value
              ? SizedBox(width: 18.r, height: 18.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
              : Row(
                  children: [
                    Icon(isEdit ? Icons.save : Icons.add, size: 16.r),
                    SizedBox(width: 8.w),
                    Text(isEdit ? 'حفظ' : 'إضافة', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
        )),
      ],
    );
  }

  Widget _buildSizeActionButtons(bool isDark, bool isEdit, FontSizeModel? size) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(isDark)))),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          onPressed: controller.isSaving.value ? null : () async {
            if (_sizeNameController.text.isEmpty || _sizeValueController.text.isEmpty) {
              Get.snackbar('تحذير', 'الرجاء إدخال جميع الحقول المطلوبة', backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }
            final sizeValue = double.tryParse(_sizeValueController.text);
            if (sizeValue == null) {
              Get.snackbar('تحذير', 'قيمة الحجم يجب أن تكون رقمية', backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }

            bool success = false;
            if (isEdit && size != null) {
              success = await controller.updateFontSize(sizeId: size.id, sizeName: _sizeNameController.text, sizeValue: sizeValue, description: _sizeDescController.text.isEmpty ? null : _sizeDescController.text, isActive: size.isActive);
            } else {
              success = await controller.createFontSize(sizeName: _sizeNameController.text, sizeValue: sizeValue, description: _sizeDescController.text.isEmpty ? null : _sizeDescController.text);
            }

            if (success) {
              Get.back();
              await controller.fetchActiveSizes();
            }
          },
          child: controller.isSaving.value
              ? SizedBox(width: 18.r, height: 18.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
              : Row(
                  children: [
                    Icon(isEdit ? Icons.save : Icons.add, size: 16.r),
                    SizedBox(width: 8.w),
                    Text(isEdit ? 'حفظ' : 'إضافة', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
        )),
      ],
    );
  }

  Widget _buildWeightActionButtons(bool isDark, bool isEdit, FontModel font, FontWeightModel? weight) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(isDark)))),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          onPressed: controller.isSaving.value ? null : () async {
            if (_weightNameController.text.isEmpty || _weightValueController.text.isEmpty) {
              Get.snackbar('تحذير', 'الرجاء إدخال جميع الحقول المطلوبة', backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }

            final weightValue = int.tryParse(_weightValueController.text);
            if (weightValue == null || weightValue < 100 || weightValue > 900) {
              Get.snackbar('تحذير', 'قيمة الوزن يجب أن تكون رقمية بين 100 و 900', backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }

            // مسار الأصل (عند التعديل)
            String assetPath = weight?.assetPath ?? '';

            // رفع الملف إن وُجد
            if (controller.fontFileBytes.value != null) {
              try {
                final uploaded = await controller.uploadFontFileToServer();
                assetPath = uploaded;
              } catch (e) {
                Get.snackbar('خطأ', 'فشل رفع ملف الخط: $e', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }
            } else {
              if (!isEdit) {
                Get.snackbar('تحذير', 'الرجاء اختيار ملف الخط', backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }
            }

            bool success = false;
            if (isEdit && weight != null) {
              success = await controller.updateFontWeight(fontId: font.id, weightId: weight.id, weightValue: weightValue, weightName: _weightNameController.text, assetPath: assetPath);
            } else {
              success = await controller.addFontWeight(fontId: font.id, weightValue: weightValue, weightName: _weightNameController.text, assetPath: assetPath);
            }

            if (success) {
              Get.back();
              await controller.fetchAllFonts();
              await controller.fetchActiveFont();
            }
          },
          child: controller.isSaving.value
              ? SizedBox(width: 18.r, height: 18.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
              : Row(
                  children: [
                    Icon(isEdit ? Icons.save : Icons.add, size: 16.r),
                    SizedBox(width: 8.w),
                    Text(isEdit ? 'حفظ' : 'إضافة', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
        )),
      ],
    );
  }

  Widget _buildTabButton(int index, String text, IconData icon, bool isDark) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.card(isDark),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.r, color: selected ? AppColors.onPrimary : AppColors.textPrimary(isDark)),
              SizedBox(width: 8.w),
              Text(text, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: selected ? AppColors.onPrimary : AppColors.textPrimary(isDark), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ Cards (compact) ------------------

  Widget _buildFontCard(FontModel font, bool isDark) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: AppColors.card(isDark),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(font.familyName,
                    style: TextStyle(fontSize: 15.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark))),
              ),
              PopupMenuButton<int>(
                padding: EdgeInsets.zero,
                onSelected: (v) async {
                  if (v == 0) _showEditFontDialog(font);
                  if (v == 1) _confirmDeleteFont(font);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('تعديل')])),
                  PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.delete, size: 16), SizedBox(width: 8), Text('حذف')])),
                ],
              ),
            ]),
            SizedBox(height: 8.h),
            Row(children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: font.isActive ? Colors.green : AppColors.surface(isDark), borderRadius: BorderRadius.circular(8.r)),
                child: Text(font.isActive ? 'نشط' : 'غير نشط', style: TextStyle(fontSize: 12.sp, color: font.isActive ? Colors.white : AppColors.textSecondary(isDark))),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: AppColors.surface(isDark), borderRadius: BorderRadius.circular(8.r)),
                child: Text('${font.weights.length} أوزان', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(isDark))),
              ),
              Spacer(),
              if (!font.isActive)
                TextButton(
                  onPressed: () async {
                    final ok = await controller.setActiveFont(font.id);
                    if (ok) {
                      Get.snackbar('تم', 'تم تعيين الخط كنشط', backgroundColor: Colors.green, colorText: Colors.white);
                      await controller.fetchAllFonts();
                      await controller.fetchActiveFont();
                    }
                  },
                  child: Text('تعيين كنشط', style: TextStyle(fontSize: 13.sp)),
                )
              else
                Text('مفعل', style: TextStyle(fontSize: 13.sp, color: Colors.green)),
            ]),
            SizedBox(height: 8.h),
            Row(children: [
              ElevatedButton(
                onPressed: () => _showAddWeightDialog(font),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1), foregroundColor: AppColors.primary, padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                child: Text('إضافة وزن', style: TextStyle(fontSize: 13.sp)),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () async {
                  // فتح قائمة الأوزان في حوار صغير
                  final weights = font.weights;
                  if (weights.isEmpty) {
                    Get.snackbar('تنبيه', 'لا توجد أوزان لعرضها', backgroundColor: Colors.orange, colorText: Colors.white);
                    return;
                  }
                  Get.dialog(AlertDialog(
                    title: Text('أوزان ${font.familyName}', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                    content: SizedBox(
                      width: 400.w,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (ctx, idx) {
                          final w = weights[idx];
                          return ListTile(
                            title: Text(w.weightName, style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                            subtitle: Text('القيمة: ${w.weightValue}', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(icon: Icon(Icons.edit, size: 18), onPressed: () {
                                Get.back();
                                _showEditWeightDialog(w, font);
                              }),
                              IconButton(icon: Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () {
                                Get.back();
                                _confirmDeleteWeight(font, w);
                              }),
                            ]),
                          );
                        },
                        separatorBuilder: (_, __) => Divider(),
                        itemCount: weights.length,
                      ),
                    ),
                    actions: [TextButton(onPressed: () => Get.back(), child: Text('إغلاق'))],
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                child: Text('عرض الأوزان', style: TextStyle(fontSize: 13.sp)),
              )
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeCard(FontSizeModel size, bool isDark) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: AppColors.card(isDark),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(size.sizeName, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, fontFamily: AppTextStyles.tajawal))),
              IconButton(icon: Icon(Icons.edit, size: 18), onPressed: () => _showEditSizeDialog(size)),
            ]),
            SizedBox(height: 6.h),
            Text('قيمة: ${size.sizeValue}', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(isDark), fontFamily: AppTextStyles.tajawal)),
            if (size.description != null && size.description!.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(size.description!, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(isDark), fontFamily: AppTextStyles.tajawal), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            
              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDeleteSize(size)),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard(FontWeightModel weight, FontModel font, bool isDark) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: AppColors.card(isDark),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(weight.weightName, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, fontFamily: AppTextStyles.tajawal))),
              PopupMenuButton<int>(
                onSelected: (v) {
                  if (v == 0) _showEditWeightDialog(weight, font);
                  if (v == 1) _confirmDeleteWeight(font, weight);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 0, child: Text('تعديل')),
                  PopupMenuItem(value: 1, child: Text('حذف')),
                ],
              )
            ]),
            SizedBox(height: 6.h),
            Text('القيمة: ${weight.weightValue}', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(isDark))),
            SizedBox(height: 6.h),
            Text('المسار: ${weight.assetPath}', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(isDark)), maxLines: 2, overflow: TextOverflow.ellipsis),
            Spacer(),
            Row(children: [
              ElevatedButton(
                onPressed: () {
                  Get.dialog(AlertDialog(
                    title: Text('معاينة', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                    content: Text('هذا نص تجريبي لوزن "${weight.weightName}"', style: controller.getTextStyle(sizeName: 'medium', weightValue: weight.weightValue)),
                    actions: [TextButton(onPressed: () => Get.back(), child: Text('إغلاق'))],
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1), foregroundColor: AppColors.primary, padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                child: Text('معاينة', style: TextStyle(fontSize: 13.sp)),
              ),
            ])
          ],
        ),
      ),
    );
  }

  // ------------------ Content builder ------------------

  Widget _buildContent(bool isDark) {
    return LayoutBuilder(builder: (context, constraints) {
      // حساب العواميد حسب العرض
      final width = constraints.maxWidth;
      int crossAxisCount;
      if (width > 1500) crossAxisCount = 4;
      else if (width > 1100) crossAxisCount = 3;
      else if (width > 800) crossAxisCount = 2;
      else crossAxisCount = 1;

      switch (_selectedTab) {
        case 0: // أحجام الخطوط
          return Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.r));
            }
            if (controller.activeSizes.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.format_size_outlined, size: 64.r, color: AppColors.textSecondary(isDark)),
                SizedBox(height: 12.h),
                Text('لا توجد أحجام خطوط مضافة', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary(isDark))),
                SizedBox(height: 6.h),
                Text('انقر على زر "إضافة حجم" لبدء إضافة الأحجام', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(isDark))),
              ]));
            }

            return GridView.builder(
              padding: EdgeInsets.all(8.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 2.2, // بطاقات أقصر
              ),
              itemCount: controller.activeSizes.length,
              itemBuilder: (context, index) {
                final size = controller.activeSizes[index];
                return _buildSizeCard(size, isDark);
              },
            );
          });

        case 1: // عائلات الخطوط
          return Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.r));
            }
            if (controller.allFonts.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.font_download_outlined, size: 64.r, color: AppColors.textSecondary(isDark)),
                SizedBox(height: 12.h),
                Text('لا توجد خطوط مضافة', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary(isDark))),
                SizedBox(height: 6.h),
                Text('انقر على زر "إضافة خط" لبدء إضافة الخطوط', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(isDark))),
              ]));
            }

            return GridView.builder(
              padding: EdgeInsets.all(8.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 2.5, // بطاقات أقصر و أعرض قليلاً
              ),
              itemCount: controller.allFonts.length,
              itemBuilder: (context, index) {
                final font = controller.allFonts[index];
                return _buildFontCard(font, isDark);
              },
            );
          });

        case 2: // أوزان الخطوط
          return Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.r));
            }

            final allWeights = <Map<String, dynamic>>[];
            for (final font in controller.allFonts) {
              for (final weight in font.weights) {
                allWeights.add({'weight': weight, 'font': font});
              }
            }

            if (allWeights.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.format_bold_outlined, size: 64.r, color: AppColors.textSecondary(isDark)),
                SizedBox(height: 12.h),
                Text('لا توجد أوزان خطوط مضافة', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary(isDark))),
                SizedBox(height: 6.h),
                Text('انقر على "إضافة وزن" في بطاقة الخط لبدء إضافة الأوزان', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(isDark)), textAlign: TextAlign.center),
              ]));
            }

            return GridView.builder(
              padding: EdgeInsets.all(8.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 2.4,
              ),
              itemCount: allWeights.length,
              itemBuilder: (context, index) {
                final weightData = allWeights[index];
                final weight = weightData['weight'] as FontWeightModel;
                final font = weightData['font'] as FontModel;
                return _buildWeightCard(weight, font, isDark);
              },
            );
          });

        default:
          return Center(child: Text('اختر قسمًا لعرضه', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary(isDark))));
      }
    });
  }

  // ------------------ Delete confirmations ------------------

  void _confirmDeleteFont(FontModel font) {
    if (font.isActive) {
      Get.snackbar('تنبيه', 'لا يمكنك حذف خط مفعل. قم بتعيين خط آخر نشط أولاً.', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    Get.defaultDialog(
      title: 'تأكيد الحذف',
      middleText: 'هل أنت متأكد من حذف عائلة الخط "${font.familyName}"؟ سيتم حذف جميع الأوزان المرتبطة بها.',
      textCancel: 'إلغاء',
      textConfirm: 'حذف',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        final ok = await controller.deleteFont(font.id);
        if (ok) {
          Get.snackbar('تم', 'تم حذف الخط', backgroundColor: Colors.green, colorText: Colors.white);
          await controller.fetchAllFonts();
          await controller.fetchActiveFont();
        }
      },
    );
  }

  void _confirmDeleteSize(FontSizeModel size) {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      middleText: 'هل أنت متأكد من حذف الحجم "${size.sizeName}"؟',
      textCancel: 'إلغاء',
      textConfirm: 'حذف',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        final ok = await controller.deleteFontSize(size.id);
        if (ok) {
          Get.snackbar('تم', 'تم حذف الحجم', backgroundColor: Colors.green, colorText: Colors.white);
          await controller.fetchActiveSizes();
        }
      },
    );
  }

  void _confirmDeleteWeight(FontModel font, FontWeightModel weight) {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      middleText: 'هل أنت متأكد من حذف الوزن "${weight.weightName}" من العائلة "${font.familyName}"؟',
      textCancel: 'إلغاء',
      textConfirm: 'حذف',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        final ok = await controller.deleteFontWeight(fontId: font.id, weightId: weight.id);
        if (ok) {
          Get.snackbar('تم', 'تم حذف الوزن', backgroundColor: Colors.green, colorText: Colors.white);
          await controller.fetchAllFonts();
          await controller.fetchActiveFont();
        }
      },
    );
  }

  // ------------------ Build ------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          AdminSidebarDeskTop(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('إدارة الخطوط والأحجام',
                          style: TextStyle(fontSize: 20.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark))),
                      Row(children: [
                        if (_selectedTab == 0)
                          ElevatedButton.icon(
                            icon: Icon(Icons.format_size, size: 16.r),
                            label: Text('إضافة حجم', style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                            onPressed: _showAddSizeDialog,
                          ),
                        if (_selectedTab == 1)
                          ElevatedButton.icon(
                            icon: Icon(Icons.font_download, size: 16.r),
                            label: Text('إضافة خط', style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                            onPressed: _showAddFontDialog,
                          ),
                      ]),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(10.r)),
                    child: Row(children: [
                      _buildTabButton(0, 'أحجام الخطوط', Icons.format_size, isDark),
                      SizedBox(width: 8.w),
                      _buildTabButton(1, 'عائلات الخطوط', Icons.font_download, isDark),
                      SizedBox(width: 8.w),
                      _buildTabButton(2, 'أوزان الخطوط', Icons.format_bold, isDark),
                    ]),
                  ),
                  SizedBox(height: 18.h),
                  Expanded(child: _buildContent(isDark)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
