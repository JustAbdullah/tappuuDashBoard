import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/UsersViewsDeskTop/UsersViewDeskTop.dart';

class AdminLoginScreenMobile extends StatefulWidget {
  const AdminLoginScreenMobile({Key? key}) : super(key: key);

  @override
  _AdminLoginScreenMobileState createState() => _AdminLoginScreenMobileState();
}

class _AdminLoginScreenMobileState extends State<AdminLoginScreenMobile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  final String _adminUsername = "admin";
  final String _adminPassword = "1299s90mt";

  void _login() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar('خطأ', 'يرجى ملء جميع الحقول',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      
      if (_usernameController.text == _adminUsername && 
          _passwordController.text == _adminPassword) {
        Get.offAll(UsersViewDeskTop());
      } else {
        Get.snackbar('خطأ', 'اسم المستخدم أو كلمة المرور غير صحيحة',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkGray = const Color(0xFF1E1F2B);
    final mediumGray = Color(0xFF1E1E1E);
    final lightGray = Color(0xFF2E2E2E);
    final textColor = Colors.grey[200];
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: darkGray,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // الشعار
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: darkGray.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: lightGray, width: 1),
                  ),
                  child: Icon(Icons.admin_panel_settings, 
                    size: 40.r, 
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 30.h),
                
                // بطاقة تسجيل الدخول المخصصة للجوال
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 24.w),
                  decoration: BoxDecoration(
                    color: mediumGray,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: lightGray, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('تسجيل دخول المشرفين', style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      )),
                      SizedBox(height: 8.h),
                      Text('أدخل بيانات الدخول للوصول إلى لوحة التحكم', style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      )),
                      SizedBox(height: 30.h),
                      
                      // حقل اسم المستخدم
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'اسم المستخدم',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                          filled: true,
                          fillColor: lightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // حقل كلمة المرور
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey[500]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[500],
                              size: 20.r,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: lightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // زر تسجيل الدخول
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5.r,
                                )
                              : Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 25.h),
                      
                      // تلميحة بيانات الدخول
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: darkGray,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 16.r, color: Colors.grey[500]),
                            SizedBox(width: 8.w),
                            Text(
                              'بيانات الدخول: admin / 1299s90mt',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                
                // حقوق الملكية
                Text(
                  '© 2025 لوحة تحكم StayInMe',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}