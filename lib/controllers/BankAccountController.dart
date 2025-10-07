// lib/core/controllers/bank_account_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../core/data/model/BankAccountModel.dart';


class BankAccountController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
  RxList<BankAccountModel> accounts = <BankAccountModel>[].obs;
  RxBool isLoading = false.obs;
  Rxn<BankAccountModel> current = Rxn<BankAccountModel>();

  // ===== fetch all =====
  Future<void> fetchAccounts() async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/bank-accounts');
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        // دعم صيغتين: { success: true, data: [...] } أو { status: 'success', data: [...] }
        final data = (body is Map && (body['data'] != null)) ? body['data'] : body;
        if (data is List) {
          accounts.value = data.map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          accounts.value = [];
          _showSnackbar('خطأ', 'البيانات المستلمة غير متوقعة', true);
        }
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
      }
    } catch (e) {
      print('Exception fetchAccounts: $e');
      _showSnackbar('استثناء', 'حدث خطأ عند جلب الحسابات', true);
    } finally {
      isLoading.value = false;
    }
  }

  // ===== fetch one =====
  Future<void> fetchAccount(int id) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/bank-accounts/$id');
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        current.value = BankAccountModel.fromJson(data as Map<String, dynamic>);
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
      }
    } catch (e) {
      print('Exception fetchAccount: $e');
      _showSnackbar('استثناء', 'حدث خطأ عند جلب الحساب', true);
    } finally {
      isLoading.value = false;
    }
  }

  // ===== create =====
  Future<bool> createAccount({required String bankName, required String accountNumber}) async {
    try {
      final uri = Uri.parse('$_baseUrl/bank-accounts');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'bank_name': bankName, 'account_number': accountNumber}),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        final created = BankAccountModel.fromJson(data as Map<String, dynamic>);
        accounts.insert(0, created);
        _showSnackbar('نجاح', 'تم إنشاء الحساب', false);
        return true;
      } else {
        final body = json.decode(res.body);
        _showSnackbar('خطأ', body['message']?.toString() ?? 'فشل الإنشاء', true);
        return false;
      }
    } catch (e) {
      print('Exception createAccount: $e');
      _showSnackbar('استثناء', 'حدث خطأ أثناء إنشاء الحساب', true);
      return false;
    }
  }

  // ===== update =====
  Future<bool> updateAccount({required int id, String? bankName, String? accountNumber}) async {
    try {
      final uri = Uri.parse('$_baseUrl/bank-accounts/$id');
      final bodyMap = <String, dynamic>{};
      if (bankName != null) bodyMap['bank_name'] = bankName;
      if (accountNumber != null) bodyMap['account_number'] = accountNumber;

      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(bodyMap),
      );

      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        final data = body['data'] ?? body;
        final updated = BankAccountModel.fromJson(data as Map<String, dynamic>);
        final idx = accounts.indexWhere((a) => a.id == updated.id);
        if (idx != -1) accounts[idx] = updated;
        current.value = updated;
        _showSnackbar('نجاح', 'تم التحديث', false);
        return true;
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
        return false;
      }
    } catch (e) {
      print('Exception updateAccount: $e');
      _showSnackbar('استثناء', 'حدث خطأ أثناء التحديث', true);
      return false;
    }
  }

  // ===== delete =====
  Future<bool> deleteAccount(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/bank-accounts/$id');
      final res = await http.delete(uri);

      if (res.statusCode == 200) {
        accounts.removeWhere((a) => a.id == id);
        _showSnackbar('نجاح', 'تم الحذف', false);
        return true;
      } else {
        _showSnackbar('خطأ', 'رمز الاستجابة: ${res.statusCode}', true);
        return false;
      }
    } catch (e) {
      print('Exception deleteAccount: $e');
      _showSnackbar('استثناء', 'حدث خطأ أثناء الحذف', true);
      return false;
    }
  }

  // ===== helper snackbar =====
  void _showSnackbar(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      borderRadius: 10,
      margin: EdgeInsets.all(12),
      duration: Duration(seconds: isError ? 4 : 3),
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
    );
  }
}
