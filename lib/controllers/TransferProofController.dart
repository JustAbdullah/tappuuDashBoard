// lib/core/controllers/transfer_proof_controller.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../core/data/model/TransferProofModel.dart';

class TransferProofController extends GetxController {
  // عدّل الـ base URL على بيئتك إذا لزم
  final String _baseUrl =
      'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
  final String uploadApiUrl =
      'https://stayinme.arabiagroup.net/lar_stayInMe/public/api/upload';

  // اختيارياً ضع توكن المصادقة هنا أو استخدم setter لحقنه من مكان آخر
  String? authToken;
  void setAuthToken(String? token) => authToken = token;

  // الحالة والبيانات
  RxList<TransferProofModel> proofs = <TransferProofModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  RxBool isSaving = false.obs;
  Rxn<TransferProofModel> current = Rxn<TransferProofModel>();

  // التعامل مع الصور قبل الرفع
  Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  RxString uploadedImageUrl = ''.obs;
  String? _pickedPath;

  // ===== image helpers =====
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        imageBytes.value = bytes;
        _pickedPath = pickedFile.path;
        update(['transfer_proof_image']);
      }
    } catch (e) {
      print('pickImage error: $e');
      _showSnackbar('خطأ', 'فشل اختيار الصورة', true);
    }
  }

  void removeImage() {
    imageBytes.value = null;
    uploadedImageUrl.value = '';
    _pickedPath = null;
    update(['transfer_proof_image']);
  }

  Future<void> loadImageFromUrl(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        imageBytes.value = res.bodyBytes;
        _pickedPath = null;
        update(['transfer_proof_image']);
      }
    } catch (e) {
      print('loadImageFromUrl error: $e');
    }
  }

  // ===== upload helper (images[] style, returns uploaded url) =====
  Future<String> uploadImageToServer() async {
    if (imageBytes.value == null) throw Exception('لا توجد صورة للرفع');
    isUploading.value = true;
    try {
      final ext = _pickedPath != null && _pickedPath!.contains('.')
          ? _pickedPath!.split('.').last
          : 'jpg';
      final filename = 'transfer_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final mimeType = lookupMimeFromExtension(ext) ?? 'image/jpeg';
      final parts = mimeType.split('/');

      var request = http.MultipartRequest('POST', Uri.parse(uploadApiUrl));
      request.files.add(
        http.MultipartFile.fromBytes(
          'images[]',
          imageBytes.value!,
          filename: filename,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      final streamed = await request.send();
      final respString = await streamed.stream.bytesToString();

      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        final jsonData = json.decode(respString);
        if (jsonData is Map && jsonData['image_urls'] != null) {
          uploadedImageUrl.value =
              (List<String>.from(jsonData['image_urls'])).first;
          return uploadedImageUrl.value;
        } else if (jsonData is Map && jsonData['image_url'] != null) {
          uploadedImageUrl.value = jsonData['image_url'].toString();
          return uploadedImageUrl.value;
        } else if (jsonData is String && jsonData.isNotEmpty) {
          uploadedImageUrl.value = jsonData;
          return uploadedImageUrl.value;
        } else {
          throw Exception('رد غير متوقع من نقطة الرفع: $jsonData');
        }
      } else {
        throw Exception(
            'فشل رفع الصورة: ${streamed.statusCode} => $respString');
      }
    } finally {
      isUploading.value = false;
    }
  }

  // ===== fetch proofs (supports filters & pagination) =====
  /// filters: userId, status, walletId
  /// pagination: page (1-based) & perPage
  Future<void> fetchProofs({
    int? page,
    int perPage = 50,
    int? userId,
    String? status,
    int? walletId,
    bool append = false,
  }) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/transfer-proofs').replace(
        queryParameters: {
          if (page != null) 'page': page.toString(),
          'per_page': perPage.toString(),
          if (userId != null) 'user_id': userId.toString(),
          if (status != null) 'status': status,
          if (walletId != null) 'wallet_id': walletId.toString(),
        },
      );

      final headers = <String, String>{'Accept': 'application/json'};
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        dynamic data = (body is Map && body['data'] != null) ? body['data'] : body;
        List<dynamic> items = [];
        // if paginated response with meta, body['data'] is list -> handled above
        if (data is List) {
          items = data;
        } else if (data is Map && data.isNotEmpty) {
          // sometimes server returns object for single item
          items = [data];
        } else if (body is Map && body['data'] is Map) {
          items = [body['data']];
        } else {
          items = [];
        }

        final parsed = items
            .map((e) => TransferProofModel.fromJson(e as Map<String, dynamic>))
            .toList();

        if (append) {
          proofs.addAll(parsed);
        } else {
          proofs.value = parsed;
        }
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
      }
    } catch (e) {
      print('fetchProofs Exception: $e');
      _showSnackbar('استثناء', 'حدث خطأ عند جلب الأدلة', true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Convenience: fetch proofs for a single user (with optional pagination)
  Future<void> fetchProofsByUser({
    required int userId,
    int? page,
    int perPage = 50,
    bool append = false,
  }) async {
    await fetchProofs(
      page: page,
      perPage: perPage,
      userId: userId,
      append: append,
    );
  }

  // ===== create proof =====
  /// supports (imageBytes -> upload first) OR direct multipart file OR external url
  Future<bool> createProof({
    required int bankAccountId,
    required int walletId,
    required double amount,
    String? sourceAccountNumber,
    File? proofFile,
    String? proofImageUrl,
  }) async {
    isSaving.value = true;
    try {
      // A: imageBytes -> upload, then JSON create
      if (imageBytes.value != null) {
        try {
          final url = await uploadImageToServer();
          if (url.isEmpty) {
            _showSnackbar('خطأ', 'فشل الحصول على رابط الصورة بعد الرفع', true);
            return false;
          }
          final uri = Uri.parse('$_baseUrl/transfer-proofs');
          final headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          };
          if (authToken != null) headers['Authorization'] = 'Bearer $authToken';
          final res = await http.post(
            uri,
            headers: headers,
            body: json.encode({
              'bank_account_id': bankAccountId,
              'wallet_id': walletId,
              'amount': amount,
              if (sourceAccountNumber != null)
                'source_account_number': sourceAccountNumber,
              'proof_image': url,
            }),
          );

          if (res.statusCode == 201 || res.statusCode == 200) {
            final body = json.decode(res.body) as Map<String, dynamic>;
            final data = body['data'] ?? body;
            final model =
                TransferProofModel.fromJson(data as Map<String, dynamic>);
            proofs.insert(0, model);
            _showSnackbar('نجاح', 'تم رفع دليل التحويل', false);
            removeImage();
            return true;
          } else {
            print('createProof (via uploadedImageUrl) failed: ${res.body}');
            _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
            return false;
          }
        } catch (e) {
          print('createProof.upload error: $e');
          _showSnackbar('استثناء', 'فشل رفع الصورة: $e', true);
          return false;
        }
      }

      // B: direct multipart with file
      if (proofFile != null) {
        final uri = Uri.parse('$_baseUrl/transfer-proofs');
        final request = http.MultipartRequest('POST', uri);
        request.headers['Accept'] = 'application/json';
        if (authToken != null) {
          request.headers['Authorization'] = 'Bearer $authToken';
        }
        request.fields['bank_account_id'] = bankAccountId.toString();
        request.fields['wallet_id'] = walletId.toString();
        request.fields['amount'] = amount.toString();
        if (sourceAccountNumber != null) {
          request.fields['source_account_number'] = sourceAccountNumber;
        }

        final mimeType = lookupMimeType(proofFile.path) ?? 'application/octet-stream';
        final parts = mimeType.split('/');
        request.files.add(await http.MultipartFile.fromPath(
          'proof_file',
          proofFile.path,
          contentType: MediaType(parts[0], parts[1]),
        ));

        final streamed = await request.send();
        final res = await http.Response.fromStream(streamed);
        if (res.statusCode == 201 || res.statusCode == 200) {
          final body = json.decode(res.body) as Map<String, dynamic>;
          final data = body['data'] ?? body;
          final model = TransferProofModel.fromJson(data as Map<String, dynamic>);
          proofs.insert(0, model);
          _showSnackbar('نجاح', 'تم رفع دليل التحويل', false);
          return true;
        } else {
          print('createProof multipart failed: ${res.body}');
          _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
          return false;
        }
      }

      // C: external image url (JSON)
      if (proofImageUrl != null && proofImageUrl.isNotEmpty) {
        final uri = Uri.parse('$_baseUrl/transfer-proofs');
        final headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        };
        if (authToken != null) headers['Authorization'] = 'Bearer $authToken';
        final res = await http.post(
          uri,
          headers: headers,
          body: json.encode({
            'bank_account_id': bankAccountId,
            'wallet_id': walletId,
            'amount': amount,
            if (sourceAccountNumber != null)
              'source_account_number': sourceAccountNumber,
            'proof_image': proofImageUrl,
          }),
        );

        if (res.statusCode == 201 || res.statusCode == 200) {
          final body = json.decode(res.body) as Map<String, dynamic>;
          final data = body['data'] ?? body;
          final model = TransferProofModel.fromJson(data as Map<String, dynamic>);
          proofs.insert(0, model);
          _showSnackbar('نجاح', 'تم إضافة دليل التحويل', false);
          return true;
        } else {
          print('createProof (external url) failed: ${res.body}');
          _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
          return false;
        }
      }

      _showSnackbar('تحذير', 'لم تقدم صورة أو ملف أو رابط للدليل', true);
      return false;
    } catch (e) {
      print('createProof Exception: $e');
      _showSnackbar('استثناء', 'حدث خطأ أثناء رفع الدليل: $e', true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ===== fetch single proof =====
  Future<void> fetchProof(int id) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/transfer-proofs/$id');
      final headers = {'Accept': 'application/json'};
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';
      final res = await http.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        current.value = TransferProofModel.fromJson(data as Map<String, dynamic>);
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
      }
    } catch (e) {
      print('fetchProof Exception: $e');
      _showSnackbar('استثناء', 'حدث خطأ عند جلب الدليل', true);
    } finally {
      isLoading.value = false;
    }
  }

  // ===== approve proof =====
  Future<bool> approveProof(int id) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/transfer-proofs/$id/approve');
      final headers = {'Accept': 'application/json'};
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final res = await http.post(uri, headers: headers);
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        final model = TransferProofModel.fromJson(data as Map<String, dynamic>);

        // تحديث القوائم محلياً
        final idx = proofs.indexWhere((p) => p.id == model.id);
        if (idx != -1) proofs[idx] = model;
        if (current.value?.id == model.id) current.value = model;

        _showSnackbar('نجاح', 'تمت الموافقة وشحن المحفظة', false);
        return true;
      } else {
        print('approveProof failed: ${res.statusCode} => ${res.body}');
        _showSnackbar('خطأ', 'فشل الموافقة: ${res.statusCode}', true);
        return false;
      }
    } catch (e) {
      print('approveProof Exception: $e');
      _showSnackbar('استثناء', 'حدث خطأ أثناء الموافقة', true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ===== reject proof (with optional comment) =====
  Future<bool> rejectProof(int id, {String? comment}) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/transfer-proofs/$id/reject');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final res = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          if (comment != null) 'comment': comment,
        }),
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        final model = TransferProofModel.fromJson(data as Map<String, dynamic>);

        final idx = proofs.indexWhere((p) => p.id == model.id);
        if (idx != -1) proofs[idx] = model;
        if (current.value?.id == model.id) current.value = model;

        _showSnackbar('نجاح', 'تم رفض الدليل', false);
        return true;
      } else {
        print('rejectProof failed: ${res.statusCode} => ${res.body}');
        _showSnackbar('خطأ', 'فشل الرفض: ${res.statusCode}', true);
        return false;
      }
    } catch (e) {
      print('rejectProof Exception: $e');
      _showSnackbar('استثناء', 'حدث خطأ أثناء الرفض', true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ===== delete proof =====
  Future<bool> deleteProof(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/transfer-proofs/$id');
      final headers = {'Accept': 'application/json'};
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final res = await http.delete(uri, headers: headers);
      if (res.statusCode == 200) {
        proofs.removeWhere((p) => p.id == id);
        if (current.value?.id == id) current.value = null;
        _showSnackbar('نجاح', 'تم حذف الدليل', false);
        return true;
      } else {
        print('deleteProof failed: ${res.statusCode} => ${res.body}');
        _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
        return false;
      }
    } catch (e) {
      print('deleteProof Exception: $e');
      _showSnackbar('استثناء', 'حدث خطأ أثناء الحذف', true);
      return false;
    }
  }

  // ===== helpers =====
  String? lookupMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }

  String? lookupMimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return null;
    }
  }

  void _showSnackbar(String title, String message, bool isError) {
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        colorText: Colors.white,
        borderRadius: 10,
        margin: EdgeInsets.all(12),
        duration: Duration(seconds: isError ? 4 : 3),
        icon: Icon(isError ? Icons.error_outline : Icons.check_circle,
            color: Colors.white),
        shouldIconPulse: true,
        dismissDirection: DismissDirection.horizontal,
      );
    } catch (e) {
      // ignore snackbar errors when UI not ready
      print('snackbar error: $e');
    }
  }
}
