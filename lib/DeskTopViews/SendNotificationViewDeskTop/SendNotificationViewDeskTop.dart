import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';

import '../../controllers/NotificationController.dart';
import '../AdminSidebarDeskTop.dart';

class SendNotificationViewDeskTop extends StatefulWidget {
  const SendNotificationViewDeskTop({Key? key}) : super(key: key);

  @override
  _SendNotificationViewDeskTopState createState() => _SendNotificationViewDeskTopState();
}

class _SendNotificationViewDeskTopState extends State<SendNotificationViewDeskTop> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  NotificationController _notificationController = Get.put(NotificationController());
  
  bool _isSending = false;

  void _sendNotification() {
    if (_titleController.text.isEmpty) {
      Get.snackbar('تحذير', 'الرجاء إدخال عنوان الإشعار',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
   _notificationController.sendTheNotification(_titleController.text.toString(), _contentController.text.toString());
    setState(() => _isSending = true);
    
    // محاكاة عملية الإرسال
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isSending = false);
     

      _titleController.clear();
      _contentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.textPrimary(isDark);
    final secondaryTextColor = AppColors.textSecondary(isDark);
    
    return Scaffold(
      body: Row(children: [
        AdminSidebarDeskTop(),
        Expanded(child: Padding(
          padding: EdgeInsets.symmetric(horizontal:64.w, vertical:16.h),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              // العنوان الرئيسي
              Text('إرسال إشعار جديد', style: TextStyle(
                fontSize: 24.sp, 
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, 
                color: textColor,
              )),
              SizedBox(height: 40.h),
              
              // حقل عنوان الإشعار
              Align(
                alignment: Alignment.centerRight,
                child: Text('عنوان الإشعار', style: TextStyle(
                  fontSize: 16.sp, 
                  fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.w600, 
                  color: textColor,
                )),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _titleController,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16.sp, 
                  fontFamily: AppTextStyles.tajawal,
                  color: textColor),
                decoration: InputDecoration(
                  hintText: 'أدخل عنوان الإشعار هنا...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp, 
                    fontFamily: AppTextStyles.tajawal,
                    color: secondaryTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: AppColors.card(isDark),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 16.h),
                  prefixIcon: Icon(Icons.title, color: secondaryTextColor),
                ),
              ),
              SizedBox(height: 24.h),
              
              // حقل محتوى الإشعار
              Align(
                alignment: Alignment.centerRight,
                child: Text('محتوى الإشعار', style: TextStyle(
                  fontSize: 16.sp, 
                  fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.w600, 
                  color: textColor,
                )),
              ),
              SizedBox(height: 8.h),
              Container(
                height: 200.h,
                child: TextField(
                  controller: _contentController,
                  textDirection: TextDirection.rtl,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(
                    fontSize: 16.sp, 
                    fontFamily: AppTextStyles.tajawal,
                    color: textColor),
                  decoration: InputDecoration(
                    hintText: 'أدخل محتوى الإشعار هنا...',
                    hintStyle: TextStyle(
                      fontSize: 14.sp, 
                      fontFamily: AppTextStyles.tajawal,
                      color: secondaryTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                    filled: true,
                    fillColor: AppColors.card(isDark),
                    contentPadding: EdgeInsets.all(16.w),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              
              // زر الإرسال
              SizedBox(
                width: 200.w,
                child: ElevatedButton.icon(
                  icon: _isSending 
                    ? SizedBox(
                        width: 20.r, 
                        height: 20.r, 
                        child: CircularProgressIndicator(
                          color: Colors.white, 
                          strokeWidth: 2.r))
                    : Icon(Icons.send, size: 20.r),
                  label: Text(_isSending ? 'جاري الإرسال...' : 'إرسال الإشعار', 
                    style: TextStyle(
                      fontSize: 16.sp, 
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w600,
                    )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r))),
                  onPressed: _isSending ? null : _sendNotification,
                ),
              ),
            ],
          ),
        ),
      ),
    ]));
  }
}