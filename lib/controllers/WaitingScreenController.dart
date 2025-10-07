// lib/controllers/WaitingScreenController.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/data/model/WaitingScreen.dart';

enum SnackType { success, error, info }

class WaitingScreenController extends GetxController {
  static const _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
  final String uploadApiUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api/upload';

  final Rxn<WaitingScreen> waitingScreen = Rxn<WaitingScreen>();
  final isLoading = false.obs;
  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  final RxString uploadedImageUrl = ''.obs;
  final RxBool isSaving = false.obs;
  
  // متحكمات جديدة للون
  final RxString selectedColor = '#FFFFFF'.obs;
  final TextEditingController colorController = TextEditingController();

  Map<String, String> _defaultHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
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
  // دوال إدارة الألوان
  // ======================
  
  // تحديث اللون المختار
  void updateColor(String color) {
    selectedColor.value = color;
    colorController.text = color;
  }
  
  // تحويل نص اللون إلى كائن Color
  Color parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('0x')) {
        return Color(int.parse(colorString));
      } else if (colorString == 'transparent') {
        return Colors.transparent;
      } else {
        // محاولة التعرف على ألوان مسمية
        switch (colorString.toLowerCase()) {
          case 'red': return Colors.red;
          case 'blue': return Colors.blue;
          case 'green': return Colors.green;
          case 'yellow': return Colors.yellow;
          case 'orange': return Colors.orange;
          case 'purple': return Colors.purple;
          case 'pink': return Colors.pink;
          case 'teal': return Colors.teal;
          case 'cyan': return Colors.cyan;
          case 'brown': return Colors.brown;
          case 'grey': return Colors.grey;
          case 'black': return Colors.black;
          case 'white': return Colors.white;
          default: return Colors.white;
        }
      }
    } catch (e) {
      return Colors.white;
    }
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
      update(['waiting_screen_image']);
    }
  }

  void removeImage() {
    imageBytes.value = null;
    uploadedImageUrl.value = '';
    update(['waiting_screen_image']);
  }

  Future<String> uploadImageToServer() async {
    if (imageBytes.value == null) {
      throw Exception('لا توجد صورة للرفع');
    }

    final request = http.MultipartRequest('POST', Uri.parse(uploadApiUrl));
    request.files.add(
      http.MultipartFile.fromBytes(
        'images[]',
        imageBytes.value!,
        filename: 'waiting_screen_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );

    final streamed = await request.send();
    final responseString = await streamed.stream.bytesToString();

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
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
      String msg = 'فشل رفع الصورة. الحالة: ${streamed.statusCode}';
      try {
        final parsed = json.decode(responseString);
        if (parsed is Map && parsed['message'] != null) msg += ' - ${parsed['message']}';
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // ======================
  // API: fetch / store / delete
  // ======================

  Future<void> fetchWaitingScreen({String? token}) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/waiting-screen');
      final res = await http.get(uri, headers: _defaultHeaders(token: token));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        if (body is Map<String, dynamic> && body['success'] == true && body['data'] != null) {
          final data = body['data'];
          if (data is Map<String, dynamic>) {
            waitingScreen.value = WaitingScreen.fromJson(data);
            // تعيين اللون الحالي بعد جلب البيانات
            selectedColor.value = waitingScreen.value!.color;
            colorController.text = waitingScreen.value!.color;
          } else {
            waitingScreen.value = null;
          }
        } else {
          waitingScreen.value = null;
        }
      } else {
        _showSnack(title: 'خطأ', message: 'فشل جلب إعداد شاشة الانتظار. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
      }
    } catch (e) {
      _showSnack(title: 'استثناء', message: 'حدث خطأ: $e', type: SnackType.error, icon: Icons.error);
    } finally {
      isLoading.value = false;
    }
  }

  /// Create or update waiting screen
  Future<bool> createOrUpdateWaitingScreen({
    String? color,
    String? imageUrl,
    String? token,
  }) async {
    isSaving.value = true;
    try {
      String finalImageUrl = imageUrl ?? '';
      String finalColor = color ?? selectedColor.value;

      final body = json.encode({
        'color': finalColor,
        'image_url': finalImageUrl,
      });

      final uri = Uri.parse('$_baseUrl/waiting-screen');
      final res = await http.post(uri, headers: _defaultHeaders(token: token), body: body);

      final responseBody = json.decode(res.body);
      final statusOk = (res.statusCode >= 200 && res.statusCode < 300);
      
      if (statusOk) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          if (responseBody['data'] != null) {
            waitingScreen.value = WaitingScreen.fromJson(responseBody['data'] as Map<String, dynamic>);
          } else {
            // إنشاء سجل جديد إذا لم يكن هناك بيانات في الاستجابة
            waitingScreen.value = WaitingScreen(id: 1, color: finalColor, imageUrl: finalImageUrl);
          }
          _showSnack(
            title: 'تم', 
            message: 'تم حفظ إعدادات شاشة الانتظار بنجاح', 
            type: SnackType.success, 
            icon: Icons.check_circle
          );
          return true;
        } else {
          // معالجة الحالة عندما يكون success = false
          String errorMsg = responseBody['message'] ?? 'فشل في حفظ الإعدادات';
          _showSnack(
            title: 'خطأ', 
            message: errorMsg, 
            type: SnackType.error, 
            icon: Icons.error_outline
          );
          return false;
        }
      } else {
        String errorMsg = responseBody['message'] ?? 'فشل في الاتصال بالسيرفر';
        _showSnack(
          title: 'خطأ', 
          message: 'الحالة: ${res.statusCode} - $errorMsg', 
          type: SnackType.error, 
          icon: Icons.error_outline
        );
        return false;
      }
    } catch (e) {
      _showSnack(
        title: 'استثناء', 
        message: 'حدث خطأ غير متوقع: $e', 
        type: SnackType.error, 
        icon: Icons.error
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update image by uploading it first and patching the record
  Future<bool> updateImageWithUpload({String? token}) async {
    if (imageBytes.value == null) {
      _showSnack(
        title: 'تحذير', 
        message: 'يجب اختيار صورة أولاً', 
        type: SnackType.info, 
        icon: Icons.info
      );
      return false;
    }

    isSaving.value = true;
    try {
      final url = await uploadImageToServer();
      
      // استخدام اللون الحالي إذا كان موجودًا، أو اللون الافتراضي
      String currentColor = waitingScreen.value?.color ?? selectedColor.value;
      
      return await createOrUpdateWaitingScreen(
        color: currentColor, 
        imageUrl: url, 
        token: token
      );
    } catch (e) {
      _showSnack(
        title: 'خطأ', 
        message: 'فشل في رفع الصورة: $e', 
        type: SnackType.error, 
        icon: Icons.error_outline
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteWaitingScreen({String? token}) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/waiting-screen');
      final res = await http.delete(uri, headers: _defaultHeaders(token: token));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        waitingScreen.value = null;
        selectedColor.value = '#FFFFFF'; // إعادة تعيين اللون إلى القيمة الافتراضية
        colorController.text = '#FFFFFF';
        _showSnack(title: 'تم', message: 'تم حذف إعداد الشاشة.', type: SnackType.success, icon: Icons.check);
        return true;
      } else {
        _showSnack(title: 'خطأ', message: 'فشل في الحذف. الحالة: ${res.statusCode}', type: SnackType.error, icon: Icons.error_outline);
        return false;
      }
    } catch (e) {
      _showSnack(title: 'خطأ', message: 'حدث خطأ أثناء الحذف: $e', type: SnackType.error, icon: Icons.error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // دالة مساعدة لإنشاء معاينة الشاشة
  Widget buildPreview() {
    if (waitingScreen.value == null) {
      return Container(
        width: 300,
        height: 400,
        color: parseColor(selectedColor.value),
        child: Center(
          child: Icon(
            Icons.color_lens,
            size: 80,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    final screen = waitingScreen.value!;
    return Container(
      width: 300,
      height: 400,
      color: parseColor(screen.color),
      child: screen.imageUrl.isNotEmpty
          ? Image.network(
              screen.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                );
              },
            )
          : Center(
              child: Icon(
                Icons.color_lens,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
    );
  }

  @override
  void onClose() {
    colorController.dispose();
    super.onClose();
  }
}