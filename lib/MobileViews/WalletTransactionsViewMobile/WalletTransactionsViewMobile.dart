import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../controllers/WalletTransactionController.dart';
import '../../core/data/model/WalletTransaction.dart';
import '../AdminSidebar.dart';

class WalletTransactionsViewMobile extends StatefulWidget {
  const WalletTransactionsViewMobile({Key? key}) : super(key: key);

  @override
  _WalletTransactionsViewMobileState createState() => _WalletTransactionsViewMobileState();
}

class _WalletTransactionsViewMobileState extends State<WalletTransactionsViewMobile> {
  final WalletTransactionController transactionController = Get.put(WalletTransactionController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _walletUuidController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  String _selectedTransactionType = 'credit';

  @override
  void initState() {
    super.initState();
    transactionController.fetchTransactions();
  }

  void _showFilterDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface(isDarkMode),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary(isDarkMode),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
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
              _buildFilterTextField('معرف المحفظة', transactionController.filterWalletUuid.toString(), isDarkMode),
              SizedBox(height: 16.h),
              
              _buildFilterTextField('معرف المستخدم', transactionController.filterUserId.toString(), isDarkMode, isNumber: true),
              SizedBox(height: 16.h),
              
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
              SizedBox(height: 16.h),
              
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
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildFilterTextField('الحد الأدنى', transactionController.filterMinAmount.toString(), isDarkMode, isNumber: true),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildFilterTextField('الحد الأقصى', transactionController.filterMaxAmount.toString(), isDarkMode, isNumber: true),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDateField('من تاريخ', transactionController.filterFromDate.value, isDarkMode, (date) {
                      if (date != null) {
                        transactionController.filterFromDate.value = date.toIso8601String().split('T')[0];
                      }
                    }),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildDateField('إلى تاريخ', transactionController.filterToDate.value, isDarkMode, (date) {
                      if (date != null) {
                        transactionController.filterToDate.value = date.toIso8601String().split('T')[0];
                      }
                    }),
                  ),
                ],
              ),
              SizedBox(height: 32.h),
              
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        foregroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        transactionController.resetFilters();
                        Get.back();
                      },
                      child: Text(
                        'إعادة التعيين',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        transactionController.fetchTransactions();
                        Get.back();
                      },
                      child: Text(
                        'تطبيق الفلتر',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTextField(String label, String initialValue, bool isDarkMode, {bool isNumber = false}) {
    final controller = TextEditingController(text: initialValue);
    
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
      onChanged: (value) {
        if (isNumber) {
          if (label.contains('المحفظة')) {
            transactionController.filterWalletUuid.value = value;
          } else if (label.contains('المستخدم')) {
            transactionController.filterUserId.value = int.tryParse(value) ?? 0;
          } else if (label.contains('الأدنى')) {
            transactionController.filterMinAmount.value = double.tryParse(value) ?? 0.0;
          } else if (label.contains('الأقصى')) {
            transactionController.filterMaxAmount.value = double.tryParse(value) ?? 0.0;
          }
        } else {
          transactionController.filterWalletUuid.value = value;
        }
      },
    );
  }

  Widget _buildDateField(String label, String initialValue, bool isDarkMode, Function(DateTime?) onDateSelected) {
    final controller = TextEditingController(text: initialValue);
    
    return TextField(
      controller: controller,
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
          controller.text = formattedDate;
          onDateSelected(date);
        }
      },
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required Map<String, String> items,
    required Function(String?) onChanged,
    required bool isDarkMode,
  }) {
    String selectedValue = items.containsValue(value) ? value : items.values.first;
    
    return DropdownButtonFormField<String>(
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
    );
  }

  void _showCreateTransactionDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface(isDarkMode),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary(isDarkMode),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.add, size: 24.r, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Text(
                    'معاملة جديدة',
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
                  Expanded(
                    child: TextButton(
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
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
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
                      child: Text(
                        'إنشاء',
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
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(WalletTransaction transaction) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface(isDarkMode),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary(isDarkMode),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
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
      Dialog(
        backgroundColor: AppColors.surface(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
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
    
    return Scaffold(
      drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context),
        ),
      ),
      appBar: AppBar(
        title: Text('إدارة معاملات المحفظة', 
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          )
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 22.r),
            onPressed: _showCreateTransactionDialog,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // Search bar
            Container(
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
                        if (value.isEmpty) {
                          transactionController.resetFilters();
                        } else {
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
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Transactions list
            Expanded(
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
                        Icon(Icons.receipt_long, size: 48.r, 
                             color: AppColors.textSecondary(isDarkMode)),
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
                
                return ListView.builder(
                  itemCount: transactionController.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactionController.transactions[index];
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(transaction.createdAt),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    color: AppColors.textSecondary(isDarkMode),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 4.h),
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
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 12.h),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatType(transaction.type),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(isDarkMode),
                                  ),
                                ),
                                Text(
                                  '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    fontWeight: FontWeight.bold,
                                    color: transaction.type == 'credit' || transaction.type == 'refund'
                                      ? AppColors.success 
                                      : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTransactionStatItem('قبل', transaction.balanceBefore.toStringAsFixed(2)),
                                _buildTransactionStatItem('بعد', transaction.balanceAfter.toStringAsFixed(2), isHighlighted: true),
                              ],
                            ),
                            
                            SizedBox(height: 12.h),
                            
                            Text(
                              'المعرف: ${transaction.uuid}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDarkMode),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.visibility, size: 20.r, 
                                          color: AppColors.primary),
                                  onPressed: () => _showTransactionDetails(transaction),
                                ),
                                SizedBox(width: 8.w),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 20.r, 
                                          color: AppColors.error),
                                  onPressed: () => _showDeleteDialog(transaction.uuid),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionStatItem(String title, String value, {bool isHighlighted = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDarkMode),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
            fontWeight: FontWeight.bold,
            color: isHighlighted 
              ? AppColors.primary 
              : AppColors.textPrimary(isDarkMode),
          ),
        ),
      ],
    );
  }
}