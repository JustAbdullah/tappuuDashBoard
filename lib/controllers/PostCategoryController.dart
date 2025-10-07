// lib/core/controllers/post_category_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../core/data/model/PostCategoryModel.dart';


class PostCategoryController extends GetxController {
  // عدّل ال-base URL حسب بيئتك
  static const String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  final RxList<PostCategoryModel> items = <PostCategoryModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  // صفحــة/فلترة
  int currentPage = 1;
  int lastPage = 1;
  int perPageDefault = 20;

  // simple text controller for create/update forms (optional helper)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController slugController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    slugController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Fetch categories
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

  /// Fetch single category
  Future<PostCategoryModel?> fetchCategory(int id) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/post-categories/$id');
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        dynamic data;
        if (body is Map && body['data'] != null) data = body['data'];
        else data = body;

        if (data is Map) {
          final model = PostCategoryModel.fromJson(Map<String, dynamic>.from(data));
          return model;
        } else {
          _showSnack('خطأ', 'رد غير متوقع عند جلب التصنيف', true);
          return null;
        }
      } else {
        _showSnack('خطأ', 'فشل جلب التصنيف (${res.statusCode})', true);
        return null;
      }
    } catch (e) {
      _showSnack('استثناء', 'حدث خطأ عند جلب التصنيف: $e', true);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create category
  Future<bool> createCategory({required String name, String? slug, String? description}) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/post-categories');
      final payload = <String, dynamic>{
        'name': name,
        if (slug != null) 'slug': slug,
        if (description != null) 'description': description,
      };

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = json.decode(res.body);
        dynamic data = (body is Map && body['data'] != null) ? body['data'] : body;
        if (data is Map) {
          final model = PostCategoryModel.fromJson(Map<String, dynamic>.from(data));
          items.insert(0, model);
          _showSnack('نجاح', 'تم إنشاء التصنيف', false);
          return true;
        } else {
          _showSnack('نجاح', 'تم إنشاء التصنيف', false);
          // refresh list
          await fetchCategories();
          return true;
        }
      } else {
        final message = tryExtractErrorMessage(res.body);
        _showSnack('خطأ', 'فشل الإنشاء (${res.statusCode})\n$message', true);
        return false;
      }
    } catch (e) {
      _showSnack('استثناء', 'حدث خطأ أثناء إنشاء التصنيف: $e', true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update category
  Future<bool> updateCategory(int id, {String? name, String? slug, String? description}) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/post-categories/$id');
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (slug != null) payload['slug'] = slug;
      if (description != null) payload['description'] = description;

      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(payload),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = json.decode(res.body);
        dynamic data = (body is Map && body['data'] != null) ? body['data'] : body;
        if (data is Map) {
          final updated = PostCategoryModel.fromJson(Map<String, dynamic>.from(data));
          final idx = items.indexWhere((e) => e.id == updated.id);
          if (idx != -1) items[idx] = updated;
          _showSnack('نجاح', 'تم تحديث التصنيف', false);
          return true;
        } else {
          // fallback refresh list
          await fetchCategories();
          _showSnack('نجاح', 'تم تحديث التصنيف', false);
          return true;
        }
      } else {
        final message = tryExtractErrorMessage(res.body);
        _showSnack('خطأ', 'فشل التحديث (${res.statusCode})\n$message', true);
        return false;
      }
    } catch (e) {
      _showSnack('استثناء', 'حدث خطأ أثناء تحديث التصنيف: $e', true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete category
  Future<bool> deleteCategory(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/post-categories/$id');
      final res = await http.delete(uri);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        items.removeWhere((e) => e.id == id);
        _showSnack('نجاح', 'تم حذف التصنيف', false);
        return true;
      } else {
        final message = tryExtractErrorMessage(res.body);
        _showSnack('خطأ', 'فشل الحذف (${res.statusCode})\n$message', true);
        return false;
      }
    } catch (e) {
      _showSnack('استثناء', 'حدث خطأ عند حذف التصنيف: $e', true);
      return false;
    }
  }

  // try to extract server error message (basic)
  String tryExtractErrorMessage(String body) {
    try {
      final parsed = json.decode(body);
      if (parsed is Map && parsed['message'] != null) return parsed['message'].toString();
      if (parsed is Map && parsed['errors'] != null) return parsed['errors'].toString();
      return body;
    } catch (_) {
      return body;
    }
  }

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
}
