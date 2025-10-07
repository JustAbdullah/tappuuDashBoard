// lib/core/controllers/editable_text_controller.dart
// تأكد من وجود هذين الاستيرادين في أعلى الملف:
import 'package:flutter/services.dart'; // <-- مهم: هنا FontLoader موجود
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui; // for FontLoader
import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../core/data/model/EditableTextModel.dart';

enum SnackType { success, error, info }

class EditableTextController extends GetxController {
  // عدّل الـ baseUrl بحسب بيئتك
  static const String _baseUrl =
      'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  // حالات
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingFont = false.obs;
  final RxBool isPreviewingFont = false.obs;

  // البيانات
  RxList<EditableTextModel> items = <EditableTextModel>[].obs;
  Rxn<EditableTextModel> current = Rxn<EditableTextModel>();

  // ملفات الخط للرفع (مثل FontController)
  final Rx<Uint8List?> fontFileBytes = Rx<Uint8List?>(null);
  String? pickedFileName;
  RxString uploadedFontUrl = ''.obs;
  RxString uploadedFontPath = ''.obs;

  // اسم العائلة الذي تم تحميله للمعاينة (لو نجحت)
  RxString previewedFamily = ''.obs;

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
  // Font file pick / remove / upload
  // ======================

  /// اختر ملف خط من الجهاز (ttf, otf, woff, woff2)
  Future<void> pickFontFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf', 'woff', 'woff2', 'ttc'],
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
      _showSnack(title: 'معلومات', message: 'تم اختيار ملف الخط: ${pickedFileName ?? ''}', type: SnackType.info);
    } catch (e) {
      _showSnack(title: 'خطأ', message: 'فشل في اختيار ملف الخط: $e', type: SnackType.error);
    }
  }

  /// إزالة الملف المختار محلياً
  void removeFontFile() {
    fontFileBytes.value = null;
    uploadedFontUrl.value = '';
    uploadedFontPath.value = '';
    pickedFileName = null;
    update(['font_file_picker']);
  }

  /// رفع ملف الخط إلى السيرفر (ترجع رابط أو path حسب استجابة السيرفر)
  /// endpoint: POST /upload/font  (تأكد من الـ endpoint في backend)
  Future<String> uploadFontFileToServer() async {
    if (fontFileBytes.value == null) {
      throw Exception('لا يوجد ملف خط للرفع');
    }

    isUploadingFont.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/upload/font');
      final request = http.MultipartRequest('POST', uri);

      // اسم الملف مع امتداد صحيح
      String filename = pickedFileName ?? 'font_${DateTime.now().millisecondsSinceEpoch}.ttf';
      if (!filename.contains('.')) {
        filename = '$filename.ttf';
      } else {
        // اجعل الامتداد lower-case
        final parts = filename.split('.');
        final ext = parts.removeLast().toLowerCase();
        filename = parts.join('.') + '.' + ext;
      }

      // اكتشاف mime
      String? mime = lookupMimeType(filename, headerBytes: fontFileBytes.value);
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
          throw Exception('فشل رفع ملف الخط. 422 - $err');
        } catch (e) {
          throw Exception('فشل رفع ملف الخط. 422 - $responseString');
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
        throw Exception('فشل رفع ملف الخط. الحالة: $status - $responseString');
      }
    } finally {
      isUploadingFont.value = false;
    }
  }

  // ======================
  // CRUD for editable_texts
  // ======================

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/editable-texts');
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final data = (body is Map && body['data'] != null) ? body['data'] : body;
        if (data is List) {
          items.value = data
              .map((e) => EditableTextModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          items.value = [];
          _showSnack(title: 'خطأ', message: 'البيانات المستلمة غير متوقعة', type: SnackType.error);
        }
      } else {
        _showSnack(title: 'خطأ', message: 'رمز الاستجابة: ${res.statusCode}', type: SnackType.error);
      }
    } catch (e) {
      print('Exception fetchAll EditableText: $e');
      _showSnack(title: 'استثناء', message: 'حدث خطأ عند جلب النصوص', type: SnackType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOne(int id) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/editable-texts/$id');
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        current.value = EditableTextModel.fromJson(data as Map<String, dynamic>);
      } else {
        _showSnack(title: 'خطأ', message: 'رمز الاستجابة: ${res.statusCode}', type: SnackType.error);
      }
    } catch (e) {
      print('Exception fetchOne EditableText: $e');
      _showSnack(title: 'استثناء', message: 'حدث خطأ عند جلب النص', type: SnackType.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// إنشاء نص: إن وُجد ملف خط محلي -> نرفعه أولًا ثم نرسل font_url في البودي
  Future<bool> createEditableText({
    required String keyName,
    required String textContent,
    int fontSize = 16,
    String color = '#000000',
    String? fontUrl, // لو المستخدم أدخل رابط مباشر
  }) async {
    isSaving.value = true;
    try {
      String? finalFontUrl = fontUrl;

      // upload font first if file bytes present
      if (fontFileBytes.value != null) {
        try {
          finalFontUrl = await uploadFontFileToServer();
        } catch (e) {
          _showSnack(title: 'خطأ', message: 'فشل رفع ملف الخط: $e', type: SnackType.error);
          return false;
        }
      }

      final uri = Uri.parse('$_baseUrl/editable-texts');
      final res = await http.post(
        uri,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode({
          'key_name': keyName,
          'text_content': textContent,
          'font_size': fontSize,
          'color': color,
          if (finalFontUrl != null && finalFontUrl.isNotEmpty) 'font_url': finalFontUrl,
        }),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        final model = EditableTextModel.fromJson(data as Map<String, dynamic>);
        items.insert(0, model);
        _showSnack(title: 'نجاح', message: 'تم إنشاء النص', type: SnackType.success, icon: Icons.check_circle);
        // reset local font file (we uploaded it)
        removeFontFile();
        return true;
      } else if (res.statusCode == 422) {
        final parsed = json.decode(res.body);
        _showSnack(title: 'خطأ في الإدخال', message: parsed.toString(), type: SnackType.error);
        return false;
      } else {
        _showSnack(title: 'خطأ', message: 'فشل الإنشاء. حالة: ${res.statusCode}', type: SnackType.error);
        return false;
      }
    } catch (e) {
      print('Exception create EditableText: $e');
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء الإنشاء: $e', type: SnackType.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// تحديث: نفس الفكرة — لو اخترت ملف خط جديد، ارفعه أولًا ثم أرسل font_url
  Future<bool> updateEditableText({
    required int id,
    String? textContent,
    int? fontSize,
    String? color,
    String? fontUrl, // رابط مباشر بدل الرفع
  }) async {
    isSaving.value = true;
    try {
      String? finalFontUrl = fontUrl;

      if (fontFileBytes.value != null) {
        try {
          finalFontUrl = await uploadFontFileToServer();
        } catch (e) {
          _showSnack(title: 'خطأ', message: 'فشل رفع ملف الخط: $e', type: SnackType.error);
          return false;
        }
      }

      final uri = Uri.parse('$_baseUrl/editable-texts/$id');
      final bodyMap = <String, dynamic>{};
      if (textContent != null) bodyMap['text_content'] = textContent;
      if (fontSize != null) bodyMap['font_size'] = fontSize;
      if (color != null) bodyMap['color'] = color;
      if (finalFontUrl != null && finalFontUrl.isNotEmpty) bodyMap['font_url'] = finalFontUrl;

      final res = await http.put(
        uri,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        body: json.encode(bodyMap),
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        final model = EditableTextModel.fromJson(data as Map<String, dynamic>);
        final idx = items.indexWhere((e) => e.id == model.id);
        if (idx != -1) items[idx] = model;
        current.value = model;
        _showSnack(title: 'نجاح', message: 'تم التحديث', type: SnackType.success, icon: Icons.check_circle);
        removeFontFile();
        return true;
      } else if (res.statusCode == 422) {
        final parsed = json.decode(res.body);
        _showSnack(title: 'خطأ في الإدخال', message: parsed.toString(), type: SnackType.error);
        return false;
      } else {
        _showSnack(title: 'خطأ', message: 'فشل التحديث. حالة: ${res.statusCode}', type: SnackType.error);
        return false;
      }
    } catch (e) {
      print('Exception update EditableText: $e');
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء التحديث: $e', type: SnackType.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteItem(int id) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/editable-texts/$id');
      final res = await http.delete(uri);

      if (res.statusCode == 200) {
        items.removeWhere((e) => e.id == id);
        _showSnack(title: 'نجاح', message: 'تم الحذف', type: SnackType.success, icon: Icons.check_circle);
        return true;
      } else {
        _showSnack(title: 'خطأ', message: 'رمز الاستجابة: ${res.statusCode}', type: SnackType.error);
        return false;
      }
    } catch (e) {
      print('Exception delete EditableText: $e');
      _showSnack(title: 'استثناء', message: 'حدث خطأ أثناء الحذف', type: SnackType.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ======================
  // Font preview (dynamic load)
  // ======================

  /// تحميل الخط من رابط وتمكينه للعرض مؤقتًا عبر FontLoader
  /// familyName: الاسم الذي تريد استخدامه في TextStyle(fontFamily: familyName)
  // الدالة المصححة
Future<bool> loadFontForPreview({required String fontUrl, required String familyName}) async {
  isPreviewingFont.value = true;
  try {
    final res = await http.get(Uri.parse(fontUrl));
    if (res.statusCode == 200) {
      final bytes = res.bodyBytes;
      // حول bytes إلى ByteData
      final byteData = ByteData.view(bytes.buffer);

      // استخدم FontLoader من package:flutter/services.dart (بدون ui.)
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
    print('Exception loadFontForPreview: $e');
    _showSnack(title: 'استثناء', message: 'خطأ عند تحميل الخط للمعاينة: $e', type: SnackType.error);
    return false;
  } finally {
    isPreviewingFont.value = false;
  }
}
  /// استرجاع TextStyle جاهز للاستخدام بالـ previewedFamily إن وُجد
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

  // ======================
  // Helpers
  // ======================

  String? _lookupMime(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'ttf':
        return 'font/ttf';
      case 'otf':
        return 'font/otf';
      case 'woff':
        return 'font/woff';
      case 'woff2':
        return 'font/woff2';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return null;
    }
  }
}
