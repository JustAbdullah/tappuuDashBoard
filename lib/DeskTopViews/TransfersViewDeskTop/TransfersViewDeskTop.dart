import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/core/data/model/TransferProofModel.dart';
import '../../controllers/TransferProofController.dart';
import '../ImageUploadWidget.dart';

class TransfersViewDeskTop extends StatefulWidget {
  const TransfersViewDeskTop({Key? key}) : super(key: key);

  @override
  _TransfersViewDeskTopState createState() => _TransfersViewDeskTopState();
}

class _TransfersViewDeskTopState extends State<TransfersViewDeskTop> {
  final TransferProofController controller = Get.put(TransferProofController());
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankAccountIdController = TextEditingController();
  final TextEditingController _walletIdController = TextEditingController();
  final TextEditingController _sourceAccountController = TextEditingController();
  final TextEditingController _rejectCommentController = TextEditingController();
  final TextEditingController _approveAmountController = TextEditingController();
  final TextEditingController _approveCommentController = TextEditingController();
  
  String _filter = 'الكل';

  @override
  void initState() {
    super.initState();
    controller.fetchProofs();
  }

  void _showAddDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    controller.removeImage();
    _amountController.clear();
    _bankAccountIdController.clear();
    _walletIdController.clear();
    _sourceAccountController.clear();

