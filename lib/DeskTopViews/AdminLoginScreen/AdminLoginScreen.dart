import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/UsersViewsDeskTop/UsersViewDeskTop.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
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
    final darkGray =      const Color(0xFF1E1F2B);

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
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // بطاقة تسجيل الدخول المصغرة
                Container(
                  width: 400.w,
                  padding: EdgeInsets.symmetric(vertical: 40.r, horizontal: 32.r),
                  decoration: BoxDecoration(
                    color: mediumGray,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: lightGray, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // الشعار المصغر
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: darkGray,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.admin_panel_settings, 
                          size: 36.r, 
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      
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
                      SizedBox(height: 32.h),
                      
                      // حقل اسم المستخدم
                      TextField(
                        controller: _usernameController,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'اسم المستخدم',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                          filled: true,
                          fillColor: lightGray,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // حقل كلمة المرور
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(
                          fontSize: 15.sp,
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
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      
                      // زر تسجيل الدخول
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
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
                      SizedBox(height: 24.h),
                      
                      // تلميحة بيانات الدخول
                  
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                
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