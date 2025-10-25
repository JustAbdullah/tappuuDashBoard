import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // FontLoader
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../core/data/model/watermark_model.dart';

enum SnackType { success, error, info }

class WatermarkController extends GetxController {
  // غيّر الـ baseUrl حسب بيئتك
  static const String _baseUrl =
      'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  // حالة عامة
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingFont = false.obs;
  final RxBool isPreviewingFont = false.obs;
  final RxBool isUploadingWmImage = false.obs; // رفع صورة العلامة

  // سجل واحد فقط
  Rxn<WatermarkModel> current = Rxn<WatermarkModel>();

  // ---------- ملفات الخط (للنمط النصي) ----------
  final Rx<Uint8List?> fontFileBytes = Rx<Uint8List?>(null);
  String? pickedFileName;
  RxString uploadedFontUrl = ''.obs;  // السيرفر يرجع الرابط
  RxString uploadedFontPath = ''.obs; // أو مسار التخزين لو ترجعونه كذلك

  // ---------- ملف صورة العلامة (لنمط الصورة) ----------
  final Rx<Uint8List?> wmImageBytes = Rx<Uint8List?>(null);
  String? pickedWmImageName;
  RxString uploadedWmImageUrl = ''.obs;

  // ---------- إعدادات العلامة العامة (من الـ DB) ----------
  // بإمكانك ربطها بالـ UI (Sliders) إن رغبت:
  final RxDouble wmImgScale = 0.18.obs; // نسبة من عرض الصورة الأصلية
  final RxInt wmOpacity = 30.obs;       // 0..100 %

  // اسم عائلة الخط المُحمّل للمعاينة
  RxString previewedFamily = ''.obs;

