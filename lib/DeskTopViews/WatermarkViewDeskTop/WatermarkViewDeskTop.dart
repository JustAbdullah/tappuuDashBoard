import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';

import 'package:tappuu_dashboard/core/data/model/watermark_model.dart';

import '../../controllers/watermark_controller.dart';

class WatermarkViewDeskTop extends StatefulWidget {
  const WatermarkViewDeskTop({Key? key}) : super(key: key);

  @override
  State<WatermarkViewDeskTop> createState() => _WatermarkViewDeskTopState();
}

class _WatermarkViewDeskTopState extends State<WatermarkViewDeskTop> {
  final WatermarkController controller = Get.put(WatermarkController());

  // حقول النموذج (لنمط النص)
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _fontSizeController = TextEditingController();
  final TextEditingController _fontUrlController = TextEditingController();
  Color _pickedColor = Colors.black;

  // سويتش النمط (صورة/نص)
  bool _isImageMode = false;

  // معاينة صورة العلامة (الحالية أو آخر مرفوعة)
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();

    // راقب أي تغيير في رابط الصورة المرفوعة وفعّل المعاينة والنمط
    controller.uploadedWmImageUrl.listen((url) {
      if (url.isNotEmpty) {
        setState(() {
          _currentImageUrl = url;
          _isImageMode = true;
        });
      }
    });

