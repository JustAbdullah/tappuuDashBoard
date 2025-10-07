import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/user_wallet_controller.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/UserWallet.dart';

import '../AdminSidebar.dart';

class UserWalletViewMobile extends StatefulWidget {
  const UserWalletViewMobile({Key? key}) : super(key: key);

  @override
  _UserWalletViewMobileState createState() => _UserWalletViewMobileState();
}

class _UserWalletViewMobileState extends State<UserWalletViewMobile> {
  final UserWalletController controller = Get.put(UserWalletController());
  final TextEditingController _creditAmountController = TextEditingController();
  final TextEditingController _debitAmountController = TextEditingController();
  final TextEditingController _creditNoteController = TextEditingController();
  final TextEditingController _debitNoteController = TextEditingController();
  
  UserWallet? _selectedWallet;
  String _filter = 'الكل';

  @override
  void initState() {
    super.initState();
    controller.fetchAllWallets();
  }

  void _showCreditDialog(UserWallet wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _creditAmountController.clear();
    _creditNoteController.clear();
    _selectedWallet = wallet;

    Get.bottomSheet(
      _buildBottomSheet(
        title: 'شحن محفظة المستخدم',
        icon: Icons.account_balance_wallet,
        onSave: () async {
          if (_creditAmountController.text.isEmpty) {
            Get.snackbar('تحذير', 'الرجاء إدخال مبلغ الشحن',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          final amount = double.tryParse(_creditAmountController.text);
          if (amount == null || amount <= 0) {
            Get.snackbar('تحذير', 'الرجاء إدخال مبلغ صحيح',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          await controller.creditWallet(
            walletUuid: wallet.uuid.toString(),
            amount: amount,
            note: _creditNoteController.text,
          );
          Get.back();
        },
        isDark: isDark,
        wallet: wallet,
        isCredit: true,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
    );
  }

  void _showDebitDialog(UserWallet wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _debitAmountController.clear();
    _debitNoteController.clear();
    _selectedWallet = wallet;

    Get.bottomSheet(
      _buildBottomSheet(
        title: 'خصم من محفظة المستخدم',
        icon: Icons.money_off,
        onSave: () async {
          if (_debitAmountController.text.isEmpty) {
            Get.snackbar('تحذير', 'الرجاء إدخال مبلغ الخصم',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          final amount = double.tryParse(_debitAmountController.text);
          if (amount == null || amount <= 0) {
            Get.snackbar('تحذير', 'الرجاء إدخال مبلغ صحيح',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          if (amount > wallet.balance) {
            Get.snackbar('تحذير', 'المبلغ المطلوب أكبر من الرصيد المتاح',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          await controller.debitWallet(
            walletUuid: wallet.uuid.toString(),
            amount: amount,
            note: _debitNoteController.text,
          );
          Get.back();
        },
        isDark: isDark,
        wallet: wallet,
        isCredit: false,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
    );
  }

  void _showDeleteDialog(UserWallet wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error),
            SizedBox(width:10.w),
            Text('تأكيد الحذف', style: TextStyle(
              fontSize:15.sp, fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w700, color: AppColors.error,
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من حذف محفظة المستخدم ${wallet.userId}؟', style: TextStyle(
              fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark)),
            ),
            if (wallet.user?.email != null) ...[
              SizedBox(height: 8.h),
              Text('البريد الإلكتروني: ${wallet.user!.email}', style: TextStyle(
                fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
            ],
            SizedBox(height: 8.h),
            Text('سيتم حذف جميع البيانات المرتبطة بها!', style: TextStyle(
              fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.error.withOpacity(0.8),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(
              fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textSecondary(isDark),
            )),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
            onPressed: controller.isDeleting.value ? null : () {
              controller.deleteWallet(wallet.uuid!);
              Get.back();
            },
            child: controller.isDeleting.value
              ? CircularProgressIndicator(color: Colors.white, strokeWidth:2.r)
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.delete, size:20.r),
                  SizedBox(width:8.w),
                  Text('حذف', style: TextStyle(
                    fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                  )),
                ]),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomSheet({
    required String title,
    required IconData icon,
    required VoidCallback onSave,
    required bool isDark,
    required UserWallet wallet,
    required bool isCredit,
  }) {
    final amountController = isCredit ? _creditAmountController : _debitAmountController;
    final noteController = isCredit ? _creditNoteController : _debitNoteController;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        left: 16.w,
        right: 16.w,
        top: 20.h
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, size: 24.r, color: isCredit ? AppColors.primary : AppColors.error),
              SizedBox(width: 10.w),
              Text(title, style: TextStyle(
                fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w700, 
                color: AppColors.textPrimary(isDark),
              )),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 22.r),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text('المستخدم: ${wallet.userId}',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 16.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark),
          )),
          if (wallet.user?.email != null) ...[
            SizedBox(height: 8.h),
            Text('البريد الإلكتروني: ${wallet.user!.email}',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
            )),
          ],
          SizedBox(height: 8.h),
          Text('الرصيد الحالي: ${wallet.balance} ${wallet.currency}',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(isDark),
          )),
          SizedBox(height: 16.h),
          _buildTextField('المبلغ', Icons.attach_money, amountController, isDark,
              keyboardType: TextInputType.numberWithOptions(decimal: true)),
          SizedBox(height: 16.h),
          _buildTextField('ملاحظات (اختياري)', Icons.note, noteController, isDark),
          SizedBox(height: 24.h),
          _buildActionButtons(onSave, isDark, isCredit),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, 
      bool isDark, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 16.sp, 
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
          color: AppColors.textSecondary(isDark)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: AppColors.card(isDark),
        prefixIcon: Icon(icon, size: 22.r),
      ),
    );
  }

  Widget _buildActionButtons(VoidCallback onSave, bool isDark, bool isCredit) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCredit ? AppColors.primary : AppColors.error,
              foregroundColor: AppColors.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
            onPressed: controller.isSaving.value ? null : onSave,
            child: controller.isSaving.value
              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isCredit ? Icons.add_circle : Icons.remove_circle, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(isCredit ? 'شحن المحفظة' : 'خصم من المحفظة', style: TextStyle(
                      fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.bold,
                    )),
                  ]),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(
              fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textSecondary(isDark),
            )),
          ),
        ),
      ],
    );
  }

  void _showActionsMenu(UserWallet wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Text(
                  'إجراءات المحفظة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.add_circle, size: 24.r, color: AppColors.primary),
                title: Text('شحن المحفظة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
                onTap: () {
                  Navigator.pop(context);
                  _showCreditDialog(wallet);
                },
              ),
              ListTile(
                leading: Icon(Icons.remove_circle, size: 24.r, color: AppColors.error),
                title: Text('خصم من المحفظة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
                onTap: () {
                  Navigator.pop(context);
                  _showDebitDialog(wallet);
                },
              ),
              if (wallet.status == 'active') ListTile(
                leading: Icon(Icons.pause_circle, size: 24.r, color: Colors.orange),
                title: Text('تجميد المحفظة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
                onTap: () {
                  Navigator.pop(context);
                  controller.freezeWallet(wallet.uuid!);
                },
              ),
              if (wallet.status == 'frozen') ListTile(
                leading: Icon(Icons.play_circle, size: 24.r, color: Colors.green),
                title: Text('تنشيط المحفظة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
                onTap: () {
                  Navigator.pop(context);
                  controller.activateWallet(wallet.uuid!);
                },
              ),
              if (wallet.status != 'closed') ListTile(
                leading: Icon(Icons.lock, size: 24.r, color: Colors.blueGrey),
                title: Text('إغلاق المحفظة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
                onTap: () {
                  Navigator.pop(context);
                  controller.closeWallet(wallet.uuid!);
                },
              ),
              if (wallet.status == 'closed') ListTile(
                leading: Icon(Icons.lock_open, size: 24.r, color: Colors.green),
                title: Text('فتح المحفظة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
                onTap: () {
                  Navigator.pop(context);
                  controller.openWallet(wallet.uuid!);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, size: 24.r, color: AppColors.error),
                title: Text('حذف المحفظة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(wallet);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context),
        ),
      ),
      appBar: AppBar(
        title: Text('إدارة محافظ المستخدمين', 
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          )
        ),
        actions: [
          // Filter dropdown
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, size: 22.r),
            onSelected: (String newValue) {
              setState(() {
                _filter = newValue;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'الكل',
                child: Text('الكل', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
              ),
              PopupMenuItem<String>(
                value: 'نشطة',
                child: Text('نشطة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
              ),
              PopupMenuItem<String>(
                value: 'مجمدة',
                child: Text('مجمدة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
              ),
              PopupMenuItem<String>(
                value: 'مغلقة',
                child: Text('مغلقة', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
              ),
              PopupMenuItem<String>(
                value: 'رصيد مرتفع',
                child: Text('رصيد مرتفع', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
              ),
              PopupMenuItem<String>(
                value: 'رصيد منخفض',
                child: Text('رصيد منخفض', style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                )),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // Filter indicator
            if (_filter != 'الكل') ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt, size: 16.r, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      'عرض: $_filter',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _filter = 'الكل';
                        });
                      },
                      child: Icon(Icons.close, size: 16.r, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            
            // Wallets list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary, 
                      strokeWidth: 3.r
                    ),
                  );
                }
                
                // Filter wallets based on selection
                List<UserWallet> filteredWallets = controller.wallets;
                if (_filter == 'نشطة') {
                  filteredWallets = controller.wallets.where((w) => w.status == 'active').toList();
                } else if (_filter == 'مجمدة') {
                  filteredWallets = controller.wallets.where((w) => w.status == 'frozen').toList();
                } else if (_filter == 'مغلقة') {
                  filteredWallets = controller.wallets.where((w) => w.status == 'closed').toList();
                } else if (_filter == 'رصيد مرتفع') {
                  filteredWallets = controller.wallets.where((w) => w.balance > 1000).toList();
                } else if (_filter == 'رصيد منخفض') {
                  filteredWallets = controller.wallets.where((w) => w.balance <= 1000).toList();
                }
                
                if (filteredWallets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet, size: 64.r, 
                             color: AppColors.textSecondary(isDark)),
                        SizedBox(height: 16.h),
                        Text('لا توجد محافظ', style: TextStyle(
                          fontSize: 16.sp, fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredWallets.length,
                  itemBuilder: (context, index) {
                    final wallet = filteredWallets[index];
                    return _buildWalletCard(wallet, isDark);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(UserWallet wallet, bool isDark) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المستخدم: ${wallet.userId}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                _buildStatusChip(wallet.status),
              ],
            ),
            
            if (wallet.user?.email != null) ...[
              SizedBox(height: 8.h),
              Text(
                wallet.user!.email.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
            
            SizedBox(height: 12.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWalletDetail('الرصيد', '${wallet.balance} ${wallet.currency}', Icons.account_balance_wallet),
                _buildWalletDetail('آخر تحديث', _formatDate(wallet.lastChangedAt), Icons.access_time),
              ],
            ),
            
            if (wallet.uuid != null) ...[
              SizedBox(height: 12.h),
              Text(
                'معرف المحفظة: ${wallet.uuid}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            SizedBox(height: 16.h),
            
            ElevatedButton(
              onPressed: () => _showActionsMenu(wallet),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.more_vert, size: 20.r),
                  SizedBox(width: 8.w),
                  Text('الإجراءات', style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'نشطة';
        break;
      case 'frozen':
        statusColor = Colors.orange;
        statusText = 'مجمدة';
        break;
      case 'closed':
        statusColor = Colors.red;
        statusText = 'مغلقة';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildWalletDetail(String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(isDark),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير معروف';
    
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
  }
}