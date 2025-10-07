import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/data/model/UserModel.dart';

class UserController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  RxList<UserModel> users = <UserModel>[].obs;
  RxBool isLoadingUsers = false.obs;
 Future<void> fetchUsersWithCounts({String? email}) async {
    isLoadingUsers.value = true;
    try {
      // Build URI with optional email query parameter
      final uri = Uri.parse('$_baseUrl/users-with-counts')
          .replace(queryParameters: email != null && email.isNotEmpty
              ? {'email': email}
              : null);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['status'] == 'success') {
          final list = body['users'] as List<dynamic>;
          users.value = list
              .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
        }
      } else {
        print('HTTP error: \${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetchUsersWithCounts: \$e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/users/\$id'));
      if (response.statusCode == 200) {
        users.removeWhere((u) => u.id == id);
      } else {
        print('Error deleting user \$id: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception deleteUser: \$e');
    }
  }

  // ======== [دالة لعرض رسائل احترافية] ========
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
  

  // ======== [دالة لتحديث max_free_posts] ========
  Future<void> updateMaxFreePostsDefault({
    required int newValue,
    bool updateExistingUsers = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update-max-posts-default'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'new_value': newValue,
          'update_existing_users': updateExistingUsers,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        fetchUsersWithCounts();
       
        if (body['status'] == true) {
          _showSnackbar(
            'نجاح',
            body['message'] as String,
            false,
          );
         
        } else {
          _showSnackbar(
            'فشل',
            body['message'] as String,
            true,
          );
        }
      } else {
        _showSnackbar(
          'خطأ',
          'رمز الاستجابة: \${response.statusCode}',
          true,
        );
      }
    } catch (e) {
      _showSnackbar(
        'استثناء',
        'حدث خطأ: \$e',
        true,
      );
    }
  }
}