  /* ------------------------- UI Snack Helper ------------------------- */
  void _showSnack({
    required String title,
    required String message,
    SnackType type = SnackType.info,
    IconData? icon,
    int seconds = 3,
  }) {
    try { Get.closeAllSnackbars(); } catch (_) {}
    final LinearGradient gradient;
    final Color textColor = Colors.white;
    switch (type) {
      case SnackType.success:
        gradient = LinearGradient(colors: [Colors.green.shade600, Colors.green.shade400]);
        break;
      case SnackType.error:
        gradient = LinearGradient(colors: [Colors.red.shade700, Colors.red.shade400]);
        break;
      case SnackType.info:
      default:
        gradient = LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]);
        break;
    }
    Get.snackbar(
      title, message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundGradient: gradient,
      colorText: textColor,
      icon: icon != null ? Icon(icon, color: Colors.white) : null,
      duration: Duration(seconds: seconds),
      maxWidth: 600,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  /* ------------------------- Pick / Remove Font ------------------------- */
  Future<void> pickFontFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf', 'woff', 'woff2', 'ttc'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final f = result.files.first;
      pickedFileName = f.name;

      if (f.bytes != null) {
        fontFileBytes.value = Uint8List.fromList(f.bytes!);
      } else if (f.path != null) {
        final bytes = await File(f.path!).readAsBytes();
        fontFileBytes.value = Uint8List.fromList(bytes);
      } else {
        _showSnack(title: 'خطأ', message: 'تعذر قراءة ملف الخط المختار', type: SnackType.error);
        return;
      }
      update(['font_file_picker']);
      _showSnack(title: 'تم', message: 'تم اختيار ملف: ${pickedFileName ?? ''}', type: SnackType.info);
    } catch (e) {
      _showSnack(title: 'خطأ', message: 'فشل اختيار ملف الخط: $e', type: SnackType.error);
    }
  }

  void removeFontFile() {
    fontFileBytes.value = null;
    uploadedFontUrl.value = '';
    uploadedFontPath.value = '';
    pickedFileName = null;
    update(['font_file_picker']);
  }

  Future<String> uploadFontFileToServer() async {
    if (fontFileBytes.value == null) {
      throw Exception('لا يوجد ملف خط للرفع');
    }
    isUploadingFont.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/upload/font');
      final request = http.MultipartRequest('POST', uri);

      String filename = pickedFileName ?? 'font_${DateTime.now().millisecondsSinceEpoch}.ttf';
      if (!filename.contains('.')) {
        filename = '$filename.ttf';
      } else {
        final parts = filename.split('.');
        final ext = parts.removeLast().toLowerCase();
        filename = parts.join('.') + '.$ext';
      }

      String? mime = lookupMimeType(filename, headerBytes: fontFileBytes.value) ?? 'application/octet-stream';
      MediaType contentType;
      try {
        final p = mime.split('/');
        contentType = MediaType(p[0], p[1]);
      } catch (_) {
        contentType = MediaType('application', 'octet-stream');
      }

      final mp = http.MultipartFile.fromBytes(
        'font',
        fontFileBytes.value!,
        filename: filename,
        contentType: contentType,
      );

      request.files.add(mp);
      request.headers.addAll({'Accept': 'application/json'});

      final streamed = await request.send();
      final responseString = await streamed.stream.bytesToString();
      final status = streamed.statusCode;

      if (status == 422) {
        String msg;
        try {
          final parsed = json.decode(responseString);
          msg = parsed.toString();
        } catch (_) {
          msg = responseString;
        }
        throw Exception('فشل رفع ملف الخط (422): $msg');
      }

      if (status >= 200 && status < 300) {
        final parsed = json.decode(responseString);
        if (parsed is Map<String, dynamic>) {
          if (parsed.containsKey('font_url')) uploadedFontUrl.value = parsed['font_url'].toString();
          if (parsed.containsKey('font_path')) uploadedFontPath.value = parsed['font_path'].toString();
          if (uploadedFontUrl.value.isNotEmpty) return uploadedFontUrl.value;
          if (uploadedFontPath.value.isNotEmpty) return uploadedFontPath.value;
        }
        throw Exception('تعذر استخراج رابط/مسار الخط من الاستجابة');
      } else {
        throw Exception('HTTP $status - $responseString');
      }
    } finally {
      isUploadingFont.value = false;
    }
  }

  /* ------------------------- Pick / Remove Watermark Image ------------------------- */
  Future<void> pickWatermarkImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final f = result.files.first;
      pickedWmImageName = f.name;

      if (f.bytes != null) {
        wmImageBytes.value = Uint8List.fromList(f.bytes!);
      } else if (f.path != null) {
        final bytes = await File(f.path!).readAsBytes();
        wmImageBytes.value = Uint8List.fromList(bytes);
      } else {
        _showSnack(title: 'خطأ', message: 'تعذر قراءة ملف صورة العلامة', type: SnackType.error);
        return;
      }
      update(['wm_image_picker']);
      _showSnack(title: 'تم', message: 'تم اختيار الصورة: ${pickedWmImageName ?? ''}', type: SnackType.info);
    } catch (e) {
      _showSnack(title: 'خطأ', message: 'فشل اختيار صورة العلامة: $e', type: SnackType.error);
    }
  }

  void removeWatermarkImage() {
    wmImageBytes.value = null;
    pickedWmImageName = null;
    uploadedWmImageUrl.value = '';
    update(['wm_image_picker']);
  }

  /// يرفع صورة العلامة إلى /watermark/upload-image (بدون أي وسم)،
  /// ويمكن تفعيلها مباشرة setAsActive=true
  Future<String> uploadWatermarkImageToServer({bool setAsActive = true}) async {
    if (wmImageBytes.value == null) {
      throw Exception('لا يوجد ملف صورة للعلامة لرفعه');
    }
    isUploadingWmImage.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/watermark/upload-image');
      final request = http.MultipartRequest('POST', uri);

      String filename = pickedWmImageName ??
          'wm_${DateTime.now().millisecondsSinceEpoch}.png';
      if (!filename.contains('.')) {
        filename = '$filename.png';
      } else {
        final parts = filename.split('.');
        final ext = parts.removeLast().toLowerCase();
        filename = parts.join('.') + '.$ext';
      }

      String? mime = lookupMimeType(filename, headerBytes: wmImageBytes.value) ??
          'image/png';
      MediaType contentType;
      try {
        final p = mime.split('/');
        contentType = MediaType(p[0], p[1]);
      } catch (_) {
        contentType = MediaType('image', 'png');
      }

      final mp = http.MultipartFile.fromBytes(
        'image',
        wmImageBytes.value!,
        filename: filename,
        contentType: contentType,
      );
      request.files.add(mp);

      // set_as_active: فعّل مباشرة كسجل watermark (اختياري)
      request.fields['set_as_active'] = setAsActive ? '1' : '0';

      request.headers.addAll({'Accept': 'application/json'});

      final streamed = await request.send();
      final responseString = await streamed.stream.bytesToString();
      final status = streamed.statusCode;

      if (status == 422) {
        String msg;
        try {
          final parsed = json.decode(responseString);
          msg = parsed.toString();
        } catch (_) {
          msg = responseString;
        }
        throw Exception('فشل رفع صورة العلامة (422): $msg');
      }

      if (status >= 200 && status < 300) {
        final parsed = json.decode(responseString);
        final url = (parsed is Map && parsed['image_url'] != null)
            ? parsed['image_url'].toString()
            : null;

        if (url != null && url.isNotEmpty) {
          uploadedWmImageUrl.value = url;

          // لو تم تفعيلها مباشرة، حدّث current من الرد إن وُجد
          if (parsed is Map && parsed['data'] is Map<String, dynamic>) {
            current.value = WatermarkModel.fromJson(parsed['data'] as Map<String, dynamic>);
            // مزامنة إعدادات الـ Rx مع DB
            if (current.value?.wmImgScale != null) {
              wmImgScale.value = current.value!.wmImgScale!;
            }
            if (current.value?.wmOpacity != null) {
              wmOpacity.value = current.value!.wmOpacity!;
            }
          }

          _showSnack(
            title: 'نجاح',
            message: setAsActive
                ? 'تم رفع وتفعيل صورة العلامة'
                : 'تم رفع صورة العلامة',
            type: SnackType.success,
            icon: Icons.check_circle,
          );

          // تنظيف بعد الرفع (لو حاب تبقي المعاينة، احذف السطرين التاليين)
          removeWatermarkImage();
          return url;
        }
        throw Exception('تعذر استخراج رابط صورة العلامة من استجابة السيرفر');
      } else {
        throw Exception('فشل رفع صورة العلامة. الحالة: $status - $responseString');
      }
    } finally {
      isUploadingWmImage.value = false;
    }
  }

  /* ------------------------- API: GET / POST|PATCH / DELETE ------------------------- */
  Future<void> fetchWatermark() async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/watermark');
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final data = (body is Map && body['data'] != null)
            ? body['data']
            : (body is Map && body['exists'] == true ? body['data'] : null);

        if (data is Map<String, dynamic>) {
          current.value = WatermarkModel.fromJson(data);

          // مزامنة قيم الـ Rx مع DB عند الجلب
          if (current.value?.wmImgScale != null) {
            wmImgScale.value = current.value!.wmImgScale!;
          }
          if (current.value?.wmOpacity != null) {
            wmOpacity.value = current.value!.wmOpacity!;
          }
        } else {
          current.value = null;
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل الجلب (HTTP ${res.statusCode})', type: SnackType.error);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'فشل جلب العلامة المائية: $e', type: SnackType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// upsert: ينشئ/يعدّل الحقول المُرسلة فقط.
  /// لو أرسلت isImage=true → سيُفرغ حقول النص في الباك‌اند.
  /// لو isImage=false → سيُفرغ image_url في الباك‌اند.
  ///
  /// NEW: يمكنك تمرير wmImgScale (0.08..0.35) و wmOpacity (0..100) وسيتم حفظهما.
  Future<bool> upsertWatermark({
    required bool isImage,
    String? imageUrl,
    // نص:
    String? textContent,
    int? fontSize,
    String? color,       // hex
    String? fontUrl,     // رابط مباشر للخط
    bool uploadPickedFontIfAny = true,

    // إعدادات عامة جديدة:
    double? wmImgScaleParam,   // (0.08..0.35)
    int? wmOpacityParam,       // (0..100)
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/watermark');
      final bodyMap = <String, dynamic>{
        'is_image': isImage ? 1 : 0,
      };

      // أولوية: ما تم تمريره للدالة، وإلا خذ من الـ Rx الحالية
      final double? finalScale = wmImgScaleParam ?? (current.value?.wmImgScale ?? wmImgScale.value);
      final int? finalOpacity = wmOpacityParam ?? (current.value?.wmOpacity ?? wmOpacity.value);

      // أضف دائماً القيم الجديدة طالما ليست null
      if (finalScale != null) bodyMap['wm_img_scale'] = double.parse(finalScale.toStringAsFixed(2));
      if (finalOpacity != null) bodyMap['wm_opacity'] = finalOpacity;

      if (isImage) {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          bodyMap['image_url'] = imageUrl;
        }
      } else {
        String? finalFontUrl = fontUrl;

        if (uploadPickedFontIfAny && fontFileBytes.value != null) {
          try {
            finalFontUrl = await uploadFontFileToServer();
          } catch (e) {
            _showSnack(title: 'خطأ', message: 'فشل رفع ملف الخط: $e', type: SnackType.error);
            return false;
          }
        }

        if (textContent != null) bodyMap['text_content'] = textContent;
        if (fontSize != null) bodyMap['font_size'] = fontSize;
        if (color != null) bodyMap['color'] = color;
        if (finalFontUrl != null && finalFontUrl.isNotEmpty) bodyMap['font_url'] = finalFontUrl;
      }

      final res = await http.post(
        uri,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode(bodyMap),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = json.decode(res.body);
        final data = (body is Map && body['data'] != null) ? body['data'] : body;
        if (data is Map<String, dynamic>) {
          current.value = WatermarkModel.fromJson(data);

          // مزامنة الـ Rx مع قيم DB الجديدة
          if (current.value?.wmImgScale != null) {
            wmImgScale.value = current.value!.wmImgScale!;
          }
          if (current.value?.wmOpacity != null) {
            wmOpacity.value = current.value!.wmOpacity!;
          }

          _showSnack(
            title: 'تم',
            message: (res.statusCode == 201) ? 'تم إنشاء الإعداد' : 'تم تحديث الإعداد',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          if (!isImage) removeFontFile();
          return true;
        } else {
          _showSnack(title: 'تنبيه', message: 'استجابة غير متوقعة من الخادم', type: SnackType.info);
          return false;
        }
      } else if (res.statusCode == 422) {
        final parsed = json.decode(res.body);
        _showSnack(title: 'خطأ إدخال', message: parsed.toString(), type: SnackType.error);
        return false;
      } else {
        _showSnack(title: 'خطأ', message: 'فشل العملية (HTTP ${res.statusCode})', type: SnackType.error);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'فشل عملية الحفظ: $e', type: SnackType.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteWatermark() async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/watermark');
      final res = await http.delete(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        current.value = null;
        _showSnack(title: 'تم', message: 'تم حذف الإعداد', type: SnackType.success, icon: Icons.check_circle);
        return true;
      } else {
        _showSnack(title: 'خطأ', message: 'فشل الحذف (HTTP ${res.statusCode})', type: SnackType.error);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'خطأ أثناء الحذف: $e', type: SnackType.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /* ------------------------- Font Preview ------------------------- */
  Future<bool> loadFontForPreview({
    required String fontUrl,
    required String familyName,
  }) async {
    isPreviewingFont.value = true;
    try {
      final res = await http.get(Uri.parse(fontUrl));
      if (res.statusCode == 200) {
        final bytes = res.bodyBytes;
        final byteData = ByteData.view(bytes.buffer);
        final loader = FontLoader(familyName);
        loader.addFont(Future.value(byteData));
        await loader.load();
        previewedFamily.value = familyName;
        _showSnack(title: 'نجاح', message: 'تم تحميل الخط للمعاينة', type: SnackType.success);
        return true;
      } else {
        _showSnack(title: 'خطأ', message: 'فشل تحميل الخط (HTTP ${res.statusCode})', type: SnackType.error);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'خطأ عند معاينة الخط: $e', type: SnackType.error);
      return false;
    } finally {
      isPreviewingFont.value = false;
    }
  }

  TextStyle previewTextStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    final family = previewedFamily.value;
    if (family.isEmpty) {
      return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
    }
    return TextStyle(fontFamily: family, fontSize: fontSize, fontWeight: fontWeight, color: color);
  }
}
