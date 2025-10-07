// lib/controllers/font_controller.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../core/data/model/FontModel.dart';
import '../core/data/model/FontSizeModel.dart';
import '../core/data/model/FontWeightModel.dart';

enum SnackType { success, error, info }

class FontController extends GetxController {
  // تعديل هذا الـ base URL حسب بيئتك (dev / prod)
  static const _baseUrl =
      'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  // حالات التحميل والحفظ
  final isLoading = false.obs;
  final isSaving = false.obs;

  // البيانات الرئيسية
  final Rx<FontModel?> activeFont = Rx<FontModel?>(null);
  final RxList<FontSizeModel> activeSizes = <FontSizeModel>[].obs;
  final RxList<FontModel> allFonts = <FontModel>[].obs;

  // رفع ملفات الخطوط (نحتفظ بالبايتز/الروابط)
  final Rx<Uint8List?> fontFileBytes = Rx<Uint8List?>(null);
  final RxString uploadedFontUrl = ''.obs;
  final RxString uploadedFontPath = ''.obs;

  // اسم الملف الذي اختاره المستخدم (إن وُجد) — مفيد لاستخدام الامتداد الحقيقي
  String? pickedFileName;

  // ---------- Snack helper ----------
  void _showSnack({
    required String title,
    required String message,
    SnackType type = SnackType.info,
    IconData? icon,
    int seconds = 3,
  }) {
    try {
      Get.closeAllSnackbars();
    } catch (_) {}
    final LinearGradient gradient;
    final Color textColor = Colors.white;

    switch (type) {
      case SnackType.success:
        gradient = LinearGradient(
            colors: [Colors.green.shade600, Colors.green.shade400]);
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
      title,
      message,
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

  // ======================
  // ملفات الخط - اختيار ورفع وحذف محلي/خادم
  // ======================

  /// يلتقط ملف من الجهاز (يدعم ttf, otf, ttc)
  Future<void> pickFontFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf', 'ttc'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      pickedFileName = file.name;

      if (file.bytes != null) {
        fontFileBytes.value = Uint8List.fromList(file.bytes!);
      } else if (file.path != null) {
        final bytes = await File(file.path!).readAsBytes();
        fontFileBytes.value = Uint8List.fromList(bytes);
      } else {
        _showSnack(title: 'خطأ', message: 'تعذر قراءة الملف المختار', type: SnackType.error);
        return;
      }

      update(['font_file_picker']);
      _showSnack(title: 'معلومات', message: 'تم اختيار الملف: ${pickedFileName ?? ''}', type: SnackType.info);
    } catch (e) {
      _showSnack(title: 'خطأ', message: 'فشل في اختيار ملف الخط: $e', type: SnackType.error);
    }
  }

  /// يزيل الملف المختار محلياً
  void removeFontFile() {
    fontFileBytes.value = null;
    uploadedFontUrl.value = '';
    uploadedFontPath.value = '';
    pickedFileName = null;
    update(['font_file_picker']);
  }

