// lib/controllers/user_wallet_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/data/model/UserWallet.dart';

class UserWalletController extends GetxController {
  // عدّل الـ baseUrl حسب بيئتك
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  Rx<UserWallet?> wallet = Rx<UserWallet?>(null);
  RxList<UserWallet> wallets = <UserWallet>[].obs; // كل المحافظ
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;
  RxBool isDeleting = false.obs;

  Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    // 'Authorization': 'Bearer <token>' // ضع التوكن هنا لو تستخدم مصادقة
  };

  // ======== [جلب كل المحافظ - supports per_page] ========
  /// مثال: GET /api/wallets?per_page=20
  Future<void> fetchAllWallets({int? perPage}) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets${perPage != null ? '?per_page=$perPage' : ''}');
      final res = await http.get(uri, headers: defaultHeaders);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          final list = UserWallet.listFromJson(data);
          wallets.assignAll(list);
        } else {
          wallets.clear();
          _showSnackbar('معلومة', body['message'] ?? 'لم يتم العثور على محافظ', false);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${res.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب المحافظ: $e', true);
    } finally {
      isLoading.value = false;
    }
  }

  // ======== [جلب محفظة المستخدم المصادق عليه] ========
  Future<void> fetchMyWallet() async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets/me');
      final res = await http.get(uri, headers: defaultHeaders);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true && body['data'] != null) {
          wallet.value = UserWallet.fromJson(Map<String, dynamic>.from(body['data']));
        } else {
          wallet.value = null;
          _showSnackbar('خطأ', body['message'] ?? 'فشل جلب المحفظة', true);
        }
      } else if (res.statusCode == 404) {
        wallet.value = null;
        _showSnackbar('معلومة', 'لا توجد محفظة لهذا المستخدم', false);
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${res.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب المحفظة: $e', true);
    } finally {
      isLoading.value = false;
    }
  }

  // ======== [جلب محفظة/محافظ مستخدم محدد - للادمن] ========
  /// ملاحظة: الراوت في الـ API هو GET /api/users/{userId}/wallets
  /// لذلك هنا نستخدمه. إذا أردت سلوكاً مختلفاً (مثل إرجاع كل المحفظات بدل الأولى) يمكن تعديلها.
  Future<void> fetchWalletByUserId(int userId) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/users/$userId/wallets');
      final res = await http.get(uri, headers: defaultHeaders);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          // في حال كانت قائمة: نأخذ أول محفظة، وإذا أردت نُعيد كافة المحافظ ضعها في wallets
          if (data is List && data.isNotEmpty) {
            wallet.value = UserWallet.fromJson(Map<String, dynamic>.from(data[0]));
          } else if (data is Map) {
            wallet.value = UserWallet.fromJson(Map<String, dynamic>.from(data));
          } else {
            wallet.value = null;
            _showSnackbar('معلومة', 'لا توجد محفظة لهذا المستخدم', false);
          }
        } else {
          wallet.value = null;
          _showSnackbar('معلومة', body['message'] ?? 'فشل جلب المحفظة', false);
        }
      } else if (res.statusCode == 404) {
        wallet.value = null;
        _showSnackbar('معلومة', 'لا توجد محفظة لهذا المستخدم', false);
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${res.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب المحفظة: $e', true);
    } finally {
      isLoading.value = false;
    }
  }

  // ======== [شحن المحفظة - credit] ========
  Future<void> creditWallet({
    required String walletUuid,
    required double amount,
    String? note,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets/credit');
      final payload = {
        'wallet_uuid': walletUuid,
        'amount': amount,
        if (note != null) 'note': note,
      };

      final res = await http.post(uri, headers: defaultHeaders, body: jsonEncode(payload));
      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        _showSnackbar('نجاح', body['message'] ?? 'تم شحن المحفظة', false);
        // تحديث المحفظة المحددة
           await   fetchAllWallets();

      } else {
        _showSnackbar('خطأ', body['message'] ?? 'فشل شحن المحفظة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء شحن المحفظة: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [خصم من المحفظة - debit] ========
  Future<void> debitWallet({
    required String walletUuid,
    required double amount,
    String? note,
  }) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets/debit');
      final payload = {
        'wallet_uuid': walletUuid,
        'amount': amount,
        if (note != null) 'note': note,
      };

      final res = await http.post(uri, headers: defaultHeaders, body: jsonEncode(payload));
      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        _showSnackbar('نجاح', body['message'] ?? 'تم خصم المبلغ من المحفظة', false);
        // تحديث المحفظة المحددة
    await   fetchAllWallets();
      } else {
        _showSnackbar('خطأ', body['message'] ?? 'فشل خصم المبلغ', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء خصم المحفظة: $e', true);
    } finally {
      isSaving.value = false;
    }
  }


  // ======== [اختياري: مساعدة لإنشاء المحفظة محلياً أو التحقق منها] ========
  Future<void> ensureWalletExistsAndFetch(int userId) async {
    await fetchWalletByUserId(userId);
    if (wallet.value == null) {
      _showSnackbar('معلومة', 'المحفظة غير موجودة — الرجاء إنشاء المحفظة عبر لوحة الإدارة أو عند التسجيل', false);
    }
  }

  // حذف القوائم محليًا
  void clearWalletsCache() {
    wallets.clear();
    wallet.value = null;
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

  // ======== [تجميد المحفظة] ========
  Future<void> freezeWallet(String walletUuid) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets/$walletUuid/freeze');
      final res = await http.post(uri, headers: defaultHeaders);
      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        _showSnackbar('نجاح', body['message'] ?? 'تم تجميد المحفظة', false);
        // تحديث المحفظة المحددة        // تحديث قائمة المحافظ
       
          await fetchAllWallets();
        
      } else {
        _showSnackbar('خطأ', body['message'] ?? 'فشل تجميد المحفظة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء تجميد المحفظة: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [تنشيط المحفظة] ========
  Future<void> activateWallet(String walletUuid) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets/$walletUuid/activate');
      final res = await http.post(uri, headers: defaultHeaders);
      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        _showSnackbar('نجاح', body['message'] ?? 'تم تنشيط المحفظة', false);
        // تحديث المحفظة المحددة        // تحديث قائمة المحافظ
          await fetchAllWallets();
        
      } else {
        _showSnackbar('خطأ', body['message'] ?? 'فشل تنشيط المحفظة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء تنشيط المحفظة: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [إغلاق المحفظة] ========
  Future<void> closeWallet(String walletUuid) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets/$walletUuid/close');
      final res = await http.post(uri, headers: defaultHeaders);
      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        _showSnackbar('نجاح', body['message'] ?? 'تم إغلاق المحفظة', false);
        // تحديث المحفظة المحددة
               await fetchAllWallets();

      } else {
        _showSnackbar('خطأ', body['message'] ?? 'فشل إغلاق المحفظة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء إغلاق المحفظة: $e', true);
    } finally {
      isSaving.value = false;
    }
  }

  // ======== [حذف المحفظة] ========
  Future<void> deleteWallet(String walletUuid) async {
    isDeleting.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets/$walletUuid');
      final res = await http.delete(uri, headers: defaultHeaders);
      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        _showSnackbar('نجاح', body['message'] ?? 'تم حذف المحفظة', false);
        // إزالة المحفظة من القائمة
               await fetchAllWallets();

      } else {
        _showSnackbar('خطأ', body['message'] ?? 'فشل حذف المحفظة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء حذف المحفظة: $e', true);
    } finally {
      isDeleting.value = false;
    }
  }

    // ======== [فتح المحفظة (reopen)] ========
  Future<void> openWallet(String walletUuid) async {
    isSaving.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/wallets/$walletUuid/open');
      final res = await http.post(uri, headers: defaultHeaders);
      final body = json.decode(res.body);

      if (res.statusCode == 200 && body['success'] == true) {
        _showSnackbar('نجاح', body['message'] ?? 'تم فتح المحفظة', false);

        // إذا رجع السيرفر بيانات المحفظة، حدّثها محليًا
        if (body['data'] != null) {
          try {
            final updated = UserWallet.fromJson(Map<String, dynamic>.from(body['data']));
            // حدّث المحفظة المفصّلة إن كانت نفس الـ uuid
            if (wallet.value != null && wallet.value!.uuid == updated.uuid) {
              wallet.value = updated;
            }
            // حدّث القائمة إن كانت موجودة فيها
            final idx = wallets.indexWhere((w) => w.uuid == updated.uuid);
            if (idx >= 0) {
              wallets[idx] = updated;
            }
          } catch (_) {
            // إذا فشل التحويل نتابع فقط بجلب كامل للقائمة
          }
        }

        // حدّث القائمة العامة لضمان تناسق البيانات
        await fetchAllWallets();
      } else {
        _showSnackbar('خطأ', body['message'] ?? 'فشل فتح المحفظة', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء فتح المحفظة: $e', true);
    } finally {
      isSaving.value = false;
    }
  }


  // ======== [Snackbar helper] ========
  
}
