import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/data/model/WalletTransaction.dart';

class WalletTransactionController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api'; // استبدل بالرابط الصحيح

  // قائمة المعاملات
  RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  
  // معاملة محددة
  Rx<WalletTransaction?> selectedTransaction = Rx<WalletTransaction?>(null);
  
  // حالات التحميل
  RxBool isLoadingTransactions = false.obs;
  RxBool isCreatingTransaction = false.obs;
  RxBool isDeletingTransaction = false.obs;

  // معلمات التصفية
  RxString filterWalletUuid = ''.obs;
  RxInt filterUserId = 0.obs;
  RxString filterType = ''.obs;
  RxString filterStatus = ''.obs;
  RxString filterReferenceType = ''.obs;
  RxInt filterReferenceId = 0.obs;
  RxString filterFromDate = ''.obs;
  RxString filterToDate = ''.obs;
  RxDouble filterMinAmount = 0.0.obs;
  RxDouble filterMaxAmount = 0.0.obs;
  RxBool filterOnlyPayments = false.obs;
  RxString sortBy = 'created_at'.obs;
  RxString sortDir = 'desc'.obs;
  RxInt perPage = 20.obs;

  // جلب جميع المعاملات مع إمكانية التصفية
 Future<void> fetchTransactions({String? walletUuid}) async {
  isLoadingTransactions.value = true;

  try {
    // بناء معلمات البحث
    final Map<String, String> queryParams = {};

    if (walletUuid != null && walletUuid.isNotEmpty) {
      queryParams['wallet_uuid'] = walletUuid;
    } else if (filterWalletUuid.value.isNotEmpty) {
      queryParams['wallet_uuid'] = filterWalletUuid.value;
    }

    if (filterUserId.value > 0) queryParams['user_id'] = filterUserId.value.toString();
    if (filterType.value.isNotEmpty) queryParams['type'] = filterType.value;
    if (filterStatus.value.isNotEmpty) queryParams['status'] = filterStatus.value;
    if (filterReferenceType.value.isNotEmpty) queryParams['reference_type'] = filterReferenceType.value;
    if (filterReferenceId.value > 0) queryParams['reference_id'] = filterReferenceId.value.toString();
    if (filterFromDate.value.isNotEmpty) queryParams['from'] = filterFromDate.value;
    if (filterToDate.value.isNotEmpty) queryParams['to'] = filterToDate.value;
    if (filterMinAmount.value > 0) queryParams['min_amount'] = filterMinAmount.value.toString();
    if (filterMaxAmount.value > 0) queryParams['max_amount'] = filterMaxAmount.value.toString();
    if (filterOnlyPayments.value) queryParams['only_payments'] = '1';

    queryParams['sort_by'] = sortBy.value;
    queryParams['sort_dir'] = sortDir.value;
    queryParams['per_page'] = perPage.value.toString();

    final uri = Uri.parse('$_baseUrl/transactions').replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body is Map<String, dynamic> && body['success'] == true) {
        final dynamic rawData = body['data'];

        if (rawData is List) {
          final List<WalletTransaction> list = [];

          for (final item in rawData) {
            try {
              if (item is Map<String, dynamic>) {
                list.add(WalletTransaction.fromJson(item));
              } else if (item is String) {
                // in case API returned JSON string per item (rare) -> try decode
                final decoded = json.decode(item);
                if (decoded is Map<String, dynamic>) {
                  list.add(WalletTransaction.fromJson(decoded));
                }
              } else {
                // unexpected type, skip
              }
            } catch (e) {
              // لا تكسر كل اللستة لو عنصر واحد فشل، يمكن تسجيله أو التعامل معه
              print('Failed to parse transaction item: $e\nItem: $item');
            }
          }

          transactions.value = list;
        } else {
          // data ليس لستة، أظهر خطأ بسيط
          _showSnackbar('خطأ', 'تنسيق البيانات غير متوقع', true);
        }
      } else {
        _showSnackbar('خطأ', 'فشل في جلب المعاملات', true);
      }
    } else {
      _showSnackbar('خطأ', 'رمز الاستجابة: ${response.statusCode}', true);
      print(response.statusCode);
    }
  } catch (e, st) {
    print('fetchTransactions exception: $e\n$st');
    _showSnackbar('استثناء', 'حدث خطأ: $e', true);
  } finally {
    isLoadingTransactions.value = false;
  }
}

  // جلب معاملات محفظة محددة
  Future<void> fetchWalletTransactions(String walletUuid) async {
    isLoadingTransactions.value = true;
    
    try {
      final Map<String, String> queryParams = {
        'sort_by': sortBy.value,
        'sort_dir': sortDir.value,
        'per_page': perPage.value.toString(),
      };

      final uri = Uri.parse('$_baseUrl/wallets/$walletUuid/transactions').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          final List<dynamic> data = body['data'];
          transactions.value = data
              .map((json) => WalletTransaction.fromJson(json))
              .toList();
        } else {
          _showSnackbar('خطأ', 'فشل في جلب معاملات المحفظة', true);
        }
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${response.statusCode}', true);
      }
    } catch (e) {
      _showSnackbar('استثناء', 'حدث خطأ: $e', true);
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  // جلب معاملة محددة
  Future<void> fetchTransaction(String uuid) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/transactions/$uuid'));
      
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          selectedTransaction.value = WalletTransaction.fromJson(body['data']);
        } else {
          _showSnackbar('خطأ', 'فشل في جلب المعاملة', true);
        }
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${response.statusCode}', true);
      }
    } catch (e) {
      _showSnackbar('استثناء', 'حدث خطأ: $e', true);
    }
  }

  // إنشاء معاملة جديدة
  Future<bool> createTransaction(Map<String, dynamic> data) async {
    isCreatingTransaction.value = true;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          _showSnackbar('نجاح', 'تم إنشاء المعاملة بنجاح', false);
          
          // إضافة المعاملة الجديدة إلى القائمة
          final newTransaction = WalletTransaction.fromJson(body['data']);
          transactions.insert(0, newTransaction);
          
          return true;
        } else {
          _showSnackbar('خطأ', body['message'] ?? 'فشل في إنشاء المعاملة', true);
          return false;
        }
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${response.statusCode}', true);
        return false;
      }
    } catch (e) {
      _showSnackbar('استثناء', 'حدث خطأ: $e', true);
      return false;
    } finally {
      isCreatingTransaction.value = false;
    }
  }

  // حذف معاملة
  Future<bool> deleteTransaction(String uuid) async {
    isDeletingTransaction.value = true;
    
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/transactions/$uuid'));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        
        if (body['success'] == true) {
          _showSnackbar('نجاح', 'تم حذف المعاملة بنجاح', false);
          
          // إزالة المعاملة من القائمة
          transactions.removeWhere((t) => t.uuid == uuid);
          
          return true;
        } else {
          _showSnackbar('خطأ', body['message'] ?? 'فشل في حذف المعاملة', true);
          return false;
        }
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${response.statusCode}', true);
        return false;
      }
    } catch (e) {
      _showSnackbar('استثناء', 'حدث خطأ: $e', true);
      return false;
    } finally {
      isDeletingTransaction.value = false;
    }
  }

  // تصفية المعاملات
  void applyFilters({
    String? walletUuid,
    int? userId,
    String? type,
    String? status,
    String? referenceType,
    int? referenceId,
    String? fromDate,
    String? toDate,
    double? minAmount,
    double? maxAmount,
    bool? onlyPayments,
    String? sortByField,
    String? sortDirection,
    int? itemsPerPage,
  }) {
    if (walletUuid != null) filterWalletUuid.value = walletUuid;
    if (userId != null) filterUserId.value = userId;
    if (type != null) filterType.value = type;
    if (status != null) filterStatus.value = status;
    if (referenceType != null) filterReferenceType.value = referenceType;
    if (referenceId != null) filterReferenceId.value = referenceId;
    if (fromDate != null) filterFromDate.value = fromDate;
    if (toDate != null) filterToDate.value = toDate;
    if (minAmount != null) filterMinAmount.value = minAmount;
    if (maxAmount != null) filterMaxAmount.value = maxAmount;
    if (onlyPayments != null) filterOnlyPayments.value = onlyPayments;
    if (sortByField != null) sortBy.value = sortByField;
    if (sortDirection != null) sortDir.value = sortDirection;
    if (itemsPerPage != null) perPage.value = itemsPerPage;

    fetchTransactions();
  }

  // إعادة تعيين التصفية
  void resetFilters() {
    filterWalletUuid.value = '';
    filterUserId.value = 0;
    filterType.value = '';
    filterStatus.value = '';
    filterReferenceType.value = '';
    filterReferenceId.value = 0;
    filterFromDate.value = '';
    filterToDate.value = '';
    filterMinAmount.value = 0.0;
    filterMaxAmount.value = 0.0;
    filterOnlyPayments.value = false;
    sortBy.value = 'created_at';
    sortDir.value = 'desc';
    perPage.value = 20;

    fetchTransactions();
  }

  // دالة لعرض الرسائل
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