  /// يرفع الملف إلى السيرفر (multipart) — يرجع رابط أو path حسب استجابة السيرفر
  Future<String> uploadFontFileToServer() async {
  if (fontFileBytes.value == null) {
    throw Exception('لا يوجد ملف خط للرفع');
  }

  final uri = Uri.parse('$_baseUrl/upload/font');
  final request = http.MultipartRequest('POST', uri);

  // تأكد من وجود اسم يحتوي على الامتداد الصحيح
  String filename = pickedFileName ?? 'font_${DateTime.now().millisecondsSinceEpoch}.ttf';
  if (!filename.contains('.')) {
    filename = '$filename.ttf';
  } else {
    // إذا الامتداد موجود وحساس لحالة الأحرف، افرض lower-case
    final parts = filename.split('.');
    final ext = parts.removeLast().toLowerCase();
    filename = parts.join('.') + '.' + ext;
  }

  // اكتشاف mime بناءً على الاسم (يمكن أن يرجع null)
  String? mime = lookupMimeType(filename, headerBytes: fontFileBytes.value);
  // امنح fallback آمن
  mime ??= 'application/octet-stream';

  MediaType contentType;
  try {
    final p = mime.split('/');
    contentType = MediaType(p[0], p[1]);
  } catch (_) {
    contentType = MediaType('application', 'octet-stream');
  }

  final multipartFile = http.MultipartFile.fromBytes(
    'font',
    fontFileBytes.value!,
    filename: filename,
    contentType: contentType,
  );

  request.files.add(multipartFile);
  request.headers.addAll({'Accept': 'application/json'});

  final streamed = await request.send();
  final responseString = await streamed.stream.bytesToString();
  final status = streamed.statusCode;

  if (status == 422) {
    try {
      final parsed = json.decode(responseString);
      final err = parsed is Map && parsed['errors'] != null ? parsed['errors'] : parsed;
      print('Upload 422 response: $err');
      throw Exception('فشل رفع ملف الخط. الحالة: 422 - $err');
    } catch (e) {
      print('Upload 422 raw: $responseString');
      throw Exception('فشل رفع ملف الخط. الحالة: 422 - $responseString');
    }
  }

  if (status >= 200 && status < 300) {
    final parsed = json.decode(responseString);
    if (parsed is Map<String, dynamic>) {
      if (parsed.containsKey('font_url')) uploadedFontUrl.value = parsed['font_url'].toString();
      if (parsed.containsKey('font_path')) uploadedFontPath.value = parsed['font_path'].toString();
      if (uploadedFontUrl.value.isNotEmpty) return uploadedFontUrl.value;
      if (uploadedFontPath.value.isNotEmpty) return uploadedFontPath.value;
    }
    throw Exception('تعذر استخراج رابط ملف الخط من استجابة السيرفر');
  } else {
    print('Upload error status $status body: $responseString');
    throw Exception('فشل رفع ملف الخط. الحالة: $status - $responseString');
  }
}
  /// يحذف الملف من السيرفر باستخدام المسار (توقع body: { font_path: '...' })
  Future<bool> deleteUploadedFontFromServer({required String fontPath}) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/delete/font');

