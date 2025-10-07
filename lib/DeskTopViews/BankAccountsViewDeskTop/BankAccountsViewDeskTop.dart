import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';

import '../../controllers/BankAccountController.dart';
import '../../controllers/CardPaymentController.dart';
import '../../core/data/model/BankAccountModel.dart';
import '../AdminSidebarDeskTop.dart';

class BankAccountsViewDeskTop extends StatefulWidget {
  const BankAccountsViewDeskTop({Key? key}) : super(key: key);

  @override
  _BankAccountsViewDeskTopState createState() => _BankAccountsViewDeskTopState();
}

class _BankAccountsViewDeskTopState extends State<BankAccountsViewDeskTop> {
  final BankAccountController bankController = Get.put(BankAccountController());
  final CardPaymentController cardController = Get.put(CardPaymentController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  
  final TextEditingController _editBankNameController = TextEditingController();
  final TextEditingController _editAccountNumberController = TextEditingController();
  
  int? _editingAccountId;

  @override
  void initState() {
    super.initState();
    bankController.fetchAccounts();
  }

  void _showAddAccountDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    _bankNameController.clear();
    _accountNumberController.clear();
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDarkMode),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500.w,
              minWidth: 300.w,
              maxHeight: 400.h,
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.account_balance, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text(
                        'إضافة حساب بنكي جديد',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  
                  TextField(
                    controller: _bankNameController,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                    decoration: InputDecoration(
                      labelText: 'اسم البنك',
                      labelStyle: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border(isDarkMode)),
                      ),
                      filled: true,
                      fillColor: AppColors.card(isDarkMode),
                      prefixIcon: Icon(Icons.account_balance, size: 22.r),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  TextField(
                    controller: _accountNumberController,
                    textDirection: TextDirection.rtl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                    decoration: InputDecoration(
                      labelText: 'رقم الحساب',
                      labelStyle: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border(isDarkMode)),
                      ),
                      filled: true,
                      fillColor: AppColors.card(isDarkMode),
                      prefixIcon: Icon(Icons.credit_card, size: 22.r),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          if (_bankNameController.text.isNotEmpty && 
                              _accountNumberController.text.isNotEmpty) {
                            bankController.createAccount(
                              bankName: _bankNameController.text,
                              accountNumber: _accountNumberController.text,
                            );
                            Get.back();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 20.r),
                            SizedBox(width: 8.w),
                            Text(
                              'إضافة',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditAccountDialog(BankAccountModel account) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    _editingAccountId = account.id;
    _editBankNameController.text = account.bankName;
    _editAccountNumberController.text = account.accountNumber;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDarkMode),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500.w,
              minWidth: 300.w,
              maxHeight: 400.h,
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.edit, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text(
                        'تعديل الحساب البنكي',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  
                  TextField(
                    controller: _editBankNameController,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                    decoration: InputDecoration(
                      labelText: 'اسم البنك',
                      labelStyle: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border(isDarkMode)),
                      ),
                      filled: true,
                      fillColor: AppColors.card(isDarkMode),
                      prefixIcon: Icon(Icons.account_balance, size: 22.r),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  TextField(
                    controller: _editAccountNumberController,
                    textDirection: TextDirection.rtl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                    decoration: InputDecoration(
                      labelText: 'رقم الحساب',
                      labelStyle: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border(isDarkMode)),
                      ),
                      filled: true,
                      fillColor: AppColors.card(isDarkMode),
                      prefixIcon: Icon(Icons.credit_card, size: 22.r),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          _editingAccountId = null;
                          Get.back();
                        },
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          if (_editBankNameController.text.isNotEmpty && 
                              _editAccountNumberController.text.isNotEmpty &&
                              _editingAccountId != null) {
                            bankController.updateAccount(
                              id: _editingAccountId!,
                              bankName: _editBankNameController.text,
                              accountNumber: _editAccountNumberController.text,
                            );
                            _editingAccountId = null;
                            Get.back();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save, size: 20.r),
                            SizedBox(width: 8.w),
                            Text(
                              'حفظ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int accountId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDarkMode),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500.w,
              minWidth: 300.w,
              maxHeight: 300.h,
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 24.r, color: AppColors.error),
                      SizedBox(width: 10.w),
                      Text(
                        'تأكيد الحذف',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'هل أنت متأكد من حذف هذا الحساب البنكي؟',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          bankController.deleteAccount(accountId);
                          Get.back();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 20.r),
                            SizedBox(width: 8.w),
                            Text(
                              'حذف',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontFamily: AppTextStyles.tajawal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCardPaymentSection(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: AppColors.card(isDarkMode),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إعدادات الدفع بالبطاقة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDarkMode),
                ),
              ),
              Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: cardController.isEnabled.value 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: cardController.isEnabled.value ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cardController.isEnabled.value ? Icons.visibility : Icons.visibility_off,
                      size: 16.r,
                      color: cardController.isEnabled.value ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      cardController.isEnabled.value ? 'مفعّل' : 'مخفي',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w600,
                        color: cardController.isEnabled.value ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // حالة العرض
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'حالة عرض خيار الدفع بالبطاقة:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDarkMode),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardController.isEnabled.value 
                      ? AppColors.error 
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: cardController.isSaving.value ? null : () {
                  cardController.toggleEnabled();
                },
                child: cardController.isSaving.value
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.r,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cardController.isEnabled.value ? Icons.visibility_off : Icons.visibility,
                            size: 18.r,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            cardController.isEnabled.value ? 'إخفاء' : 'تفعيل',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              )),
            ],
          ),
          
       
          
          SizedBox(height: 16.h),
          
          // معلومات إضافية
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.surface(isDarkMode),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.info_outline, size: 18.r, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'هذا الإعداد يتحكم في ظهور خيار الدفع بالبطاقة الائتمانية للمستخدمين في التطبيق',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final rowColor1 = isDarkMode ? AppColors.grey900 : AppColors.grey50;
    final rowColor2 = isDarkMode ? AppColors.grey800 : AppColors.grey100;
    
    return Scaffold(
      body: Row(
        children: [
          AdminSidebarDeskTop(),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إدارة الحسابات البنكية والدفع',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add, size: 18.r),
                        label: Text(
                          'إضافة حساب بنكي للتحويل جديد',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 20.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _showAddAccountDialog,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // قسم إعدادات الدفع بالبطاقة
                  _buildCardPaymentSection(isDarkMode),
                  
                  // Professional search bar
                 
                  SizedBox(height: 24.h),
                  
                  // Professional table with shadow and rounded corners
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card(isDarkMode),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CustomScrollView(
                          slivers: [
                            // Fixed header
                            SliverToBoxAdapter(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? AppColors.grey800 : AppColors.grey200,
                                ),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "المعرف",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "اسم البنك",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "رقم الحساب",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "تاريخ الإنشاء",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "الإجراءات",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Bank accounts list as table rows
                            Obx(() {
                              if (bankController.isLoading.value) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 3.r,
                                    ),
                                  ),
                                );
                              }
                              
                              if (bankController.accounts.isEmpty) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.account_balance, size: 64.r, color: AppColors.textSecondary(isDarkMode)),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'لا توجد حسابات بنكية',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: AppTextStyles.tajawal,
                                            color: AppColors.textSecondary(isDarkMode),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'انقر على زر "إضافة حساب جديد" لبدء الإضافة',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: AppTextStyles.tajawal,
                                            color: AppColors.textSecondary(isDarkMode),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final account = bankController.accounts[index];
                                    final rowColor = index % 2 == 0 ? rowColor1 : rowColor2;
                                    
                                    return Container(
                                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                                      color: rowColor,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              account.id.toString(),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              account.bankName,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              account.accountNumber,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _formatCreatedAt(account.createdAt??""),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textSecondary(isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit, size: 18.r, color: AppColors.primary),
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  onPressed: () => _showEditAccountDialog(account),
                                                ),
                                                SizedBox(width: 8.w),
                                                IconButton(
                                                  icon: Icon(Icons.delete, size: 18.r, color: AppColors.error),
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  onPressed: () => _showDeleteDialog(account.id),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: bankController.accounts.length,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return createdAt;
    }
  }
}