// lib/controllers/posts_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';

import '../core/data/model/Post.dart';

class PostsController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
  final String uploadApiUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api/upload';

  // reactive state
  RxList<Post> postsList = <Post>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxBool isDeleting = false.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMorePosts = true.obs;

  // image handling
  Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  RxString uploadedImageUrl = ''.obs;
  RxString imageUploadError = ''.obs;

  // form fields
  RxString formTitle = ''.obs;
  RxString formSlug = ''.obs;
  RxString formExcerpt = ''.obs;
  RxString formContentHtml = ''.obs;
  RxString formStatus = 'draft'.obs;
  RxString formMetaTitle = ''.obs;
  RxString formMetaDescription = ''.obs;
  RxInt editingPostId = 0.obs;

  // search and filter
  RxString searchQuery = ''.obs;
  RxString statusFilter = 'الكل'.obs;

  final translator = GoogleTranslator();
  final ImagePicker _imagePicker = ImagePicker();

  // cache for better performance
  final Map<int, Post> _postCache = {};
  final Map<String, Uint8List> _imageCache = {};

  // debounce timer for search
  Timer? _searchDebounce;

  @override
  void onClose() {
    // تنظيف الذاكرة عند إغلاق الكونترولر
    _postCache.clear();
    _imageCache.clear();

    // إلغاء أي عملية بحث معلقة
    _searchDebounce?.cancel();

    super.onClose();
  }

  // ---------------- image handling ----------------
  Future<void> pickImage() async {
    try {
      imageUploadError.value = '';
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();

        // التحقق من حجم الصورة (5MB كحد أقصى)
        if (bytes.length > 5 * 1024 * 1024) {
          imageUploadError.value = 'حجم الصورة كبير جداً. الحد الأقصى 5MB';
          return;
        }

        imageBytes.value = bytes;
        update(['post_image']);
      }
    } catch (e) {
      imageUploadError.value = 'فشل في اختيار الصورة: ${e.toString()}';
      _showSnackbar('خطأ', 'فشل في اختيار الصورة', true);
    }
  }

  void removeImage() {
    imageBytes.value = null;
    uploadedImageUrl.value = '';
    imageUploadError.value = '';
    update(['post_image']);
  }

  Future<void> uploadImageToServer() async {
    if (imageBytes.value == null) {
      imageUploadError.value = 'لا توجد صورة لتحميلها';
      return;
    }

    try {
      imageUploadError.value = '';

      // محاولة التحقق من نوع الصورة
      final allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
      final imageType = _getImageType(imageBytes.value!);

      if (!allowedTypes.contains(imageType)) {
        imageUploadError.value = 'نوع الصورة غير مدعوم';
        throw Exception('نوع الصورة غير مدعوم: $imageType');
      }

      final uri = Uri.parse(uploadApiUrl);

      // محاولة إرسال الصورة بمختلف الأسماء المحتملة (بعض الـ APIs تنتظر حقول مختلفة)
      final fieldNames = ['image', 'images[]', 'file', 'upload'];

      String? foundUrl;
      String lastError = '';

      for (final fieldName in fieldNames) {
        try {
          final request = http.MultipartRequest('POST', uri);
          request.files.add(http.MultipartFile.fromBytes(
            fieldName,
            imageBytes.value!,
            filename: 'post_${DateTime.now().millisecondsSinceEpoch}.${imageType.split('/').last}',
          ));

          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 200 || response.statusCode == 201) {
            final jsonBody = _safeJsonDecode(response.body);
            final String? imageUrl = _extractImageUrlFromResponse(jsonBody);
            if (imageUrl != null && imageUrl.isNotEmpty) {
              foundUrl = imageUrl;
              break;
            } else {
              lastError = 'لم يتم العثور على رابط في الرد للحقل $fieldName';
            }
          } else {
            lastError = 'HTTP ${response.statusCode} عند محاولة الحقل $fieldName';
          }
        } catch (e) {
          lastError = e.toString();
          // استمر إلى المحاولة التالية
        }
      }

      if (foundUrl == null) {
        imageUploadError.value = 'فشل تحميل الصورة: $lastError';
        throw Exception('Upload failed: $lastError');
      }

      uploadedImageUrl.value = foundUrl;
      _imageCache[foundUrl] = imageBytes.value!;
    } catch (e) {
      imageUploadError.value = 'فشل تحميل الصورة: ${e.toString()}';
      _showSnackbar('خطأ', 'فشل تحميل الصورة', true);
      rethrow;
    }
  }

  String _getImageType(Uint8List bytes) {
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    } else if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    } else if (bytes.length >= 3 && bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return 'image/gif';
    } else if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return 'application/octet-stream';
  }

  dynamic _safeJsonDecode(String body) {
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  String? _extractImageUrlFromResponse(dynamic jsonBody) {
    if (jsonBody is Map<String, dynamic>) {
      if (jsonBody['image_url'] != null) return jsonBody['image_url'].toString();
      if (jsonBody['url'] != null) return jsonBody['url'].toString();
      if (jsonBody['path'] != null) return jsonBody['path'].toString();
      if (jsonBody['location'] != null) return jsonBody['location'].toString();

      if (jsonBody['data'] is Map) {
        final data = jsonBody['data'] as Map;
        if (data['url'] != null) return data['url'].toString();
        if (data['image_url'] != null) return data['image_url'].toString();
        if (data['path'] != null) return data['path'].toString();
      }

      if (jsonBody['image_urls'] is List && (jsonBody['image_urls'] as List).isNotEmpty) {
        return (jsonBody['image_urls'] as List).first.toString();
      }
    } else if (jsonBody is String) {
      // بعض الـ APIs ترجع URL كنص خام
      if (jsonBody.startsWith('http')) return jsonBody;
    }
    return null;
  }

  // ---------------- fetch posts with pagination ----------------
  Future<void> fetchPosts({int page = 1, int perPage = 20, bool loadMore = false}) async {
    if (isLoading.value && !loadMore) return;

    isLoading.value = true;
    try {
      final params = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (searchQuery.value.isNotEmpty) params['q'] = searchQuery.value;
      if (statusFilter.value != 'الكل') params['status'] = statusFilter.value;

      final uri = Uri.parse('$_baseUrl/admin/posts').replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonBody = _safeJsonDecode(response.body);
        List<dynamic> postsData = [];

        if (jsonBody is Map && jsonBody.containsKey('data')) {
          final data = jsonBody['data'];
          if (data is List) postsData = data;
          else if (data is Map && data['data'] is List) postsData = data['data'];

          // التحقق من وجود المزيد من الصفحات
          if (jsonBody is Map && jsonBody['meta'] is Map) {
            final meta = jsonBody['meta'] as Map;
            final current = meta['current_page'] ?? page;
            final lastPage = meta['last_page'] ?? (meta['total'] != null && meta['per_page'] != null ? ((meta['total'] / meta['per_page']).ceil()) : page);
            hasMorePosts.value = (current as int) < (lastPage as int);
            currentPage.value = current as int;
          }
        } else if (jsonBody is List) {
          postsData = jsonBody;
          hasMorePosts.value = postsData.length >= perPage;
        } else if (jsonBody is Map && jsonBody.isNotEmpty) {
          // maybe server returned a single post object
          postsData = [jsonBody];
          hasMorePosts.value = postsData.length >= perPage;
        }

        final newPosts = postsData.map<Post>((item) {
          final map = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
          final post = Post.fromJson(map);
          _postCache[post.id] = post;
          return post;
        }).toList();

        if (loadMore && page > 1) {
          postsList.addAll(newPosts);
          currentPage.value = page;
        } else {
          postsList.value = newPosts;
          currentPage.value = page;
        }
      } else {
        throw Exception('خطأ في الاتصال بالسيرفر (${response.statusCode})');
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب المنشورات: ${e.toString()}', true);
      // في حالة خطأ لا نغيّر محتويات القائمة الحالية لكنها قد تبقى كما هي
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMorePosts({int perPage = 20}) async {
    if (hasMorePosts.value && !isLoading.value) {
      await fetchPosts(page: currentPage.value + 1, perPage: perPage, loadMore: true);
    }
  }

  Future<Post?> fetchPost(int id, {bool forceRefresh = false}) async {
    // التحقق من الكاش أولاً
    if (!forceRefresh && _postCache.containsKey(id)) {
      return _postCache[id];
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/posts/$id'));

      if (response.statusCode == 200) {
        final jsonBody = _safeJsonDecode(response.body);
        Post? post;

        if (jsonBody is Map && jsonBody['status'] == 'success' && jsonBody['data'] != null) {
          post = Post.fromJson(Map<String, dynamic>.from(jsonBody['data']));
        } else if (jsonBody is Map && jsonBody['data'] is Map) {
          post = Post.fromJson(Map<String, dynamic>.from(jsonBody['data']));
        } else if (jsonBody is Map) {
          post = Post.fromJson(Map<String, dynamic>.from(jsonBody));
        }

        if (post != null) {
          _postCache[id] = post;
          return post;
        }
      }
    } catch (e) {
      debugPrint('fetchPost error: $e');
    }
    return null;
  }

  // ---------------- content processing ----------------
  String _cleanHtmlContent(String html) {
    // تنظيف المحتوى من الأنماط غير المرغوب فيها
    String cleaned = html.replaceAll(
      RegExp(r'<style[^>]*>[\s\S]*?<\/style>', caseSensitive: false),
      '',
    );

    // جعل الصور متجاوبة
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'<img([^>]*)>', caseSensitive: false),
      (Match m) {
        String attributes = m.group(1) ?? '';
        if (!attributes.contains('style')) {
          return '<img$attributes style="max-width: 100%; height: auto;">';
        } else if (!attributes.contains('max-width')) {
          // إضافة max-width داخل style إن لم يكن موجوداً
          final parts = attributes.split('style="');
          if (parts.length > 1) {
            final rest = parts.sublist(1).join('style="');
            final newStyle = 'style="${rest.replaceFirst('"', '')} max-width: 100%; height: auto;"';
            return '<img${parts.first}$newStyle>';
          }
        }
        return m.group(0) ?? '';
      },
    );

    return cleaned;
  }

  // ---------------- helpers for slug/meta ----------------
  Future<String> _generateSlug(String title) async {
    try {
      final translated = await translator.translate(title, from: 'ar', to: 'en');
      String text = translated.text.isNotEmpty ? translated.text : title;

      text = text.toLowerCase();
      text = text.replaceAll(RegExp(r"[^\w\s\-]"), '');
      text = text.replaceAll(RegExp(r"\s+"), '-');
      text = text.replaceAll(RegExp(r"^-+|-+$"), '');

      if (text.isEmpty) text = 'post-${DateTime.now().millisecondsSinceEpoch}';
      if (text.length > 120) text = text.substring(0, 120);

      return text;
    } catch (e) {
      debugPrint('slug generation error: $e');
      String fallback = title.replaceAll(RegExp(r'\s+'), '-').replaceAll(RegExp(r"[^\p{Arabic}\p{L}\p{N}\-]", unicode: true), '');
      if (fallback.isEmpty) fallback = 'post-${DateTime.now().millisecondsSinceEpoch}';
      return fallback.toLowerCase();
    }
  }

  String _stripHtml(String? html) {
    if (html == null || html.isEmpty) return '';
    final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final collapsed = withoutTags.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed;
  }

  String _generateMetaTitle(String title) {
    final base = title.trim();
    if (base.length <= 60) return base;
    return base.substring(0, 57) + '...';
  }

  String _generateMetaDescription(String? content, String title) {
    final text = _stripHtml(content);
    if (text.isEmpty) {
      final maxTitleLength = 120;
      final t = title.length > maxTitleLength ? title.substring(0, maxTitleLength - 3) + '...' : title;
      return t;
    }

    final firstSentenceMatch = RegExp(r'(.{60,300}?[\.\!\?])', dotAll: true).firstMatch(text);
    String candidate = firstSentenceMatch?.group(0) ?? text;
    candidate = candidate.replaceAll(RegExp(r'\s+'), ' ').trim();

    int maxLength = 160;
    if (candidate.length > maxLength) {
      candidate = candidate.substring(0, maxLength - 3).trim() + '...';
    }
    return candidate;
  }

  // ========== Create post ==========
  Future<bool> createPost() async {
    if (formTitle.value.trim().isEmpty) {
      _showSnackbar('تحذير', 'أدخل عنوانًا للمنشور', true);
      return false;
    }

    isSaving.value = true;
    try {
      // تحميل الصورة إذا وجدت
      if (imageBytes.value != null && uploadedImageUrl.value.isEmpty) {
        await uploadImageToServer();
      }

      final slug = formSlug.value.trim().isEmpty ? await _generateSlug(formTitle.value) : formSlug.value.trim();
      final metaTitle = formMetaTitle.value.trim().isEmpty ? _generateMetaTitle(formTitle.value) : formMetaTitle.value.trim();
      final metaDescription = formMetaDescription.value.trim().isEmpty ? _generateMetaDescription(formContentHtml.value, formTitle.value) : formMetaDescription.value.trim();
      final cleanedContent = _cleanHtmlContent(formContentHtml.value);

     final payload = {
  'title': formTitle.value.trim(),
  'slug': slug,
  'category_id': formCategoryId.value == 0 ? null : formCategoryId.value, // أضف هذا السطر
  'excerpt': formExcerpt.value.isEmpty ? null : formExcerpt.value.trim(),
  'content': cleanedContent,
  'featured_image': uploadedImageUrl.value.isNotEmpty ? uploadedImageUrl.value : null,
  'meta_title': metaTitle,
  'meta_description': metaDescription,
  'status': formStatus.value,
};

      final uri = Uri.parse('$_baseUrl/admin/posts');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.post(uri, headers: headers, body: json.encode(payload));

      final contentType = response.headers['content-type'] ?? '';
      final isJson = contentType.contains('application/json') || response.body.trim().startsWith('{') || response.body.trim().startsWith('[');

      if (!isJson) {
        _showDetailedSnackbar(
          '❌ استجابة غير متوقعة',
          'الخادم أعاد HTML أو نص غير JSON. تحقق من إعدادات الخادم/المصادقة.',
          'HTTP ${response.statusCode}\nContent-Type: $contentType\nBody start: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}',
          true,
        );
        return false;
      }

      final body = json.decode(response.body);

      if (response.statusCode == 201 || (response.statusCode == 200 && (body['status'] == 'success' || body['data'] != null))) {
        _showSnackbar('نجاح', 'تم إنشاء المنشور بنجاح', false);
        await fetchPosts();
        resetForm();
        return true;
      } else {
        final errorMessage = body['message'] ?? body['error'] ?? 'فشل إنشاء المنشور';
        String errorDetails = '';
        if (body['errors'] != null && body['errors'] is Map) {
          final errors = body['errors'] as Map;
          errorDetails = '\nالأخطاء: ${errors.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
        }
        _showDetailedSnackbar(
          '❌ فشل إنشاء المنشور',
          errorMessage,
          'كود الخطأ: ${response.statusCode}$errorDetails',
          true,
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('خطأ في createPost: $e\n$stackTrace');
      _showDetailedSnackbar(
        '❌ خطأ تقني',
        'حدث خطأ أثناء إنشاء المنشور',
        'التفاصيل: ${e.toString()}\nيرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        true,
      );
      return false;
    } finally {
      isSaving.value = false;
      _closeLoadingDialog();
    }
  }

  void _showDetailedSnackbar(String title, String subtitle, String details, bool isError) {
    Get.snackbar(
      title,
      '$subtitle\n$details',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      duration: Duration(seconds: isError ? 8 : 5),
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      dismissDirection: DismissDirection.horizontal,
      isDismissible: true,
      maxWidth: 500,
    );
  }

  Future<bool> updatePost(int id) async {
    if (id <= 0) {
      _showSnackbar('خطأ', 'لا يوجد منشور قيد التعديل', true);
      return false;
    }

    isSaving.value = true;
    try {
      final cleanedContent = _cleanHtmlContent(formContentHtml.value);

     final Map<String, dynamic> payload = {
  'title': formTitle.value.trim(),
  'excerpt': formExcerpt.value.isEmpty ? null : formExcerpt.value.trim(),
  'content': cleanedContent,
  'status': formStatus.value,
  'slug': formSlug.value.trim().isEmpty ? null : formSlug.value.trim(),
  'meta_title': formMetaTitle.value.trim().isEmpty ? null : formMetaTitle.value.trim(),
  'meta_description': formMetaDescription.value.trim().isEmpty ? null : formMetaDescription.value.trim(),
  'category_id': formCategoryId.value == 0 ? null : formCategoryId.value, // أضف هذا السطر
};

      payload.removeWhere((k, v) => v == null);

      final uri = Uri.parse('$_baseUrl/admin/posts/$id');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.put(uri, headers: headers, body: json.encode(payload)).timeout(Duration(seconds: 20));

      final bodyText = response.body ?? '';
      final contentType = response.headers['content-type'] ?? '';
      final isJson = contentType.contains('application/json') || bodyText.trim().startsWith('{') || bodyText.trim().startsWith('[');

      if (!isJson) {
        _showDetailedSnackbar('خطأ', 'الخادم أعاد محتوى غير JSON', 'HTTP ${response.statusCode}\nContent-Type: $contentType\nBody: ${bodyText.length > 800 ? bodyText.substring(0, 800) + "..." : bodyText}', true);
        return false;
      }

      final body = json.decode(bodyText);

      if (response.statusCode == 200 && (body['status'] == 'success' || body['data'] != null)) {
        _showSnackbar('نجاح', 'تم تحديث المنشور بنجاح', false);

        if (_postCache.containsKey(id)) {
          final updatedPost = Post.fromJson(Map<String, dynamic>.from(body['data'] ?? body));
          _postCache[id] = updatedPost;
        }

        await fetchPosts();
        resetForm();
        return true;
      } else {
        final errorMessage = body['message'] ?? body['error'] ?? 'فشل تحديث المنشور';
        String errorDetails = '';
        if (body['errors'] != null && body['errors'] is Map) {
          final errors = body['errors'] as Map;
          errorDetails = '\nالأخطاء: ${errors.entries.map((e) => '${e.key}: ${e.value}').join(', ')}';
        }
        _showDetailedSnackbar('خطأ تحديث', errorMessage, 'HTTP ${response.statusCode}$errorDetails', true);
        return false;
      }
    } on TimeoutException {
      _showSnackbar('خطأ', 'انتهى وقت الاتصال مع الخادم (timeout). حاول لاحقًا', true);
      return false;
    } catch (e, st) {
      debugPrint('updatePost: exception: $e\n$st');
      _showDetailedSnackbar('خطأ', 'حدث خطأ أثناء تحديث المنشور', e.toString(), true);
      return false;
    } finally {
      isSaving.value = false;
      editingPostId.value = 0;
    }
  }

  void _closeLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<bool> deletePost(int id) async {
    isDeleting.value = true;
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/admin/posts/$id'));
      final bodyDecoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 && bodyDecoded is Map && (bodyDecoded['status'] == 'success' || bodyDecoded['success'] == true)) {
        _showSnackbar('نجاح', 'تم حذف المنشور', false);
        _postCache.remove(id);
        await fetchPosts();
        return true;
      } else {
        final errorMessage = bodyDecoded is Map ? (bodyDecoded['message'] ?? bodyDecoded['error'] ?? 'فشل حذف المنشور') : 'فشل حذف المنشور';
        _showSnackbar('خطأ', errorMessage, true);
        return false;
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء حذف المنشور: ${e.toString()}', true);
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> togglePublish(int id) async {
    try {
      final response = await http.patch(Uri.parse('$_baseUrl/admin/posts/$id/toggle-publish'));
      final bodyDecoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 && bodyDecoded is Map && (bodyDecoded['status'] == 'success' || bodyDecoded['success'] == true)) {
        _showSnackbar('نجاح', 'تم تغيير حالة النشر', false);

        if (_postCache.containsKey(id) && bodyDecoded['data'] != null) {
          final updatedPost = Post.fromJson(Map<String, dynamic>.from(bodyDecoded['data']));
          _postCache[id] = updatedPost;
        }

        await fetchPosts();
        return true;
      } else {
        final errorMessage = bodyDecoded is Map ? (bodyDecoded['message'] ?? bodyDecoded['error'] ?? 'فشل تغيير الحالة') : 'فشل تغيير الحالة';
        _showSnackbar('خطأ', errorMessage, true);
        return false;
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء تغيير حالة النشر: ${e.toString()}', true);
      return false;
    }
  }

  // ---------------- form management ----------------
  void populateFormFromPost(Post post) {
    editingPostId.value = post.id;
    formTitle.value = post.title;
    formSlug.value = post.slug;
    formExcerpt.value = post.excerpt ?? '';
    formContentHtml.value = post.content ?? '';
    formStatus.value = post.status;
    formMetaTitle.value = post.metaTitle ?? '';
    formMetaDescription.value = post.metaDescription ?? '';
    uploadedImageUrl.value = post.featuredImage ?? '';
    imageBytes.value = null;

    update(['post_form']);
  }

  void resetForm() {
    imageBytes.value = null;
    uploadedImageUrl.value = '';
    imageUploadError.value = '';
    formTitle.value = '';
    formSlug.value = '';
    formExcerpt.value = '';
    formContentHtml.value = '';
    formStatus.value = 'draft';
    formMetaTitle.value = '';
    formMetaDescription.value = '';
    editingPostId.value = 0;

    update(['post_form', 'post_image']);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;

    // إلغاء أي عملية بحث سابقة
    _searchDebounce?.cancel();

    // إعداد بحث جديد مع تأخير
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchPosts();
    });
  }

  void updateStatusFilter(String status) {
    statusFilter.value = status;
    fetchPosts();
  }

  // ---------------- helper methods ----------------
  void _showSnackbar(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(15),
      duration: Duration(seconds: isError ? 4 : 3),
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // تحسين الأداء: تحميل الصور مع الكاش
  Future<Uint8List?> getCachedImage(String url) async {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _imageCache[url] = response.bodyBytes;
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('Failed to cache image: $e');
    }

    return null;
  }

  // تنظيف الذاكرة
  void clearCache() {
    _postCache.clear();
    _imageCache.clear();
  }

  /// تحديث حقول SEO للمنشور (slug, metaTitle, metaDescription)
  Future<bool> updatePostSeo(int postId, {String? slug, String? metaTitle, String? metaDescription}) async {
    if (postId <= 0) {
      _showSnackbar('خطأ', 'معرّف المنشور غير صالح', true);
      return false;
    }

    final Map<String, dynamic> payload = {};
    if (slug != null) payload['slug'] = slug;
    if (metaTitle != null) payload['meta_title'] = metaTitle;
    if (metaDescription != null) payload['meta_description'] = metaDescription;

    if (payload.isEmpty) {
      _showSnackbar('خطأ', 'لم تُرسل أي حقل للتحديث', true);
      return false;
    }

    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/admin/posts/$postId/seo');
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      debugPrint('updatePostSeo status: ${response.statusCode}');
      debugPrint('updatePostSeo body: ${response.body}');

      final bodyDecoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 && bodyDecoded is Map && (bodyDecoded['status'] == 'success' || bodyDecoded['data'] != null)) {
        _showSnackbar('نجاح', bodyDecoded['message'] ?? 'تم تحديث SEO', false);

        await fetchPost(postId, forceRefresh: true);
        return true;
      } else {
        final msg = bodyDecoded is Map ? (bodyDecoded['message'] ?? 'فشل تحديث SEO') : 'فشل تحديث SEO';
        String details = '';
        if (bodyDecoded is Map && bodyDecoded['errors'] is Map) {
          details = '\n' + (bodyDecoded['errors'] as Map).entries.map((e) => '${e.key}: ${e.value}').join('\n');
        }
        _showDetailedSnackbar('فشل', msg, details, true);
        return false;
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء التحديث: ${e.toString()}', true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }


  final RxList<PostCategoryModel> items = <PostCategoryModel>[].obs;
  

  // صفحــة/فلترة
  int lastPage = 1;
  int perPageDefault = 20;

  /// Fetch single category
 // Fetch categories
  /// - supports query params: q (search), page, per_page (if page omitted returns all)
  Future<void> fetchCategories({String? q, int? page, int perPage = 20}) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/post-categories').replace(queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (page != null) 'page': page.toString(),
        'per_page': perPage.toString(),
      });

      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        dynamic data;
        // handle various response shapes
        if (body is Map && body['data'] != null) {
          data = body['data'];
        } else {
          data = body;
        }

        if (data is List) {
          items.value = data.map((e) => PostCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (data is Map && data.containsKey('data') && data['data'] is List) {
          // some pagination style
          final list = data['data'] as List;
          items.value = list.map((e) => PostCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          // fallback clear
          items.clear();
          _showSnack('خطأ', 'البيانات المستلمة غير متوقعة', true);
        }

        // if server returned pagination meta inside a map (common), try to read it
        if (body is Map) {
          final meta = body['meta'] ?? body['pagination'] ?? body;
          if (meta is Map && meta['last_page'] != null) {
            lastPage = (meta['last_page'] is int) ? meta['last_page'] : int.tryParse(meta['last_page'].toString()) ?? lastPage;
            currentPage = (meta['current_page'] is int) ? meta['current_page'] : int.tryParse(meta['current_page'].toString()) ?? currentPage;
          }
        }
      } else {
        _showSnack('خطأ', 'فشل جلب التصنيفات (${res.statusCode})', true);
      }
    } catch (e) {
      _showSnack('استثناء', 'حدث خطأ عند جلب التصنيفات: $e', true);
    } finally {
      isLoading.value = false;
    }
  }
  RxInt formCategoryId = 0.obs;
// snack helper
  void _showSnack(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      margin: EdgeInsets.all(12),
      borderRadius: 8,
      duration: Duration(seconds: isError ? 4 : 3),
    );
  }


  // في قسم الـ Rx variables أضف:

// دالة لتعيين التصنيف
void setFormCategoryId(int? categoryId) {
  formCategoryId.value = categoryId ?? 0;
}

// دالة لجلب التصنيف الحالي
int? getFormCategoryId() {
  return formCategoryId.value == 0 ? null : formCategoryId.value;
}

}
