import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../core/data/model/PackageType.dart';
import '../core/data/model/PremiumPackage.dart';
class PremiumPackageController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  // باقات
  RxList<PremiumPackage> packagesList = <PremiumPackage>[].obs;
  RxBool isLoadingPackages = false.obs;
  RxBool isSavingPackage = false.obs;
  RxBool isDeletingPackage = false.obs;

  // أنواع الباقات
  RxList<PackageType> packageTypesList = <PackageType>[].obs;
  RxBool isLoadingTypes = false.obs;
  RxBool isSavingType = false.obs;
  RxBool isDeletingType = false.obs;

  // ======== [جلب الباقات] ========
  Future<void> fetchPackages({String? status, int? perPage, int? packageTypeId}) async {
    isLoadingPackages.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/premium-packages').replace(queryParameters: {
        if (status != null) 'is_active': status,
        if (perPage != null) 'per_page': perPage.toString(),
        if (packageTypeId != null) 'package_type_id': packageTypeId.toString(),
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          List items = [];
          if (data is List) {
            items = data;
          } else if (data is Map && data['data'] is List) {
            items = data['data'];
          }
          packagesList.value = items.map((e) => PremiumPackage.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب الباقات', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب الباقات: $e', true);
    } finally {
      isLoadingPackages.value = false;
    }
  }

  // ======== [جلب أنواع الباقات] ========
  Future<void> fetchPackageTypes({int? perPage}) async {
    isLoadingTypes.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/package-types').replace(queryParameters: {
        if (perPage != null) 'per_page': perPage.toString(),
      });

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final jsonResponse = json.decode(res.body) as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          List items = [];
          if (data is List) {
            items = data;
          } else if (data is Map && data['data'] is List) {
            items = data['data'];
          }
          packageTypesList.value = items.map((e) => PackageType.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب أنواع الباقات', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${res.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب أنواع الباقات: $e', true);
    } finally {
      isLoadingTypes.value = false;
    }
  }

  // ======== [إنشاء باقة] ========
  Future<void> createPackage(PremiumPackage pkg) async {
    if (pkg.name.trim().isEmpty) {
      _showSnackbar('تحذير', 'الرجاء إدخال اسم الباقة', true);
      return;
    }

    isSavingPackage.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/premium-packages');
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(pkg.toJson()));

      final resData = json.decode(res.body);
      if (res.statusCode == 201 || (res.statusCode == 200 && resData['success'] == true)) {
        _showSnackbar('نجاح', 'تم إنشاء الباقة بنجاح', false);
        await fetchPackages();
      } else {
        _showSnackbar('خطأ', resData['message'] ?? 'فشل إنشاء الباقة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء إنشاء الباقة: $e', true);
    } finally {
      isSavingPackage.value = false;
    }
  }

  // ======== [تحديث باقة] ========
  Future<void> updatePackage(PremiumPackage pkg) async {
    if (pkg.id == null) {
      _showSnackbar('تحذير', 'معرف الباقة مطلوب للتحديث', true);
      return;
    }

    isSavingPackage.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/premium-packages/${pkg.id}');
      final res = await http.put(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(pkg.toJson()));

      final resData = json.decode(res.body);
      if (res.statusCode == 200 && resData['success'] == true) {
        _showSnackbar('نجاح', 'تم تحديث الباقة بنجاح', false);
        await fetchPackages();
      } else {
        _showSnackbar('خطأ', resData['message'] ?? 'فشل تحديث الباقة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء تحديث الباقة: $e', true);
    } finally {
      isSavingPackage.value = false;
    }
  }

  // ======== [حذف باقة] ========
  Future<void> deletePackage(int id) async {
    isDeletingPackage.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/premium-packages/$id');
      final res = await http.delete(uri);
      final resData = json.decode(res.body);
      if (res.statusCode == 200 && resData['success'] == true) {
        _showSnackbar('نجاح', 'تم حذف الباقة بنجاح', false);
        await fetchPackages();
      } else {
        _showSnackbar('خطأ', resData['message'] ?? 'فشل حذف الباقة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء حذف الباقة: $e', true);
    } finally {
      isDeletingPackage.value = false;
    }
  }

  // ======== [إخفاء/عرض باقة واحدة (toggle)] ========
  Future<void> toggleActive(int id) async {
    isSavingPackage.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/premium-packages/$id/toggle-active');
      final res = await http.post(uri);
      final resData = json.decode(res.body);
      if (res.statusCode == 200 && resData['success'] == true) {
        _showSnackbar('نجاح', 'تم تحديث حالة الباقة', false);
        await fetchPackages();
      } else {
        _showSnackbar('خطأ', resData['message'] ?? 'فشل تحديث حالة الباقة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء تحديث حالة الباقة: $e', true);
    } finally {
      isSavingPackage.value = false;
    }
  }

  // ======== [إخفاء كل الباقات مرة واحدة] ========
  Future<void> hideAllPackages() async {
    isSavingPackage.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/premium-packages/hide-all');
      final res = await http.post(uri);
      final resData = json.decode(res.body);
      if (res.statusCode == 200 && resData['success'] == true) {
        _showSnackbar('نجاح', resData['message'] ?? 'تم إخفاء كل الباقات', false);
        await fetchPackages();
      } else {
        _showSnackbar('خطأ', resData['message'] ?? 'فشل إخفاء الباقات', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء إخفاء الباقات: $e', true);
    } finally {
      isSavingPackage.value = false;
    }
  }

  // ======== [إنشاء نوع باقة] ========
  Future<void> createPackageType(PackageType type) async {
    if (type.name.trim().isEmpty) {
      _showSnackbar('تحذير', 'الرجاء إدخال اسم نوع الباقة', true);
      return;
    }

    isSavingType.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/package-types');
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(type.toJson()));

      final resData = json.decode(res.body);
      if ((res.statusCode == 201) || (res.statusCode == 200 && resData['success'] == true)) {
        _showSnackbar('نجاح', 'تم إنشاء نوع الباقة بنجاح', false);
        await fetchPackageTypes();
      } else {
        _showSnackbar('خطأ', resData['message'] ?? 'فشل إنشاء نوع الباقة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء إنشاء نوع الباقة: $e', true);
    } finally {
      isSavingType.value = false;
    }
  }

  // ======== [تحديث نوع باقة] ========
  Future<void> updatePackageType(PackageType type) async {
    if (type.id == null) {
      _showSnackbar('تحذير', 'معرف نوع الباقة مطلوب للتحديث', true);
      return;
    }

    isSavingType.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/package-types/${type.id}');
      final res = await http.put(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(type.toJson()));

      final resData = json.decode(res.body);
      if (res.statusCode == 200 && resData['success'] == true) {
        _showSnackbar('نجاح', 'تم تحديث نوع الباقة بنجاح', false);
        await fetchPackageTypes();
      } else {
        _showSnackbar('خطأ', resData['message'] ?? 'فشل تحديث نوع الباقة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء تحديث نوع الباقة: $e', true);
    } finally {
      isSavingType.value = false;
    }
  }

  // ======== [حذف نوع باقة] ========
  Future<void> deletePackageType(int id) async {
    isDeletingType.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/package-types/$id');
      final res = await http.delete(uri);
      final resData = json.decode(res.body);
      if (res.statusCode == 200 && resData['success'] == true) {
        _showSnackbar('نجاح', 'تم حذف نوع الباقة بنجاح', false);
        await fetchPackageTypes();
        // بعد حذف نوع الباقة.. تأكد من تحديث الباقات أيضاً
        await fetchPackages();
      } else {
        _showSnackbar('خطأ', resData['message'] ?? 'فشل حذف نوع الباقة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء حذف نوع الباقة: $e', true);
    } finally {
      isDeletingType.value = false;
    }
  }

  // ======== [Snackbar helper] ========
  void _showSnackbar(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      borderRadius: 10,
      margin: EdgeInsets.all(15),
      duration: Duration(seconds: isError ? 4 : 3),
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}