    controller.fetchWatermark().then((_) => _hydrateFromModel());
  }

  @override
  void dispose() {
    _textController.dispose();
    _fontSizeController.dispose();
    _fontUrlController.dispose();
    super.dispose();
  }

  void _hydrateFromModel() {
    final wm = controller.current.value;
    if (wm == null) {
      _isImageMode = false;
      _currentImageUrl = null;

      _textController.clear();
      _fontSizeController.text = '16';
      _fontUrlController.clear();
      _pickedColor = Colors.black;
    } else {
      _isImageMode     = wm.isImage;
      _currentImageUrl = wm.imageUrl;

      if (!wm.isImage) {
        _textController.text = wm.textContent ?? '';
        _fontSizeController.text = (wm.fontSize ?? 16).toString();
        _fontUrlController.text = wm.fontUrl ?? '';
        _pickedColor = _hexToColor(wm.color ?? '#000000');
      } else {
        _textController.clear();
        _fontSizeController.text = '16';
        _fontUrlController.clear();
        _pickedColor = Colors.black;
      }
      // ستتم مزامنة قيَم السكيل/الشفافية تلقائياً من الكنترولر.fetchWatermark()
    }
    if (mounted) setState(() {});
  }

  void _resetLocalFontSelection() {
    controller.removeFontFile();
  }

  Future<void> _pickColor() async {
    if (_isImageMode) return; // لا حاجة للون في نمط الصورة
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card(_isDark),
        title: Text('اختر اللون', textDirection: TextDirection.rtl, style: TextStyle(fontFamily: AppTextStyles.tajawal)),
        content: SizedBox(
          width: 500.w,
          height: 520.h,
          child: AdvancedColorPicker(
            initialColor: _pickedColor,
            onColorSelected: (c) => setState(() => _pickedColor = c),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إغلاق', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    // نقرأ قيم الـ Rx الحالية لنرسلها مع الحفظ
    final double scale = controller.wmImgScale.value; // 0.08..0.35
    final int opacity  = controller.wmOpacity.value;  // 0..100

    if (_isImageMode) {
      // خذ الرابط من: المحلي الحالي ← الرابط المرفوع في الكنترولر ← رابط السجل الحالي
      final imageUrl = (_currentImageUrl?.isNotEmpty == true)
          ? _currentImageUrl!
          : (controller.uploadedWmImageUrl.value.isNotEmpty
              ? controller.uploadedWmImageUrl.value
              : (controller.current.value?.imageUrl ?? ''));

      if (imageUrl.isEmpty) {
        Get.snackbar('تنبيه', 'يجب رفع وتفعيل صورة العلامة أولاً', backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      final ok = await controller.upsertWatermark(
        isImage: true,
        imageUrl: imageUrl,
        wmImgScaleParam: scale,
        wmOpacityParam: opacity,
      );

      if (ok) {
        await controller.fetchWatermark();
        _hydrateFromModel();
      }
      return;
    }

    // نمط النص
    final int? size = int.tryParse(_fontSizeController.text.trim());
    if (_textController.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'النص مطلوب', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (size == null || size < 8) {
      Get.snackbar('تنبيه', 'حجم الخط غير صالح (>= 8)', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final ok = await controller.upsertWatermark(
      isImage: false,
      textContent: _textController.text.trim(),
      fontSize: size,
      color: _colorToHex(_pickedColor),
      fontUrl: _fontUrlController.text.trim().isNotEmpty ? _fontUrlController.text.trim() : null,
      uploadPickedFontIfAny: true,
      wmImgScaleParam: scale,
      wmOpacityParam: opacity,
    );

    if (ok) {
      await controller.fetchWatermark();
      _hydrateFromModel();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card(_isDark),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8.w),
            Text('تأكيد الحذف', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
          ],
        ),
        content: Text('سيتم حذف إعداد العلامة المائية بالكامل.',
            textDirection: TextDirection.rtl, style: TextStyle(fontFamily: AppTextStyles.tajawal)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await controller.deleteWatermark();
      if (ok) {
        _resetLocalFontSelection();
        _hydrateFromModel();
      }
    }
  }

  // رفع صورة العلامة وتفعيلها مباشرة
  Future<void> _uploadAndActivateWmImage() async {
    try {
      await controller.pickWatermarkImage(); // يملأ wmImageBytes فوراً
      if (controller.wmImageBytes.value == null) return;

      // أظهر المعاينة فوراً
      setState(() {
        _isImageMode = true;
      });

      final url = await controller.uploadWatermarkImageToServer(setAsActive: true);

      // ✅ ضمنّا تفعيل الرابط محلياً وفي الـ Rx
      if (url.isNotEmpty) {
        controller.uploadedWmImageUrl.value = url; // يفعّل الـ listener أعلاه أيضًا
        setState(() {
          _currentImageUrl = url;
          _isImageMode = true;
        });
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل رفع صورة العلامة: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebarDeskTop(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: _buildFormCard()),
                        SizedBox(width: 16.w),
                        Expanded(flex: 2, child: _buildPreviewCard()),
                      ],
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

  Widget _buildHeader() {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('إعدادات العلامة المائية', style: TextStyle(
          fontSize: 19.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary(_isDark),
        )),
        Row(
          children: [
            // سويتش النمط
            Row(
              children: [
                Text('نص', style: TextStyle(fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(_isDark))),
                Switch(
                  value: _isImageMode,
                  onChanged: (v) {
                    setState(() {
                      _isImageMode = v;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Text('صورة', style: TextStyle(fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(_isDark))),
              ],
            ),
            SizedBox(width: 12.w),

            Obx(() => ElevatedButton.icon(
              onPressed: controller.isSaving.value ? null : _save,
              icon: const Icon(Icons.save),
              label: Text('حفظ', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            )),
            SizedBox(width: 10.w),
            Obx(() => ElevatedButton.icon(
              onPressed: controller.current.value == null || controller.isSaving.value ? null : _delete,
              icon: const Icon(Icons.delete),
              label: Text('حذف', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error, foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            )),
          ],
        )
      ],
    );
  }

  Widget _buildFormCard() {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card(_isDark),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        padding: EdgeInsets.all(20.r),
        child: controller.isLoading.value
            ? Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.r))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    _generalSettingsTile(),
                    SizedBox(height: 16.h),
                    if (_isImageMode) ..._imageFormFields() else ..._textFormFields(),
                  ],
                ),
              ),
      );
    });
  }

  /// ✅ إعدادات عامة (تظهر دائماً)
  Widget _generalSettingsTile() {
    return Obx(() {
      final scale = controller.wmImgScale.value; // 0.08..0.35
      final opacity = controller.wmOpacity.value; // 0..100
      return Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.card(_isDark),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text('إعدادات عامة', style: TextStyle(
                  fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(_isDark),
                )),
              ],
            ),
            SizedBox(height: 12.h),

            // Scale
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('حجم/نسبة العلامة (من عرض الصورة): ${((scale)*100).toStringAsFixed(0)}%',
                          style: TextStyle(fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(_isDark))),
                      Slider(
                        value: scale.clamp(0.08, 0.35),
                        onChanged: (v) => controller.wmImgScale.value = double.parse(v.toStringAsFixed(2)),
                        min: 0.08,
                        max: 0.35,
                        divisions: 27, // خطوة 0.01 تقريباً
                        label: '${(scale*100).toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Opacity
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('شفافية العلامة: ${opacity}%',
                          style: TextStyle(fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(_isDark))),
                      Slider(
                        value: opacity.toDouble().clamp(0, 100),
                        onChanged: (v) => controller.wmOpacity.value = v.round().clamp(0, 100),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: '$opacity%',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),
            Text(
              _isImageMode
                  ? 'سيتم تطبيق الحجم والشفافية على صورة العلامة المائية عند إنتاج الصور في السيرفر.'
                  : 'سيتم تطبيق الشفافية على النص (مع حدود/ظل) عند إنتاج الصور في السيرفر.',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(_isDark), fontFamily: AppTextStyles.tajawal),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _imageFormFields() {
    return [
      // عرض رابط الصورة الحالي
      Obx(() {
        final rxUploaded = controller.uploadedWmImageUrl.value;
        final rxModel    = controller.current.value;

        final url = (_currentImageUrl?.isNotEmpty == true)
            ? _currentImageUrl!
            : (rxUploaded.isNotEmpty
                ? rxUploaded
                : (rxModel?.imageUrl ?? ''));

        return Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.surface(_isDark),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.image, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  (url.isNotEmpty) ? url : '— لا يوجد رابط صورة محدد —',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(_isDark)),
                ),
              ),
            ],
          ),
        );
      }),
      SizedBox(height: 16.h),

      // رفع صورة العلامة وتفعيلها
      Obx(() => ElevatedButton.icon(
        onPressed: controller.isUploadingWmImage.value ? null : _uploadAndActivateWmImage,
        icon: controller.isUploadingWmImage.value
            ? SizedBox(width: 18.r, height: 18.r, child: CircularProgressIndicator(strokeWidth: 2.r, color: Colors.white))
            : const Icon(Icons.cloud_upload),
        label: Text('رفع صورة العلامة وتفعيلها', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      )),

      SizedBox(height: 8.h),
      Text(
        'ملاحظة: يتم رفع صورة العلامة إلى السيرفر بدون أي وسم ثم تعيينها كعلامة مائية فعّالة مباشرة. استخدم الإعدادات العامة بالأعلى للتحكم بالحجم والشفافية.',
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(_isDark), fontFamily: AppTextStyles.tajawal),
      ),
    ];
  }

  List<Widget> _textFormFields() {
    return [
      // النص + الحجم
      Row(
        children: [
          Expanded(child: _buildTextField('نص العلامة المائية', Icons.text_fields, _textController, maxLines: 3)),
          SizedBox(width: 12.w),
          SizedBox(
            width: 160.w,
            child: _buildTextField('حجم الخط', Icons.format_size, _fontSizeController,
                keyboardType: TextInputType.number),
          ),
        ],
      ),
      SizedBox(height: 16.h),

      // اللون + رابط الخط
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _colorPickerTile(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildTextField('رابط الخط (اختياري)', Icons.link, _fontUrlController),
          ),
        ],
      ),
      SizedBox(height: 16.h),

      // رفع ملف خط محلي
      _fontUploadTile(),

      SizedBox(height: 8.h),
      Text(
        'ملاحظة: لو اخترت ملف خط، سيتم رفعه وتخزين رابط الملف تلقائيًا عند الحفظ. الشفافية تُطبّق على النص عند المعالجة في السيرفر.',
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(_isDark), fontFamily: AppTextStyles.tajawal),
      ),
    ];
  }

  Widget _buildPreviewCard() {
    return Obx(() {
      final WatermarkModel? wm = controller.current.value;
      final scalePct = (controller.wmImgScale.value * 100).toStringAsFixed(0);
      final opacityPct = controller.wmOpacity.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.card(_isDark),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text('معاينة', style: TextStyle(
                  fontSize: 16.sp, fontWeight: FontWeight.w700, fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textPrimary(_isDark),
                )),
              ],
            ),
            SizedBox(height: 14.h),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: _isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                ),
                child: _isImageMode
                    ? _imagePreviewArea()
                    : _textPreviewArea(wm),
              ),
            ),
            SizedBox(height: 12.h),

            // لمحة سريعة عن الإعدادات العامة
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                Chip(
                  label: Text('الحجم: $scalePct%', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                  avatar: const Icon(Icons.photo_size_select_large, size: 18),
                ),
                Chip(
                  label: Text('الشفافية: $opacityPct%', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                  avatar: const Icon(Icons.opacity, size: 18),
                ),
              ],
            ),

            if (!_isImageMode) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => ElevatedButton.icon(
                      onPressed: ((wm?.fontUrl?.isNotEmpty ?? false) && !controller.isPreviewingFont.value)
                          ? () async {
                              await controller.loadFontForPreview(
                                fontUrl: wm!.fontUrl!,
                                familyName: 'WMFamily_${wm.id ?? 'x'}',
                              );
                            }
                          : null,
                      icon: controller.isPreviewingFont.value
                          ? SizedBox(width: 18.r, height: 18.r, child: CircularProgressIndicator(strokeWidth: 2.r, color: Colors.white))
                          : const Icon(Icons.font_download),
                      label: Text('معاينة الخط المخصص', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    )),
                  ),
                ],
              ),
            ]
          ],
        ),
      );
    });
  }

  /// ✅ معاينة نمط الصورة
  Widget _imagePreviewArea() {
    return Obx(() {
      final bytes = controller.wmImageBytes.value; // Rx
      final rxUploaded = controller.uploadedWmImageUrl.value; // Rx
      final rxModel    = controller.current.value;            // Rx

      if (bytes != null && bytes.isNotEmpty) {
        // عرض فوري للصورة المختارة محلياً
        return LayoutBuilder(
          builder: (_, constraints) => SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: InteractiveViewer(
              child: Image.memory(
                bytes,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      }

      // وإلا اعرض بالرابط (آخر مرفوع/مفعّل)
      final url = (_currentImageUrl?.isNotEmpty == true)
          ? _currentImageUrl!
          : (rxUploaded.isNotEmpty
              ? rxUploaded
              : (rxModel?.imageUrl ?? ''));

      if (url.isEmpty) {
        return Center(
          child: Text(
            '— لا توجد صورة علامة مائية —\nاضغط "رفع صورة العلامة وتفعيلها"',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(_isDark)),
          ),
        );
      }

      return LayoutBuilder(
        builder: (_, constraints) => SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: InteractiveViewer(
              child: Image.network(
                url,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Text('تعذر تحميل الصورة', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _textPreviewArea(WatermarkModel? wm) {
    final previewFontFamily =
        (wm?.fontUrl != null && controller.previewedFamily.value.isNotEmpty)
            ? controller.previewedFamily.value
            : AppTextStyles.tajawal;

    final previewFontSize =
        double.tryParse(_fontSizeController.text.trim()) ??
        (wm?.fontSize?.toDouble() ?? 16.0);
    final previewColor = _pickedColor;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Text('النص:', style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary(_isDark), fontFamily: AppTextStyles.tajawal)),
          SizedBox(height: 6.h),
          Text(
            _textController.text.isEmpty ? '— لا يوجد نص —' : _textController.text,
            style: TextStyle(
              fontSize: previewFontSize,
              fontFamily: previewFontFamily,
              color: previewColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Text('الحجم: ${previewFontSize.toInt()}', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(_isDark))),
              SizedBox(width: 12.w),
              Container(
                width: 18.w, height: 18.w,
                decoration: BoxDecoration(
                  color: previewColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              SizedBox(width: 8.w),
              Text(_colorToHex(previewColor), style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary(_isDark))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: !_isImageMode, // تعطيل حقول النص عند نمط الصورة
      style: TextStyle(
        fontSize: maxLines == 1 ? 16.sp : 14.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(_isDark),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
          color: AppColors.textSecondary(_isDark),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: AppColors.card(_isDark),
        prefixIcon: Icon(icon, size: 20.r),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _colorPickerTile() {
    return IgnorePointer(
      ignoring: _isImageMode, // تعطيل اختيار اللون عند نمط الصورة
      child: Opacity(
        opacity: _isImageMode ? 0.5 : 1,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.card(_isDark),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text('اللون', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(_isDark))),
              SizedBox(height: 8.h),
              InkWell(
                onTap: _pickColor,
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.card(_isDark),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      SizedBox(width: 12.w),
                      Container(
                        width: 28.w, height: 28.w,
                        decoration: BoxDecoration(
                          color: _pickedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(child: Text(_colorToHex(_pickedColor),
                          style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary(_isDark)))),
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
      ),
    );
  }

  Widget _fontUploadTile() {
    return IgnorePointer(
      ignoring: _isImageMode, // تعطيل عند نمط الصورة
      child: Opacity(
        opacity: _isImageMode ? 0.5 : 1,
        child: Obx(() => Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.card(_isDark),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text('رفع ملف خط (اختياري)', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(_isDark))),
              SizedBox(height: 8.h),
              Row(
                children: [
                  if (controller.fontFileBytes.value != null)
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.surface(_isDark),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          controller.pickedFileName ?? 'ملف الخط',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  SizedBox(width: 10.w),
                  ElevatedButton.icon(
                    onPressed: controller.pickFontFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(controller.fontFileBytes.value == null ? 'اختر ملف' : 'تبديل الملف',
                        style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (controller.fontFileBytes.value != null)
                    ElevatedButton.icon(
                      onPressed: controller.removeFontFile,
                      icon: const Icon(Icons.delete_outline),
                      label: Text('إزالة', style: TextStyle(fontFamily: AppTextStyles.tajawal)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                    ),
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }
}

/* =========================
   Helpers + Color Pickers
   ========================= */

extension _EmptyExt on String {
  String? get ifEmpty => isEmpty ? null : this;
}

String _colorToHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
}

Color _hexToColor(String hexColor) {
  try {
    var h = hexColor.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  } catch (_) {
    return Colors.black;
  }
}

/// منتقي ألوان متقدم بسيط (بدون حزم خارجية)
class AdvancedColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;
  const AdvancedColorPicker({Key? key, required this.onColorSelected, this.initialColor = Colors.black}) : super(key: key);

  @override
  State<AdvancedColorPicker> createState() => _AdvancedColorPickerState();
}

class _AdvancedColorPickerState extends State<AdvancedColorPicker> {
  late Color _selectedColor;
  final TextEditingController _hexController = TextEditingController();
  final List<Color> _presetColors = [
    Colors.black, Colors.white, Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan, Colors.teal, Colors.green,
    Colors.lightGreen, Colors.lime, Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _hexController.text = _colorToHex(widget.initialColor);
  }

  void _apply(Color c) {
    setState(() {
      _selectedColor = c;
      _hexController.text = _colorToHex(c);
    });
    widget.onColorSelected(c);
  }

  void _onHexChanged(String v) {
    if (v.startsWith('#') && v.length == 7) {
      try {
        _apply(_hexToColor(v));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // معاينة
        Container(
          width: double.infinity, height: 72.h,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: Text(
              'معاينة اللون',
              style: TextStyle(
                fontFamily: AppTextStyles.tajawal,
                color: _selectedColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // إدخال HEX
        TextField(
          controller: _hexController,
          onChanged: _onHexChanged,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: 'HEX',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          ),
        ),
        SizedBox(height: 12.h),
        // ألوان مسبقة
        Align(
          alignment: Alignment.centerRight,
          child: Text('الألوان المسبقة:', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: AppTextStyles.tajawal)),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 160.h,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, crossAxisSpacing: 8.w, mainAxisSpacing: 8.h,
            ),
            itemCount: _presetColors.length,
            itemBuilder: (_, i) {
              final c = _presetColors[i];
              final selected = c.value == _selectedColor.value;
              return GestureDetector(
                onTap: () => _apply(c),
                child: Container(
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: c == Colors.white ? Colors.grey : Colors.transparent, width: 2),
                  ),
                  child: selected
                      ? Icon(Icons.check, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 16.r)
                      : null,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        // مساحة اختيار لونية بسيطة
        SizedBox(
          width: double.infinity,
          height: 180.h,
          child: _SimpleSpectrum(
            onPick: (c) => _apply(c),
          ),
        ),
      ],
    );
  }
}

/// سبكترم لوني بسيط للاختيار بالسحب/الضغط
class _SimpleSpectrum extends StatefulWidget {
  final ValueChanged<Color> onPick;
  const _SimpleSpectrum({Key? key, required this.onPick}) : super(key: key);

  @override
  State<_SimpleSpectrum> createState() => _SimpleSpectrumState();
}

class _SimpleSpectrumState extends State<_SimpleSpectrum> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => _select(d.localPosition, context),
      onPanUpdate: (d) => _select(d.localPosition, context),
      child: CustomPaint(
        painter: _SpectrumPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  void _select(Offset localPos, BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox;
    final size = box.size;
    final x = localPos.dx.clamp(0, size.width);
    final y = localPos.dy.clamp(0, size.height);
    final hue = (x / size.width) * 360.0;
    final sat = (y / size.height);
    final color = HSLColor.fromAHSL(1.0, hue, sat, 0.5).toColor();
    widget.onPick(color);
  }
}

class _SpectrumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const colors = [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red];
    final paint = Paint()..shader = const LinearGradient(colors: colors).createShader(rect);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
