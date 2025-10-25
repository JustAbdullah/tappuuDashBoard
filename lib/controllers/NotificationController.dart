import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging'
  ];
  final String _projectId = 'stayinme-1af7d';

  Future<void> sendTheNotification(String title, String body) async {
    // ملف Service Account credentials
    final serviceAccount = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "stayinme-1af7d",
      "private_key_id": "540f1f5ed41fa3f203867493991f1b43f25b5b18",
      "private_key": "-----BEGIN PRIVATE KEY-----\n"
          "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCnawV7vLyz/WDn\n"
          "5OZc73sMHBs1RSRu4mUBTiYghAP6dcpB2C8DCbvjSlLA9pKUIsZj2dNAcGS+zEq1\n"
          "hH2J50fdRw85nPvRnVC6kKQ65+zmC8ckGnCU64TyueaZU28427u7UCPtjDbOASSo\n"
          "lgCIjEkLpy8Com4NMeR0nHt3jL6eV+ckN6Ptsr99HWCYpbCH8ygeN2xQe/jfiqnG\n"
          "2yaqNP1ZRIsmUmdhHcxomwH0zp7dcyAIaBXaZJVgeOvZDqsNo6xa2quWTcU3UpKu\n"
          "eU0KrvkLPIo65fj6UcpLYs+e9riJGwpapmTWCghomdqzMpkROcgNbya2UYtCB6ol\n"
          "iJqrXd0jAgMBAAECggEAGMDwLJ15YTuDioYDsZYPIXk+ZJ/2hRagTJMbfA9I701f\n"
          "PGEUgmR8DV094x4SCikiID1iyNJVcwiNu0z9qtgxffw1uhUF/rY963fbcII+Or1f\n"
          "Em1+W+Z+38yw1dbKSSPkHAv7Y/IpYEg2/V5AcfAcFMcBYmhV0UmhN8SzVLfQr2Se\n"
          "pQmR1lbR7MZHvYTCph3K2YgZTRl+XYNExIZINsFxDIFim3ng9mOs6zPI9f07UYQz\n"
          "mBuSSwHYIF2doVNJ8Wi5JzRQ+FAGVLBZbSeRKPJc/IkH1rPbR3HlquYZtREQlsFl\n"
          "o9KRIBoOV4JUuHmYaCFChzv+OMeSthZo5L6Ae+IW4QKBgQDRaS7xHMwrMJOozW8d\n"
          "fanHDAhBpvPUaBmFdHrESYQr7s6GNGTWTv7h8XUlcC5wCV1DEFzRRtJfpp3wQbed\n"
          "ZRThRPvJNVUAcPufG4ycPhxUBEEfWW77gFSsWIZ8Zp9GFNOCwU1Miw3qVkDB9Zd0\n"
          "LFQIO76Lz/ojY2FBM4iAkAiMewKBgQDMqixJxsqRdNkRJew6FzhkhfrjTJ8kH3n1\n"
          "WrJ5mVeUcTZ6iiQwh1n0RSUC/XYJWLiuMvr7spVZpnh+Lom+iqJGkdexl70LdAAH\n"
          "qlu/a/HcRaXB2+zEN/aJIspzJ/6HpaFligUBL19IWoHGm/Cc1/YBiVdFOp+Yit9K\n"
          "X93UnVo1eQKBgHEFbvNtEniA+EDT15O4HeizAsXEQLc0FAomKphEAVTgx5BBOOc9\n"
          "rWzur8Yr/LQ1KaOnciD1M1eyim2AWoRVaOaIH8ihwyXA1N0ztjkhgJKL1UYBM9gD\n"
          "lC+Me9EqZe4iEWHxyDF2n2UJdlv4m+x0fEoRTK8S6bMt0PCqypJwqlx/AoGBAMT8\n"
          "TWA9C59wnbRZkcJfsxFduxqnFs0H1rSGNR3Ar4DabpsG9soWnEf1fSghmEhqsmZH\n"
          "/zXersz44yRf2oggmwvdN4NhDr1FSvoVx/S4CrP9/QpXiM1bJ9jaOY0Yw2z/yBYY\n"
          "/7QiSk0zf5EPakkru0XDUNH7GL0TfNLy7mnDgZ3RAoGAI37O8HGVRJBWgSYDP9Tf\n"
          "KvcXOr28YcvpuhiEsfH1utHUbO0/AdemeSApuyRo5hEwwchPoc/bQR9t/Xi7qKc3\n"
          "MrUMMxj6b6nkqtT+7lEV0b4vBYGKhoHeHL2rRUfL9t2V0nKB3el9+NqC+QQlnF+e\n"
          "lVFUtgsaaVGyKH46ZP8lybw=\n"
          "-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@stayinme-1af7d.iam.gserviceaccount.com",
      "client_id": "103600567456147272658",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40stayinme-1af7d.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    try {
      // إنشاء عميل معتمد
      final authClient = await clientViaServiceAccount(
        serviceAccount,
        _scopes,
      );

      // الحصول على الـ access token
      final accessToken = authClient.credentials.accessToken.data;

      // تحضير طلب FCM HTTP v1
      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      );
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      final message = {
        "message": {
          "topic": "all",
          "notification": {"title": title, "body": body},
          "android": {
            "priority": "HIGH",
            "notification": {
              "channel_id": "high_priority_channel",
              "sound": "default"
            }
          },
          "apns": {
            "headers": {"apns-priority": "10"},
            "payload": {
              "aps": {"sound": "default", "badge": 1}
            }
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "new"
          }
        }
      };

      // إرسال الطلب
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ تم إرسال الإشعار بنجاح');
      } else {
        debugPrint('‼️ فشل الإرسال: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      debugPrint('‼️ خطأ غير متوقع: $e');
      debugPrint('🔍 تفاصيل الخطأ: $stack');
    }
  }
}
