import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../controllers/WalletTransactionController.dart';
import '../../core/data/model/WalletTransaction.dart';
import '../AdminSidebarDeskTop.dart';

class WalletTransactionsViewDeskTop extends StatefulWidget {
  const WalletTransactionsViewDeskTop({Key? key}) : super(key: key);

  @override
  _WalletTransactionsViewDeskTopState createState() => _WalletTransactionsViewDeskTopState();
}

class _WalletTransactionsViewDeskTopState extends State<WalletTransactionsViewDeskTop> {
  final WalletTransactionController transactionController = Get.put(WalletTransactionController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _walletUuidController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  // controllers for filter dialog
  final TextEditingController _filterWalletUuidController = TextEditingController();
  final TextEditingController _filterUserIdController = TextEditingController();
  final TextEditingController _filterMinAmountController = TextEditingController();
  final TextEditingController _filterMaxAmountController = TextEditingController();
  final TextEditingController _filterFromDateController = TextEditingController();
  final TextEditingController _filterToDateController = TextEditingController();

  String _selectedType = 'الكل';
  String _selectedStatus = 'الكل';
  String _selectedTransactionType = 'credit';

  @override
  void initState() {
    super.initState();
    transactionController.fetchTransactions();
  }

  @override
  void dispose() {
    _filterWalletUuidController.dispose();
    _filterUserIdController.dispose();
    _filterMinAmountController.dispose();
    _filterMaxAmountController.dispose();
    _filterFromDateController.dispose();
    _filterToDateController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Initialize filter controllers with current values
    _filterWalletUuidController.text = transactionController.filterWalletUuid.value;
    _filterUserIdController.text = transactionController.filterUserId.value > 0 
        ? transactionController.filterUserId.value.toString() 
        : '';
    _filterMinAmountController.text = transactionController.filterMinAmount.value > 0 
        ? transactionController.filterMinAmount.value.toString() 
        : '';
    _filterMaxAmountController.text = transactionController.filterMaxAmount.value > 0 
        ? transactionController.filterMaxAmount.value.toString() 
        : '';
    _filterFromDateController.text = transactionController.filterFromDate.value;
    _filterToDateController.text = transactionController.filterToDate.value;

    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDarkMode),
          insetPadding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 900.w,
              minWidth: 500.w,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.filter_list_rounded, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text(
                        'تصفية المعاملات',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  // Filter options
                  Wrap(
                    spacing: 16.w,
                    runSpacing: 16.h,
                    textDirection: TextDirection.rtl,
                    children: [
                      // Wallet UUID filter
                      SizedBox(
                        width: 250.w,
                        child: TextField(
                          controller: _filterWalletUuidController,
                          decoration: InputDecoration(
                            labelText: 'معرف المحفظة',
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
                          ),
                          onChanged: (value) {
                            transactionController.filterWalletUuid.value = value;
                          },
                        ),
                      ),
                      
                      // User ID filter
                      SizedBox(
                        width: 150.w,
                        child: TextField(
                          controller: _filterUserIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'معرف المستخدم',
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
                          ),
                          onChanged: (value) {
                            transactionController.filterUserId.value = int.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                      
                      // Type filter
                      _buildFilterDropdown(
                        label: 'نوع المعاملة',
                        value: transactionController.filterType.value,
                        items: {
                          'الكل': '',
                          'إيداع': 'credit',
                          'سحب': 'debit',
                          'شراء': 'purchase',
                          'استرداد': 'refund',
                          'رسوم': 'fee',
                          'تعديل': 'adjustment',
                          'نظام': 'system'
                        },
                        onChanged: (value) {
                          transactionController.filterType.value = value ?? '';
                        },
                        isDarkMode: isDarkMode,
                      ),
                      
                      // Status filter
                      _buildFilterDropdown(
                        label: 'الحالة',
                        value: transactionController.filterStatus.value,
                        items: {
                          'الكل': '',
                          'قيد الانتظار': 'pending',
                          'مكتمل': 'completed',
                          'فشل': 'failed'
                        },
                        onChanged: (value) {
                          transactionController.filterStatus.value = value ?? '';
                        },
                        isDarkMode: isDarkMode,
                      ),
                      
                      // Amount range
                      SizedBox(
                        width: 200.w,
                        child: TextField(
                          controller: _filterMinAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'الحد الأدنى للمبلغ',
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
                          ),
                          onChanged: (value) {
                            transactionController.filterMinAmount.value = double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ),
                      
                      SizedBox(
                        width: 200.w,
                        child: TextField(
                          controller: _filterMaxAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'الحد الأقصى للمبلغ',
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
                          ),
                          onChanged: (value) {
                            transactionController.filterMaxAmount.value = double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ),
                      
                      // Date range
                      SizedBox(
                        width: 200.w,
                        child: TextField(
                          controller: _filterFromDateController,
                          decoration: InputDecoration(
                            labelText: 'من تاريخ',
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
                            suffixIcon: Icon(Icons.calendar_today, size: 20.r),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              final formattedDate = date.toIso8601String().split('T')[0];
                              _filterFromDateController.text = formattedDate;
                              transactionController.filterFromDate.value = formattedDate;
                            }
                          },
                        ),
                      ),
                      
                      SizedBox(
                        width: 200.w,
                        child: TextField(
                          controller: _filterToDateController,
                          decoration: InputDecoration(
                            labelText: 'إلى تاريخ',
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
                            suffixIcon: Icon(Icons.calendar_today, size: 20.r),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              final formattedDate = date.toIso8601String().split('T')[0];
                              _filterToDateController.text = formattedDate;
                              transactionController.filterToDate.value = formattedDate;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          transactionController.resetFilters();
                          // Clear filter controllers
                          _filterWalletUuidController.clear();
                          _filterUserIdController.clear();
                          _filterMinAmountController.clear();
                          _filterMaxAmountController.clear();
                          _filterFromDateController.clear();
                          _filterToDateController.clear();
                          Get.back();
                        },
                        child: Text(
                          'إعادة التعيين',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ),
                      Row(
                        textDirection: TextDirection.rtl,
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
                          SizedBox(width: 12.w),
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
                              // Apply all filter values
                              transactionController.filterWalletUuid.value = _filterWalletUuidController.text;
                              transactionController.filterUserId.value = int.tryParse(_filterUserIdController.text) ?? 0;
                              transactionController.filterMinAmount.value = double.tryParse(_filterMinAmountController.text) ?? 0.0;
                              transactionController.filterMaxAmount.value = double.tryParse(_filterMaxAmountController.text) ?? 0.0;
                              transactionController.filterFromDate.value = _filterFromDateController.text;
                              transactionController.filterToDate.value = _filterToDateController.text;
                              
                              transactionController.fetchTransactions();
                              Get.back();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_alt, size: 20.r),
                                SizedBox(width: 8.w),
                                Text(
                                  'تطبيق الفلتر',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required Function(String?) onChanged,
    required bool isDarkMode,
  }) {
    // Ensure the value exists in the items map, otherwise use the first item
    String selectedValue = value;
    if (!items.containsValue(value)) {
      selectedValue = items.values.first;
    }
    
    return SizedBox(
      width: 200.w,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
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
        ),
        items: items.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.value,
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textPrimary(isDarkMode),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  
  void _showCreateTransactionDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDarkMode),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600.w,
              minWidth: 500.w,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  SizedBox(height: 24.h),
                  
                  // Create transaction form
                  TextField(
                    controller: _walletUuidController,
                    decoration: InputDecoration(
                      labelText: 'معرف المحفظة *',
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
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  TextField(
                    controller: _userIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'معرف المستخدم',
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
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  _buildFilterDropdown(
                    label: 'نوع المعاملة *',
                    value: _selectedTransactionType,
                    items: {
                      'إيداع': 'credit',
                      'سحب': 'debit',
                      'شراء': 'purchase',
                      'استرداد': 'refund',
                      'رسوم': 'fee',
                      'تعديل': 'adjustment',
                      'نظام': 'system'
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedTransactionType = value ?? 'credit';
                      });
                    },
                    isDarkMode: isDarkMode,
                  ),
                  SizedBox(height: 16.h),
                  
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'المبلغ *',
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
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ملاحظة',
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
                          if (_walletUuidController.text.isEmpty || _amountController.text.isEmpty) {
                            Get.snackbar(
                              'خطأ',
                              'يرجى ملء جميع الحقول الإلزامية',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          
                          final data = {
                            'wallet_uuid': _walletUuidController.text,
                            'type': _selectedTransactionType,
                            'amount': double.parse(_amountController.text),
                            'note': _noteController.text,
                          };
                          
                          if (_userIdController.text.isNotEmpty) {
                            data['user_id'] = int.parse(_userIdController.text);
                          }
                          
                          transactionController.createTransaction(data);
                          Get.back();
                          
                          // Clear fields
                          _walletUuidController.clear();
                          _userIdController.clear();
                          _amountController.clear();
                          _noteController.clear();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 20.r),
                            SizedBox(width: 8.w),
                            Text(
                              'إنشاء',
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

  void _showTransactionDetails(WalletTransaction transaction) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDarkMode),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 50.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600.w,
              minWidth: 500.w,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تفاصيل المعاملة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 24.r),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  // Transaction details
                  _buildDetailRow('المعرف:', transaction.uuid, isDarkMode),
                  _buildDetailRow('معرف المحفظة:', transaction.walletUuid, isDarkMode),
                  _buildDetailRow('معرف المستخدم:', transaction.userId.toString(), isDarkMode),
                  _buildDetailRow('النوع:', _formatType(transaction.type), isDarkMode),
                  _buildDetailRow('المبلغ:', '${transaction.amount} ${transaction.currency}', isDarkMode),
                  _buildDetailRow('الرصيد قبل:', transaction.balanceBefore.toStringAsFixed(2), isDarkMode),
                  _buildDetailRow('الرصيد بعد:', transaction.balanceAfter.toStringAsFixed(2), isDarkMode),
                  _buildDetailRow('الحالة:', _formatStatus(transaction.status), isDarkMode),
                  if (transaction.referenceType != null)
                    _buildDetailRow('نوع المرجع:', transaction.referenceType!, isDarkMode),
                  if (transaction.referenceId != null)
                    _buildDetailRow('معرف المرجع:', transaction.referenceId.toString(), isDarkMode),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    _buildDetailRow('ملاحظة:', transaction.note!, isDarkMode),
                  _buildDetailRow('تاريخ الإنشاء:', _formatFullDate(transaction.createdAt), isDarkMode),
                  
                  SizedBox(height: 24.h),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'إغلاق',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDarkMode),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDarkMode),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String uuid) {
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
                    'هل أنت متأكد من حذف هذه المعاملة؟',
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
                          transactionController.deleteTransaction(uuid);
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatFullDate(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatType(String type) {
    switch (type) {
      case 'credit': return 'إيداع';
      case 'debit': return 'سحب';
      case 'purchase': return 'شراء';
      case 'refund': return 'استرداد';
      case 'fee': return 'رسوم';
      case 'adjustment': return 'تعديل';
      case 'system': return 'نظام';
      default: return type;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'completed': return 'مكتمل';
      case 'failed': return 'فشل';
      default: return status;
    }
  }

  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status) {
      case 'completed': return AppColors.success;
      case 'pending': return AppColors.warning;
      case 'failed': return AppColors.error;
      default: return AppColors.textPrimary(isDarkMode);
    }
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
                        'إدارة معاملات المحفظة',
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
                          'معاملة جديدة',
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
                        onPressed: _showCreateTransactionDialog,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Search and filter bar
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 800.w,
                        minWidth: 600.w,
                      ),
                      child: Container(
                        height: 56.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Expanded(
                              child: TextField(
                                textDirection: TextDirection.rtl,
                                controller: _searchController,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textPrimary(isDarkMode),
                                ),
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  hintText: 'ابحث في المعرف أو الملاحظات...',
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    color: AppColors.textSecondary(isDarkMode),
                                  ),
                                  prefixIcon: Icon(Icons.search, size: 22.r),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                ),
                                onChanged: (value) {
                                  // Implement search functionality
                                  if (value.isEmpty) {
                                    transactionController.resetFilters();
                                  } else {
                                    // You can implement search by UUID or note
                                    transactionController.filterWalletUuid.value = value;
                                    transactionController.fetchTransactions();
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            IconButton(
                              icon: Icon(Icons.filter_list, size: 22.r),
                              onPressed: _showFilterDialog,
                              tooltip: 'تصفية',
                            ),
                            SizedBox(width: 8.w),
                            Obx(() => transactionController.isLoadingTransactions.value
                                ? CircularProgressIndicator( color: AppColors.primary)
                                : IconButton(
                                    icon: Icon(Icons.refresh, size: 22.r),
                                    onPressed: () {
                                      transactionController.resetFilters();
                                      _searchController.clear();
                                    },
                                    tooltip: 'تحديث',
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Transactions table
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
                        child: Obx(() {
                          if (transactionController.isLoadingTransactions.value) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3.r,
                              ),
                            );
                          }
                          
                          if (transactionController.transactions.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long, size: 64.r, color: AppColors.textSecondary(isDarkMode)),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'لا توجد معاملات',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: AppTextStyles.tajawal,
                                      color: AppColors.textSecondary(isDarkMode),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return CustomScrollView(
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
                                          "التاريخ",
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
                                          "النوع",
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
                                          "المبلغ",
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
                                          "الرصيد قبل",
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
                                          "الرصيد بعد",
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
                                          "الحالة",
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
                              
                              // Transactions list
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final transaction = transactionController.transactions[index];
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
                                              _formatDate(transaction.createdAt),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              _formatType(transaction.type),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                fontWeight: FontWeight.bold,
                                                color: transaction.type == 'credit' || transaction.type == 'refund'
                                                  ? AppColors.success 
                                                  : AppColors.error,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              transaction.balanceBefore.toStringAsFixed(2),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              transaction.balanceAfter.toStringAsFixed(2),
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
                                            flex: 1,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(transaction.status, isDarkMode).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                              child: Text(
                                                _formatStatus(transaction.status),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontFamily: AppTextStyles.tajawal,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getStatusColor(transaction.status, isDarkMode),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.visibility, size: 18.r, color: AppColors.primary),
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  onPressed: () => _showTransactionDetails(transaction),
                                                ),
                                                SizedBox(width: 8.w),
                                                IconButton(
                                                  icon: Icon(Icons.delete, size: 18.r, color: AppColors.error),
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  onPressed: () => _showDeleteDialog(transaction.uuid),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: transactionController.transactions.length,
                                ),
                              ),
                            ],
                          );
                        }),
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
}