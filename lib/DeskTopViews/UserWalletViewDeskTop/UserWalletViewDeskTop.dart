import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';

import '../../controllers/user_wallet_controller.dart';
import '../../core/data/model/UserWallet.dart';

class UserWalletViewDeskTop extends StatefulWidget {
  const UserWalletViewDeskTop({Key? key}) : super(key: key);

  @override
  _UserWalletViewDeskTopState createState() => _UserWalletViewDeskTopState();
}

class _UserWalletViewDeskTopState extends State<UserWalletViewDeskTop> {
  final UserWalletController controller = Get.put(UserWalletController());
  final TextEditingController _creditAmountController = TextEditingController();
  final TextEditingController _debitAmountController = TextEditingController();
  final TextEditingController _creditNoteController = TextEditingController();
  final TextEditingController _debitNoteController = TextEditingController();
  
  UserWallet? _selectedWallet;
  String _filter = 'الكل';
  final ScrollController _horizontalScrollController = ScrollController();

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

    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 80.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w, minWidth: 400.w),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.account_balance_wallet, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text('شحن محفظة المستخدم', style: TextStyle(
                        fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700, 
                        color: AppColors.textPrimary(isDark),
                      )),
                    ],
                  ),
                  SizedBox(height: 24.h),
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
                  SizedBox(height: 16.h),
                  _buildTextField('المبلغ', Icons.attach_money, _creditAmountController, isDark,
                      keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  SizedBox(height: 16.h),
                  _buildTextField('ملاحظات (اختياري)', Icons.note, _creditNoteController, isDark),
                  SizedBox(height: 24.h),
                  _buildCreditActionButtons(isDark, wallet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDebitDialog(UserWallet wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _debitAmountController.clear();
    _debitNoteController.clear();
    _selectedWallet = wallet;

    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 80.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w, minWidth: 400.w),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.money_off, size: 24.r, color: AppColors.error),
                      SizedBox(width: 10.w),
                      Text('خصم من محفظة المستخدم', style: TextStyle(
                        fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700, 
                        color: AppColors.textPrimary(isDark),
                      )),
                    ],
                  ),
                  SizedBox(height: 24.h),
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
                  SizedBox(height: 16.h),
                  _buildTextField('المبلغ', Icons.attach_money, _debitAmountController, isDark,
                      keyboardType: TextInputType.numberWithOptions(decimal: true)),
                  SizedBox(height: 16.h),
                  _buildTextField('ملاحظات (اختياري)', Icons.note, _debitNoteController, isDark),
                  SizedBox(height: 24.h),
                  _buildDebitActionButtons(isDark, wallet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(UserWallet wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w, minWidth: 300.w, maxHeight: 300.h),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(textDirection: TextDirection.rtl, children: [
                    Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error),
                    SizedBox(width:10.w),
                    Text('تأكيد الحذف', style: TextStyle(
                      fontSize:15.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700, color: AppColors.error,
                    )),
                  ]),
                  SizedBox(height:16.h),
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
                  Text('سيتم حذف جميع البيانات المرتبطة بها!', style: TextStyle(
                    fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.error.withOpacity(0.8),
                  )),
                  SizedBox(height:24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionsMenu(UserWallet wallet, BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'credit',
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.add_circle, size: 18.r, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text('شحن المحفظة', style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
              )),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'debit',
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.remove_circle, size: 18.r, color: AppColors.error),
              SizedBox(width: 8.w),
              Text('خصم من المحفظة', style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
              )),
            ],
          ),
        ),
        if (wallet.status == 'active') PopupMenuItem(
          value: 'freeze',
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.pause_circle, size: 18.r, color: Colors.orange),
              SizedBox(width: 8.w),
              Text('تجميد المحفظة', style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
              )),
            ],
          ),
        ),
        if (wallet.status == 'frozen') PopupMenuItem(
          value: 'activate',
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.play_circle, size: 18.r, color: Colors.green),
              SizedBox(width: 8.w),
              Text('تنشيط المحفظة', style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
              )),
            ],
          ),
        ),
        if (wallet.status != 'closed') PopupMenuItem(
          value: 'close',
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.lock, size: 18.r, color: Colors.blueGrey),
              SizedBox(width: 8.w),
              Text('إغلاق المحفظة', style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
              )),
            ],
          ),
        ),
        if (wallet.status == 'closed') PopupMenuItem(
          value: 'open',
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.lock_open, size: 18.r, color: Colors.green),
              SizedBox(width: 8.w),
              Text('فتح المحفظة', style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
              )),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.delete, size: 18.r, color: AppColors.error),
              SizedBox(width: 8.w),
              Text('حذف المحفظة', style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
              )),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'credit':
            _showCreditDialog(wallet);
            break;
          case 'debit':
            _showDebitDialog(wallet);
            break;
          case 'freeze':
            controller.freezeWallet(wallet.uuid!);
            break;
          case 'activate':
            controller.activateWallet(wallet.uuid!);
            break;
          case 'close':
            controller.closeWallet(wallet.uuid!);
            break;
          case 'open':
            controller.openWallet(wallet.uuid!);
            break;
          case 'delete':
            _showDeleteDialog(wallet);
            break;
        }
      }
    });
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

  Widget _buildCreditActionButtons(bool isDark, UserWallet wallet) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('إلغاء', style: TextStyle(
            fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          ))),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          onPressed: controller.isSaving.value ? null : () async {
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
          child: controller.isSaving.value
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_circle, size: 20.r),
                SizedBox(width: 8.w),
                Text('شحن المحفظة', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                )),
              ]),
        )),
      ],
    );
  }

  Widget _buildDebitActionButtons(bool isDark, UserWallet wallet) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('إلغاء', style: TextStyle(
            fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          ))),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          onPressed: controller.isSaving.value ? null : () async {
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
          child: controller.isSaving.value
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.remove_circle, size: 20.r),
                SizedBox(width: 8.w),
                Text('خصم من المحفظة', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                )),
              ]),
        )),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor1 = isDark ? AppColors.grey900 : AppColors.grey50;
    final rowColor2 = isDark ? AppColors.grey800 : AppColors.grey100;
    
    return Scaffold(
      body: Row(children: [
        AdminSidebarDeskTop(),
        Expanded(child: Padding(
          padding: EdgeInsets.symmetric(horizontal:24.w, vertical:16.h),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, textDirection: TextDirection.rtl, children: [
            Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('إدارة محافظ المستخدمين', style: TextStyle(
                fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
              )),
              // Filter dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filter,
                    items: ['الكل', 'نشطة', 'مجمدة', 'مغلقة', 'رصيد مرتفع', 'رصيد منخفض']
                      .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textPrimary(isDark),
                        )),
                      )).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _filter = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ]),
            SizedBox(height:16.h),
            SizedBox(height:24.h),
            Expanded(child: Container(
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius:12, offset: Offset(0,4),
                )]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Column(
                  children: [
                    // Header with horizontal scroll
                    Container(
                      padding: EdgeInsets.symmetric(vertical:16.h, horizontal:16.w),
                      decoration: BoxDecoration(color: isDark ? AppColors.grey800 : AppColors.grey200),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _horizontalScrollController,
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 100.w, child: _buildHeaderCell("رقم المستخدم", TextAlign.center)),
                            SizedBox(width: 200.w, child: _buildHeaderCell("البريد الإلكتروني", TextAlign.center)),
                            SizedBox(width: 200.w, child: _buildHeaderCell("معرف المحفظة", TextAlign.center)),
                            SizedBox(width: 100.w, child: _buildHeaderCell("الرصيد", TextAlign.center)),
                            SizedBox(width: 80.w, child: _buildHeaderCell("العملة", TextAlign.center)),
                            SizedBox(width: 100.w, child: _buildHeaderCell("الحالة", TextAlign.center)),
                            SizedBox(width: 200.w, child: _buildHeaderCell("آخر تحديث", TextAlign.center)),
                            SizedBox(width: 120.w, child: _buildHeaderCell("الإجراءات", TextAlign.center)),
                          ],
                        ),
                      ),
                    ),
                    // Data rows
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth:3.r));
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
                          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.account_balance_wallet, size:64.r, color: AppColors.textSecondary(isDark)),
                            SizedBox(height:16.h),
                            Text('لا توجد محافظ', style: TextStyle(
                              fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                          ]));
                        }
                        
                        return ListView.builder(
                          itemCount: filteredWallets.length,
                          itemBuilder: (context, index) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _horizontalScrollController,
                              child: _buildWalletRow(
                                filteredWallets[index], 
                                index, 
                                isDark,
                                index % 2 == 0 ? rowColor1 : rowColor2
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            )),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Text(text, 
      textAlign: align,
      style: TextStyle(
        fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
        fontWeight: FontWeight.w700, 
        color: AppColors.textPrimary(Theme.of(context).brightness == Brightness.dark),
      ));
  }

  Widget _buildWalletRow(UserWallet wallet, int index, bool isDark, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical:14.h, horizontal:16.w),
      color: color,
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 100.w, child: _buildCell(wallet.userId.toString(), TextAlign.center)),
          SizedBox(width: 200.w, child: _buildCell(wallet.user?.email ?? 'غير متوفر', TextAlign.center)),
          SizedBox(width: 200.w, child: _buildCell(wallet.uuid ?? 'غير متوفر', TextAlign.center, color: AppColors.textSecondary(isDark))),
          SizedBox(width: 100.w, child: _buildCell('${wallet.balance}', TextAlign.center, fontWeight: FontWeight.bold)),
          SizedBox(width: 80.w, child: _buildCell(wallet.currency, TextAlign.center)),
          SizedBox(width: 100.w, child: _buildStatusCell(wallet.status)),
          SizedBox(width: 200.w, child: _buildCell(
            wallet.lastChangedAt != null 
              ? '${wallet.lastChangedAt!.toLocal()}'
              : 'غير معروف', 
            TextAlign.center,
            color: AppColors.textSecondary(isDark),
          )),
          SizedBox(
            width: 120.w,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.more_vert, size: 22.r),
                onPressed:()
                
                {
                  _showActionsMenu(wallet, context
                  );
                } 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, TextAlign align, {
    Color? color, 
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Text(text, 
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
        fontWeight: fontWeight, color: color,
      ));
  }

  Widget _buildStatusCell(String status) {
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }


 
}