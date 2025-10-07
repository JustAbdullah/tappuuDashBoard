import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/data/model/AdvertiserProfile.dart' as Adv;
import '../core/data/model/UserModel.dart';

class AdvertiserProfileController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';
  
  RxList<Adv.AdvertiserProfile> profilesList = <Adv.AdvertiserProfile>[].obs;
  RxBool isLoading = false.obs;
  RxBool isDeleting = false.obs;
  RxString errorMessage = ''.obs;



  // ======== [دوال جلب بيانات المستخدمين ] ========


  RxList<UserModel> users = <UserModel>[].obs;
  RxBool isLoadingUsers = false.obs;

  Future<void> fetchUsersWithCounts() async {
    isLoadingUsers.value = true;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users-with-counts'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['status'] == 'success') {
          final list = body['users'] as List<dynamic>;
          users.value = list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          print('API error: ${body['status']}');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetchUsersWithCounts: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // ======== [دوال جلب البيانات] ========
  Future<void> fetchAdvertiserProfiles({
    int? userId,
    String? name,
  }) async {
    profilesList.clear();
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // بناء معاملات الفلترة
      final queryParams = <String, String>{};
      if (userId != null) queryParams['user_id'] = userId.toString();
      if (name != null) queryParams['name'] = name;

      final uri = Uri.parse('$_baseUrl/advertiser-profiles')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        if (jsonResponse['message'] == 'تم جلب جميع ملفات المعلنين بنجاح.') {
          final data = jsonResponse['profiles'] as List<dynamic>;
          profilesList.value = data
              .map((e) => Adv.AdvertiserProfile.fromJson(e as Map<String, dynamic>))
              .toList();
       
        } else {
          throw jsonResponse['message'] ?? 'فشل جلب البيانات';
        }
      } else {
        throw 'خطأ في الاتصال بالسيرفر (${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب البيانات: $e', true);
    } finally {
      isLoading.value = false;
    }
  }

  // ======== [حذف معلن] ========
  Future<void> deleteAdvertiserProfile(int id) async {
    isDeleting.value = true;
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/advertiser-profiles/$id'),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['message'] == 'تم حذف ملف المعلن بنجاح.') {
        _showSnackbar('نجاح', 'تم حذف المعلن بنجاح', false);
        profilesList.removeWhere((profile) => profile.id == id);
      } else {
        throw responseData['message'] ?? 'فشل في الحذف';
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء الحذف: $e', true);
    } finally {
      isDeleting.value = false;
    }
  }

  // ======== [رسائل التنبيه] ========
  void _showSnackbar(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      duration: Duration(seconds: isError ? 4 : 3),
      icon: Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
    );
  }
}