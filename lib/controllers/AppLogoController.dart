// lib/controllers/AppLogoController.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/data/model/AppLogo.dart';

enum SnackType { success, error, info }

class AppLogoController extends GetxController {
  static const _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
 
  final String uploadApiUrl = "https://stayinme.arabiagroup.net/lar_stayInMe/public/api/upload";

  final Rxn<AppLogo> appLogo = Rxn<AppLogo>();
  final isLoading = false.obs;
  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  final RxString uploadedImageUrl = ''.obs;
  final RxBool isSaving = false.obs;

  Map<String, String> _defaultHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

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
  // Image helpers
  // ======================
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      imageBytes.value = bytes;
      update(['app_logo_image']);
    }
  }

  void removeImage() {
    imageBytes.value = null;
    uploadedImageUrl.value = '';
    update(['app_logo_image']);
  }

  /// Upload image bytes to server using same endpoint & pattern as CategoriesController
  /// Expects server to return either:
  ///  - { "image_urls": ["..."] }  (we take first)
  ///  - { "image_url": "..." }
  ///  - { "url": "..." }
  /// Returns the uploaded URL string or throws on failure.
  Future<String> uploadImageToServer() async {
    if (imageBytes.value == null) {
      throw Exception('لا توجد صورة للرفع');
    }

    final request = http.MultipartRequest('POST', Uri.parse(uploadApiUrl));
    // field name used in your backend: images[] (matching CategoriesController)
    request.files.add(
      http.MultipartFile.fromBytes(
        'images[]',
        imageBytes.value!,
        filename: 'app_logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 201 || (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300)) {
      final parsed = json.decode(responseString);
      String? url;
      if (parsed is Map<String, dynamic>) {
        if (parsed.containsKey('image_urls') && parsed['image_urls'] is List && parsed['image_urls'].isNotEmpty) {
          url = parsed['image_urls'][0]?.toString();
        } else if (parsed.containsKey('image_url')) {
          url = parsed['image_url']?.toString();
        } else if (parsed.containsKey('url')) {
          url = parsed['url']?.toString();
        } else if (parsed.containsKey('data')) {
          // sometimes response wraps data
          final data = parsed['data'];
          if (data is Map<String, dynamic>) {
            url = data['image_url']?.toString() ?? (data['image_urls'] is List ? (data['image_urls'][0]?.toString()) : null);
          } else if (data is List && data.isNotEmpty) {
            url = data[0]?.toString();
          }
        }
      }

      if (url == null || url.isEmpty) {
        throw Exception('تعذر استخراج رابط الصورة من استجابة السيرفر');
      }

      uploadedImageUrl.value = url;
      return url;
    } else {
      // try to include server message in exception
      String msg = 'فشل رفع الصورة. الحالة: ${streamedResponse.statusCode}';
      try {
        final parsed = json.decode(responseString);
        if (parsed is Map && parsed['message'] != null) msg += ' - ${parsed['message']}';
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // Convenience: upload image then create app logo with returned URL
  Future<bool> createAppLogoWithImage({
    required String name,
    String? token,
  }) async {
    if (imageBytes.value == null) {
      _showSnack(title: 'تحذير', message: 'اختر صورة أولاً', type: SnackType.error, icon: Icons.warning);
      return false;
    }

    isSaving.value = true;
    try {
      final url = await uploadImageToServer();
      return await createAppLogo(name: name, url: url, token: token);
    } catch (e) {
      _showSnack(title: 'خطأ', message: 'فشل رفع أو إنشاء اللوجو: $e', type: SnackType.error, icon: Icons.error_outline);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Convenience: upload image then update logo url
  Future<bool> updateLogoWithImage({
    required int id,
    String? token,
  }) async {
    if (imageBytes.value == null) {
      _showSnack(title: 'تحذير', message: 'اختر صورة أولاً', type: SnackType.error, icon: Icons.warning);
      return false;
    }

    isSaving.value = true;
    try {
      final url = await uploadImageToServer();
      return await updateLogoUrl(id: id, url: url, token: token);
    } catch (e) {
      _showSnack(title: 'خطأ', message: 'فشل رفع أو تحديث رابط اللوجو: $e', type: SnackType.error, icon: Icons.error_outline);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ======================
  // API methods (fetch/create/update)
  // ======================

  // Fetch logo (first)
  Future<void> fetchAppLogo({String? token}) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/app-logo');
      final res = await http.get(uri, headers: _defaultHeaders(token: token));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body is Map<String, dynamic> && body['success'] == true && body['data'] != null) {
          final data = body['data'];
          if (data is Map<String, dynamic>) {
            appLogo.value = AppLogo.fromJson(data);
          } else if (data is List && data.isNotEmpty && data[0] is Map<String, dynamic>) {
            appLogo.value = AppLogo.fromJson(data[0] as Map<String, dynamic>);
          } else {
            appLogo.value = null;
          }
        } else {
          appLogo.value = null;
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل في جلب لوجو التطبيق. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ: $e', type: SnackType.error, icon: Icons.error);
    } finally {
      isLoading.value = false;
    }
  }

  // Create logo (expects url already available as string)
  Future<bool> createAppLogo({
    required String name,
    required String url,
    String? token,
  }) async {
    isSaving.value = true;
    try {
      final body = json.encode({'name': name, 'url': url});
      final uri = Uri.parse('$_baseUrl/app-logo');
      final res = await http.post(uri, headers: _defaultHeaders(token: token), body: body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bodyParsed = json.decode(res.body);
        if (bodyParsed is Map<String, dynamic> && bodyParsed['success'] == true && bodyParsed['data'] != null) {
          appLogo.value = AppLogo.fromJson(bodyParsed['data'] as Map<String, dynamic>);
        } else {
          // try to build minimal local model
          appLogo.value = AppLogo(id: 0, name: name, url: url);
        }
        _showSnack(title: 'تم', message: 'تم إنشاء لوجو التطبيق.', type: SnackType.success, icon: Icons.check_circle);
        return true;
      } else {
        _showSnack(title: 'خطأ', message: 'فشل إنشاء اللوجو. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ: $e', type: SnackType.error, icon: Icons.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Update url only
  Future<bool> updateLogoUrl({
    required int id,
    required String url,
    String? token,
  }) async {
    isSaving.value = true;
    try {
      final body = json.encode({'url': url});
      final uri = Uri.parse('$_baseUrl/app-logo/$id');
      http.Response res;
      try {
        res = await http.put(uri, headers: _defaultHeaders(token: token), body: body);
      } catch (e) {
        res = http.Response('', 404);
      }

      if (res.statusCode == 404) {
        // fallback if needed
        final fallbackUri = Uri.parse('$_baseUrl/app-logo/$id');
        final fallbackRes = await http.post(fallbackUri, headers: _defaultHeaders(token: token), body: body);
        if (fallbackRes.statusCode >= 200 && fallbackRes.statusCode < 300) {
          final parsed = json.decode(fallbackRes.body);
          if (parsed is Map<String, dynamic> && parsed['success'] == true && parsed['data'] != null) {
            appLogo.value = AppLogo.fromJson(parsed['data'] as Map<String, dynamic>);
          } else {
            if (appLogo.value != null) appLogo.value = appLogo.value!.copyWith(url: url);
          }
          _showSnack(title: 'تم', message: 'تم تحديث رابط اللوجو.', type: SnackType.success, icon: Icons.check);
          return true;
        } else {
          _showSnack(title: 'خطأ', message: 'فشل التحديث. الحالة: ${fallbackRes.statusCode}', type: SnackType.error, icon: Icons.error_outline);
          return false;
        }
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final parsed = json.decode(res.body);
        if (parsed is Map<String, dynamic> && parsed['success'] == true && parsed['data'] != null) {
          appLogo.value = AppLogo.fromJson(parsed['data'] as Map<String, dynamic>);
        } else {
          if (appLogo.value != null) appLogo.value = appLogo.value!.copyWith(url: url);
        }
        _showSnack(title: 'تم', message: 'تم تحديث رابط اللوجو.', type: SnackType.success, icon: Icons.check);
        return true;
      } else {
        _showSnack(title: 'خطأ', message: 'فشل التحديث. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ: $e', type: SnackType.error, icon: Icons.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