      final res = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'font_path': fontPath}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body is Map && (body['success'] == true || body['message'] != null)) {
          uploadedFontPath.value = '';
          uploadedFontUrl.value = '';
          _showSnack(
            title: 'تم',
            message: 'تم حذف ملف الخط من السيرفر',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في حذف ملف الخط من السيرفر. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء حذف ملف الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ======================
  // دوال API للخطوط (Fonts)
  // ======================

  /// جلب الخط النشط
  Future<void> fetchActiveFont() async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/fonts/active');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true && body['data'] != null) {
          activeFont.value = FontModel.fromJson(body['data']);
        } else {
          activeFont.value = null;
          _showSnack(
            title: 'تحذير',
            message: 'لا يوجد خط نشط',
            type: SnackType.info,
            icon: Icons.info_outline,
          );
        }
      } else {
        _showSnack(
          title: 'خطأ',
          message: 'فشل في جلب الخط النشط. الحالة: ${res.statusCode}',
          type: SnackType.error,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء جلب الخط النشط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// جلب كل الخطوط
  Future<void> fetchAllFonts() async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/fonts');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final List list = body['data'] as List;
          allFonts.assignAll(list.map((x) => FontModel.fromJson(x)).toList());
        }
      } else {
        _showSnack(
          title: 'خطأ',
          message: 'فشل في جلب جميع الخطوط. الحالة: ${res.statusCode}',
          type: SnackType.error,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء جلب جميع الخطوط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تعيين خط كـ نشط (server)
  Future<bool> setActiveFont(int fontId) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/fonts/$fontId/active');
      final res = await http.put(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          // حدث تغيّر في الخط النشط، نجلبه محلياً
          await fetchActiveFont();
          await fetchAllFonts();
          _showSnack(
            title: 'تم',
            message: 'تم تعيين الخط النشط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في تعيين الخط النشط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء تعيين الخط النشط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// إنشاء خط جديد
  Future<bool> createFont({
    required String familyName,
    bool isActive = false,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/fonts');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'family_name': familyName, 'is_active': isActive}),
      );

      if (res.statusCode == 201) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم إنشاء الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          // تحديث قائمة الخطوط
          await fetchAllFonts();
          if (isActive) await fetchActiveFont();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في إنشاء الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء إنشاء الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// تحديث خط
  Future<bool> updateFont({
    required int fontId,
    String? familyName,
    bool? isActive,
  }) async {
    isSaving.value = true;
    try {
      final payload = <String, dynamic>{};
      if (familyName != null) payload['family_name'] = familyName;
      if (isActive != null) payload['is_active'] = isActive;

      final uri = Uri.parse('$_baseUrl/fonts/$fontId');
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم تحديث الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          // تحديث البيانات محلياً
          await fetchAllFonts();
          await fetchActiveFont();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في تحديث الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء تحديث الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// حذف خط (مع حذف أوزانه وملفاته)
  Future<bool> deleteFont(int fontId) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/fonts/$fontId');
      final res = await http.delete(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم حذف الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          await fetchAllFonts();
          await fetchActiveFont();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في حذف الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء حذف الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ======================
  // دوال API لأوزان الخطوط (Weights)
  // ======================

  /// جلب أوزان خط معين (مفيد لتحديث واجهة عرض الأوزان)
  Future<List<FontWeightModel>> fetchFontWeights(int fontId) async {
    try {
      final uri = Uri.parse('$_baseUrl/fonts/$fontId/weights');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final List list = body['data'] as List;
          return list.map((x) => FontWeightModel.fromJson(x)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// إضافة وزن لخط
  Future<bool> addFontWeight({
    required int fontId,
    required int weightValue,
    required String weightName,
    required String assetPath,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/fonts/$fontId/weights');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'weight_value': weightValue,
          'weight_name': weightName,
          'asset_path': assetPath,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم إضافة وزن الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          await fetchAllFonts();
          await fetchActiveFont();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في إضافة وزن الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء إضافة وزن الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// تحديث وزن
  Future<bool> updateFontWeight({
    required int fontId,
    required int weightId,
    int? weightValue,
    String? weightName,
    String? assetPath,
  }) async {
    isSaving.value = true;
    try {
      final payload = <String, dynamic>{};
      if (weightValue != null) payload['weight_value'] = weightValue;
      if (weightName != null) payload['weight_name'] = weightName;
      if (assetPath != null) payload['asset_path'] = assetPath;

      final uri = Uri.parse('$_baseUrl/fonts/$fontId/weights/$weightId');
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم تحديث وزن الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          await fetchAllFonts();
          await fetchActiveFont();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في تحديث وزن الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء تحديث وزن الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// حذف وزن
  Future<bool> deleteFontWeight( {
    required int fontId,
    required int weightId,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/fonts/$fontId/weights/$weightId');
      final res = await http.delete(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم حذف وزن الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          await fetchAllFonts();
          await fetchActiveFont();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في حذف وزن الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء حذف وزن الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ======================
  // دوال API لأحجام الخطوط (Sizes)
  // ======================

  /// جلب الأحجام النشطة
  Future<void> fetchActiveSizes() async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/font-sizes');
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final List list = body['data'] as List;
          activeSizes.assignAll(list.map((x) => FontSizeModel.fromJson(x)).toList());
        }
      } else {
        print(res.statusCode);
        _showSnack(
          title: 'خطأ',
          message: 'فشل في جلب الأحجام النشطة. الحالة: ${res.statusCode}',
          type: SnackType.error,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      print(e);
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء جلب الأحجام النشطة: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء حجم جديد
  Future<bool> createFontSize({
    required String sizeName,
    required double sizeValue,
    String? description,
    bool isActive = true,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/font-sizes');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'size_name': sizeName,
          'size_value': sizeValue,
          'description': description,
          'is_active': isActive,
        }),
      );

      if (res.statusCode == 201) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم إنشاء حجم الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          await fetchActiveSizes();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في إنشاء حجم الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء إنشاء حجم الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// تحديث حجم
  Future<bool> updateFontSize({
    required int sizeId,
    String? sizeName,
    double? sizeValue,
    String? description,
    bool? isActive,
  }) async {
    isSaving.value = true;
    try {
      final payload = <String, dynamic>{};
      if (sizeName != null) payload['size_name'] = sizeName;
      if (sizeValue != null) payload['size_value'] = sizeValue;
      if (description != null) payload['description'] = description;
      if (isActive != null) payload['is_active'] = isActive;

      final uri = Uri.parse('$_baseUrl/font-sizes/$sizeId');
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم تحديث حجم الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          await fetchActiveSizes();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في تحديث حجم الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء تحديث حجم الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// حذف حجم
  Future<bool> deleteFontSize(int sizeId) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/font-sizes/$sizeId');
      final res = await http.delete(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body['success'] == true) {
          _showSnack(
            title: 'تم',
            message: 'تم حذف حجم الخط بنجاح',
            type: SnackType.success,
            icon: Icons.check_circle,
          );
          await fetchActiveSizes();
          return true;
        }
      }

      _showSnack(
        title: 'خطأ',
        message: 'فشل في حذف حجم الخط. الحالة: ${res.statusCode}',
        type: SnackType.error,
        icon: Icons.error_outline,
      );
      return false;
    } catch (e) {
      _showSnack(
        title: 'استثناء',
        message: 'حدث خطأ أثناء حذف حجم الخط: $e',
        type: SnackType.error,
        icon: Icons.error,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ======================
  // دوال مساعدة للاستخدام داخل الواجهات
  // ======================

  /// الحصول على TextStyle جاهز للاستخدام في الواجهة
  /// - sizeName: اسم الحجم الموجود في activeSizes (مثال: 'sm','md','lg')
  /// - weightValue: قيمة الوزن (100..900)
  /// - color: لون الخط
  TextStyle getTextStyle({
    String? sizeName,
    int? weightValue,
    Color color = Colors.black,
  }) {
    // الحصول على الخط النشط
    final font = activeFont.value;
    if (font == null) {
      return TextStyle(
        fontFamily: 'Tajawal',
        color: color,
      );
    }

    // تحويل قيمة الوزن إلى FontWeight من Flutter
    FontWeight resolvedWeight = FontWeight.w400;
    if (weightValue != null) {
      switch (weightValue) {
        case 100:
          resolvedWeight = FontWeight.w100;
          break;
        case 200:
          resolvedWeight = FontWeight.w200;
          break;
        case 300:
          resolvedWeight = FontWeight.w300;
          break;
        case 400:
          resolvedWeight = FontWeight.w400;
          break;
        case 500:
          resolvedWeight = FontWeight.w500;
          break;
        case 600:
          resolvedWeight = FontWeight.w600;
          break;
        case 700:
          resolvedWeight = FontWeight.w700;
          break;
        case 800:
          resolvedWeight = FontWeight.w800;
          break;
        case 900:
          resolvedWeight = FontWeight.w900;
          break;
        default:
          resolvedWeight = FontWeight.w400;
      }
    }

    // الحصول على حجم الخط من activeSizes
    double fontSize = 16.0;
    if (sizeName != null) {
      final found = activeSizes.firstWhere(
        (s) => s.sizeName == sizeName,
        orElse: () => FontSizeModel(
          id: 0,
          sizeName: 'md',
          sizeValue: 16.0,
          isActive: true,
        ),
      );
      fontSize = found.sizeValue;
    }

    return TextStyle(
      fontFamily: font.familyName,
      fontWeight: resolvedWeight,
      fontSize: fontSize.sp,
      color: color,
    );
  }

  // ======================
  // تهيئة الكنترولر عند التشغيل
  // ======================
  Future<void> initializeFontData() async {
    await Future.wait([
      fetchActiveFont(),
      fetchActiveSizes(),
      fetchAllFonts(),
    ]);
  }

  @override
  void onInit() {
    super.onInit();
    initializeFontData();
  }
}