    Get.dialog(_buildDialog(
      title: 'إضافة إثبات تحويل جديد',
      icon: Icons.payment,
      amountController: _amountController,
      bankAccountIdController: _bankAccountIdController,
      walletIdController: _walletIdController,
      sourceAccountController: _sourceAccountController,
      onSave: () async {
        if (_amountController.text.isEmpty || 
            _bankAccountIdController.text.isEmpty ||
            _walletIdController.text.isEmpty) {
          Get.snackbar('تحذير', 'الرجاء إدخال جميع البيانات المطلوبة',
            backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
        
        final amount = double.tryParse(_amountController.text);
        final bankAccountId = int.tryParse(_bankAccountIdController.text);
        final walletId = int.tryParse(_walletIdController.text);
        
        if (amount == null || bankAccountId == null || walletId == null) {
          Get.snackbar('تحذير', 'الرجاء إدخال بيانات صحيحة',
            backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }

        final success = await controller.createProof(
          bankAccountId: bankAccountId,
          walletId: walletId,
          amount: amount,
          sourceAccountNumber: _sourceAccountController.text.isNotEmpty 
              ? _sourceAccountController.text 
              : null,
        );
        
        if (success) {
          Get.back();
        }
      },
      isDark: isDark,
    ));
  }

  Widget _buildDialog({
    required String title,
    required IconData icon,
    required TextEditingController amountController,
    required TextEditingController bankAccountIdController,
    required TextEditingController walletIdController,
    required TextEditingController sourceAccountController,
    required VoidCallback onSave,
    required bool isDark,
  }) {
    return Center(
      child: Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 80.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500.w, minWidth: 400.w, maxHeight: 600.h),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(icon, size: 24.r, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Text(title, style: TextStyle(
                      fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700, 
                      color: AppColors.textPrimary(isDark),
                    )),
                  ],
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField('المبلغ', Icons.attach_money, amountController, isDark, 
                            keyboardType: TextInputType.numberWithOptions(decimal: true)),
                        SizedBox(height: 16.h),
                        _buildTextField('رقم الحساب البنكي', Icons.account_balance, bankAccountIdController, isDark, 
                            keyboardType: TextInputType.number),
                        SizedBox(height: 16.h),
                        _buildTextField('رقم المحفظة', Icons.wallet, walletIdController, isDark, 
                            keyboardType: TextInputType.number),
                        SizedBox(height: 16.h),
                        _buildTextField('رقم الحساب المصدر (اختياري)', Icons.credit_card, sourceAccountController, isDark,
                            keyboardType: TextInputType.text),
                        
                        SizedBox(height: 16.h),
                        Text('صورة إثبات التحويل', style: TextStyle(
                          fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                        SizedBox(height: 8.h),
                        Obx(() => ImageUploadWidget(
                          imageBytes: controller.imageBytes.value,
                          onPickImage: controller.pickImage,
                          onRemoveImage: controller.removeImage,
                        )),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                _buildDialogActionButtons(onSave, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, 
      bool isDark, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: maxLines == 1 ? 16.sp : 14.sp,
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

  Widget _buildDialogActionButtons(VoidCallback onSave, bool isDark) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('إلغاء', style: TextStyle(
            fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          )),
        ),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          onPressed: controller.isSaving.value ? null : onSave,
          child: controller.isSaving.value
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add, size: 20.r),
                SizedBox(width: 8.w),
                Text('إضافة', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                )),
              ]),
        )),
      ],
    );
  }

  void _showApproveDialog(TransferProofModel proof) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _approveAmountController.text = proof.amount.toString();
    _approveCommentController.clear();
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w, minWidth: 400.w, maxHeight: 500.h),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(textDirection: TextDirection.rtl, children: [
                    Icon(Icons.check_circle, size:24.r, color: AppColors.success),
                    SizedBox(width:10.w),
                    Text('تأكيد الموافقة على الإثبات', style: TextStyle(
                      fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700, color: AppColors.success,
                    )),
                  ]),
                  SizedBox(height:16.h),
                  
                  // مبلغ الشحن
                  Text('مبلغ الشحن للمحفظة:', style: TextStyle(
                    fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.bold,
                  )),
                  SizedBox(height:8.h),
                  TextField(
                    controller: _approveAmountController,
                    textDirection: TextDirection.rtl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark)),
                    decoration: InputDecoration(
                      hintText: 'أدخل مبلغ الشحن...',
                      hintStyle: TextStyle(
                        fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                      filled: true,
                      fillColor: AppColors.card(isDark),
                      prefixIcon: Icon(Icons.attach_money, size: 20.r),
                    ),
                  ),
                  SizedBox(height:8.h),
                  Text(
                    'ملاحظة: إذا لم تدخل مبلغاً سيتم استخدام المبلغ الأصلي (${proof.amount} ل.س)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: Colors.orange,
                    ),
                  ),
                  
                  SizedBox(height:16.h),
                  
                  // التعليق
                  Text('تعليق الموافقة (اختياري):', style: TextStyle(
                    fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDark),
                  )),
                  SizedBox(height:8.h),
                  TextField(
                    controller: _approveCommentController,
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark)),
                    decoration: InputDecoration(
                      hintText: 'أدخل تعليقاً للموافقة...',
                      hintStyle: TextStyle(
                        fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                      filled: true,
                      fillColor: AppColors.card(isDark),
                    ),
                  ),
                  
                  SizedBox(height:24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('إلغاء', style: TextStyle(
                          fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        onPressed: () {
                          final amount = double.tryParse(_approveAmountController.text) ?? proof.amount;
                          if (amount <= 0) {
                            Get.snackbar('خطأ', 'المبلغ يجب أن يكون أكبر من الصفر',
                              backgroundColor: Colors.red, colorText: Colors.white);
                            return;
                          }
                          
                          // TODO: تحتاج لتعديل الـ controller لدعم المبلغ المخصص والتعليق
                          controller.approveProof(proof.id);
                          Get.back();
                        },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.check, size:20.r),
                          SizedBox(width:8.w),
                          Text('موافقة وشحن', style: TextStyle(
                            fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          )),
                        ]),
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

  void _showRejectDialog(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _rejectCommentController.clear();
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500.w, minWidth: 400.w, maxHeight: 400.h),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(textDirection: TextDirection.rtl, children: [
                    Icon(Icons.cancel, size:24.r, color: AppColors.error),
                    SizedBox(width:10.w),
                    Text('رفض الإثبات', style: TextStyle(
                      fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700, color: AppColors.error,
                    )),
                  ]),
                  SizedBox(height:16.h),
                  Text('سبب الرفض:', style: TextStyle(
                    fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.bold,
                  )),
                  SizedBox(height:8.h),
                  TextField(
                    controller: _rejectCommentController,
                    textDirection: TextDirection.rtl,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDark)),
                    decoration: InputDecoration(
                      hintText: 'أدخل سبب الرفض...',
                      hintStyle: TextStyle(
                        fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                      filled: true,
                      fillColor: AppColors.card(isDark),
                    ),
                  ),
                  SizedBox(height:24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('إلغاء', style: TextStyle(
                          fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        onPressed: () {
                          if (_rejectCommentController.text.isEmpty) {
                            Get.snackbar('تحذير', 'يرجى إدخال سبب الرفض',
                              backgroundColor: Colors.orange, colorText: Colors.white);
                            return;
                          }
                          controller.rejectProof(id, comment: _rejectCommentController.text);
                          Get.back();
                        },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.close, size:20.r),
                          SizedBox(width:8.w),
                          Text('رفض', style: TextStyle(
                            fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          )),
                        ]),
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

  void _showDeleteDialog(int id) {
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
                  Text('هل أنت متأكد من حذف هذا الإثبات؟', style: TextStyle(
                    fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDark)),
                  ),
                  Text('سيتم حذف جميع البيانات المرتبطة به!', style: TextStyle(
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        onPressed: () {
                          controller.deleteProof(id);
                          Get.back();
                        },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.delete, size:20.r),
                          SizedBox(width:8.w),
                          Text('حذف', style: TextStyle(
                            fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          )),
                        ]),
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

  void _showImageDialog(String imageUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 50.h),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('صورة الإثبات', style: TextStyle(
                      fontSize: 16.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(isDark),
                    )),
                    SizedBox(height: 16.h),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 600.w,
                        maxHeight: 500.h,
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 300.w,
                            height: 200.h,
                            decoration: BoxDecoration(
                              color: AppColors.card(isDark),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 48.r, color: AppColors.error),
                                SizedBox(height: 8.h),
                                Text('فشل تحميل الصورة', style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary(isDark),
                                )),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10.r,
                left: 10.r,
                child: IconButton(
                  icon: Icon(Icons.close, size: 24.r, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        statusText = 'قيد الانتظار';
        break;
      case 'approved':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        statusText = 'مقبول';
        break;
      case 'rejected':
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        statusText = 'مرفوض';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(TransferProofModel proof, bool isDark) {
    List<Widget> buttons = [];

    // View Image Button
    if (proof.proofImage != null && proof.proofImage!.isNotEmpty) {
      buttons.add(
        IconButton(
          icon: Icon(Icons.visibility, size: 18.r, color: AppColors.primary),
          onPressed: () => _showImageDialog(proof.proofImage!),
          tooltip: 'معاينة الصورة',
        ),
      );
      buttons.add(SizedBox(width: 4.w));
    }

    // Approve/Reject Buttons (only for pending proofs)
    if (proof.status == 'pending') {
      buttons.add(
        IconButton(
          icon: Icon(Icons.check, size: 18.r, color: AppColors.success),
          onPressed: () => _showApproveDialog(proof),
          tooltip: 'موافقة',
        ),
      );
      buttons.add(SizedBox(width: 4.w));
      buttons.add(
        IconButton(
          icon: Icon(Icons.close, size: 18.r, color: AppColors.error),
          onPressed: () => _showRejectDialog(proof.id),
          tooltip: 'رفض',
        ),
      );
      buttons.add(SizedBox(width: 4.w));
    }

    // Delete Button (always visible)
    buttons.add(
      IconButton(
        icon: Icon(Icons.delete, size: 18.r, color: AppColors.error),
        onPressed: () => _showDeleteDialog(proof.id),
        tooltip: 'حذف',
      ),
    );

    return buttons;
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
              Text('إدارة إثباتات التحويل', style: TextStyle(
                fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
              )),
            
            ]),
            SizedBox(height:16.h),
            
            // فلترة فقط بدون بحث نصي
            Center(child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth:400.w, minWidth:300.w),
              child: Container(
                height:56.h,
                padding: EdgeInsets.symmetric(horizontal:16.w),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius:12, offset: Offset(0,4),
                  )]),
                child: Row(textDirection: TextDirection.rtl, children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _filter,
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textPrimary(isDark),
                      ),
                      dropdownColor: AppColors.card(isDark),
                      items: ['الكل', 'قيد الانتظار', 'مقبول', 'مرفوض'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                          )),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _filter = newValue!;
                        });
                      },
                    ),
                  ),
                  SizedBox(width:12.w),
                  ElevatedButton(
                    onPressed: () => controller.fetchProofs(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                    child: Text('تحديث', style: TextStyle(
                      fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                    )),
                  ),
                ]),
              ),
            )),
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
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: Container(
                    padding: EdgeInsets.symmetric(vertical:16.h, horizontal:16.w),
                    decoration: BoxDecoration(color: isDark ? AppColors.grey800 : AppColors.grey200),
                    child: Row(textDirection: TextDirection.rtl, children: [
                      _buildHeaderCell("المعرف", 1),
                      _buildHeaderCell("الصورة", 1),
                      _buildHeaderCell("المبلغ", 1),
                      _buildHeaderCell("العميل", 2),
                      _buildHeaderCell("المحفظة", 2),
                      _buildHeaderCell("الحساب البنكي", 2),
                      _buildHeaderCell("الحالة", 1),
                      _buildHeaderCell("التاريخ", 1),
                      _buildHeaderCell("الإجراءات", 2),
                    ]),
                  )),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth:3.r)),
                      );
                    }
                    
                    // Filter proofs based on selected filter
                    List<TransferProofModel> filteredProofs = controller.proofs.where((proof) {
                      switch (_filter) {
                        case 'قيد الانتظار':
                          return proof.status == 'pending';
                        case 'مقبول':
                          return proof.status == 'approved';
                        case 'مرفوض':
                          return proof.status == 'rejected';
                        default:
                          return true;
                      }
                    }).toList();

                    if (filteredProofs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.payment_outlined, size:64.r, color: AppColors.textSecondary(isDark)),
                          SizedBox(height:16.h),
                          Text('لا توجد إثباتات تحويل', style: TextStyle(
                            fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )),
                          SizedBox(height:8.h),
                       
                        ]),
                      ));
                    }
                    
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildTransferRow(
                          filteredProofs[index], 
                          index, 
                          isDark,
                          index % 2 == 0 ? rowColor1 : rowColor2
                        ),
                        childCount: filteredProofs.length,
                      ),
                    );
                  }),
                ]),
              ),
            )),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(text, 
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w700, 
          color: AppColors.textPrimary(Theme.of(context).brightness == Brightness.dark),
        )),
    );
  }

  Widget _buildTransferRow(TransferProofModel proof, int index, bool isDark, Color color) {
    final createdAt = _parseDate(proof.createdAt ?? '') ?? DateTime.now().subtract(Duration(days: 1));
    final dateText = _formatDaysAgo(createdAt);
    final bankName = proof.bankAccount?.bankName ?? 'غير محدد';
    final accountNumber = proof.bankAccount?.accountNumber ?? 'غير محدد';
    
    // بيانات العميل
    final userEmail = proof.user?.email ?? proof.wallet?.user?.email ?? 'غير محدد';
    final userName = proof.user?.email?.split('@').first ?? 'مستخدم';
    
    // بيانات المحفظة
    final walletUuid = proof.wallet?.uuid ?? 'غير محدد';
    final walletBalance = proof.wallet?.balance ?? 0.0;
    
    return Container(
      padding: EdgeInsets.symmetric(vertical:12.h, horizontal:12.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(proof.id.toString(), 1),
        Expanded(
          flex: 1, 
          child: Center(
            child: GestureDetector(
              onTap: proof.proofImage != null && proof.proofImage!.isNotEmpty
                  ? () => _showImageDialog(proof.proofImage!)
                  : null,
              child: Container(
                width:40.w, height:40.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Center(
                    child: proof.proofImage != null && proof.proofImage!.isNotEmpty
                      ? Image.network(
                          proof.proofImage!, 
                          width:25.r, height:25.r, 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.receipt, color: AppColors.primary, size: 18.r);
                          },
                        )
                      : Icon(Icons.receipt, color: AppColors.primary, size: 18.r),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildCell('${proof.amount} ل.س', 1, 
          color: AppColors.primary, fontWeight: FontWeight.bold),
        
        // بيانات العميل
        _buildCell('$userName\n$userEmail', 2, 
          fontWeight: FontWeight.w500, maxLines: 2, fontSize: 10.sp),
        
        // بيانات المحفظة
        _buildCell('$walletUuid\n${walletBalance} ل.س', 2, 
          fontWeight: FontWeight.w500, maxLines: 2, fontSize: 10.sp),
        
        // الحساب البنكي
        _buildCell('$bankName\n$accountNumber', 2, 
          fontWeight: FontWeight.w500, maxLines: 2, fontSize: 10.sp),
        
        Expanded(
          flex: 1,
          child: Center(child: _buildStatusChip(proof.status)),
        ),
        _buildCell(dateText, 1, color: AppColors.textSecondary(isDark), fontSize: 10.sp),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildActionButtons(proof, isDark),
          ),
        ),
      ]),
    );
  }

  Widget _buildCell(String text, int flex, {
    Color? color, 
    FontWeight fontWeight = FontWeight.normal,
    int maxLines = 1,
    double fontSize = 11,
  }) {
    return Expanded(
      flex: flex,
      child: Text(text, 
        textAlign: TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize.sp, fontFamily: AppTextStyles.tajawal,
          fontWeight: fontWeight, color: color,
        )),
    );
  }
}

String _formatDaysAgo(DateTime date) {
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

DateTime? _parseDate(String dateString) {
  try {
    return DateTime.parse(dateString);
  } catch (_) {
    return null;
  }
}