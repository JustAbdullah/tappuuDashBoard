import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../controllers/ColorAndCurrencyController.dart';
import '../../core/data/model/AppColor.dart';

class ColorAndCurrencyViewDeskTop extends StatefulWidget {
  const ColorAndCurrencyViewDeskTop({Key? key}) : super(key: key);

  @override
  _ColorAndCurrencyViewDeskTopState createState() => _ColorAndCurrencyViewDeskTopState();
}

class _ColorAndCurrencyViewDeskTopState extends State<ColorAndCurrencyViewDeskTop> {
  final ColorAndCurrencyController controller = Get.put(ColorAndCurrencyController());
  final TextEditingController _colorNameController = TextEditingController();
  final TextEditingController _colorHexController = TextEditingController();
  final TextEditingController _currencyNameController = TextEditingController();
  final TextEditingController _currencyCodeController = TextEditingController();
  final TextEditingController _currencySymbolController = TextEditingController();
  final TextEditingController _currencyRateController = TextEditingController();
  
  AppColor? _editingColor;
  Map<String, dynamic>? _editingCurrency;
  bool _isBaseCurrency = false;
  String _currencyFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الصفحة
    controller.fetchColors();
    controller.fetchCurrencies();
  }

  void _showColorDialog({AppColor? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _editingColor = color;
    
    if (color != null) {
      _colorNameController.text = color.name;
      _colorHexController.text = color.hexCode;
    } else {
      _colorNameController.clear();
      _colorHexController.clear();
    }

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
                      Icon(Icons.color_lens, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text(color != null ? 'تعديل اللون' : 'إضافة لون جديد', style: TextStyle(
                        fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700, 
                        color: AppColors.textPrimary(isDark),
                      )),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildTextField('اسم اللون', Icons.text_fields, _colorNameController, isDark),
                  SizedBox(height: 16.h),
                  _buildTextField('كود اللون (Hex)', Icons.color_lens, _colorHexController, isDark,
                      hintText: '#2D5E8C'),
                  if (color != null) ...[
                    SizedBox(height: 16.h),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: controller.colorFromHex(color.hexCode),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.border(isDark)),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text('معاينة اللون', style: TextStyle(
                          fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark),
                        )),
                      ],
                    ),
                  ],
                  SizedBox(height: 24.h),
                  _buildColorActionButtons(isDark, color != null),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog({Map<String, dynamic>? currency}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _editingCurrency = currency;
    
    // التحقق من وجود عملة أساسية حالية
    final bool hasBaseCurrency = controller.currencies.any((c) => 
      (c['is_base'] == 1 || c['is_base'] == true) && 
      (currency == null || c['id'] != currency['id'] || c['code'] != currency['code'])
    );
    
    if (currency != null) {
      _currencyNameController.text = currency['name'] ?? '';
      _currencyCodeController.text = currency['code'] ?? '';
      _currencySymbolController.text = currency['symbol'] ?? '';
      _currencyRateController.text = currency['rate']?.toString() ?? '1.0';
      _isBaseCurrency = currency['is_base'] == 1 || currency['is_base'] == true;
    } else {
      _currencyNameController.clear();
      _currencyCodeController.clear();
      _currencySymbolController.clear();
      _currencyRateController.text = '1.0';
      _isBaseCurrency = false;
    }

    Get.dialog(
      Center(
        child: Dialog(
          backgroundColor: AppColors.surface(isDark),
          insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 80.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w, minWidth: 500.w),
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Icons.currency_exchange, size: 24.r, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Text(currency != null ? 'تعديل العملة' : 'إضافة عملة جديدة', style: TextStyle(
                        fontSize: 18.sp, fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700, 
                        color: AppColors.textPrimary(isDark),
                      )),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: _buildTextField('اسم العملة', Icons.text_fields, _currencyNameController, isDark),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField('رمز العملة', Icons.code, _currencyCodeController, isDark,
                            hintText: 'USD'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: _buildTextField('الرمز المعروض', Icons.code, _currencySymbolController, isDark,
                            hintText: '\$'),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField('سعر الصرف', Icons.attach_money, _currencyRateController, isDark,
                            keyboardType: TextInputType.numberWithOptions(decimal: true)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // عرض توضيح سعر الصرف
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'سعر الصرف بالنسبة للعملة الأساسية (الليرة السورية)- اي مبلغ يوازي قيمته بالليرة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: AppTextStyles.tajawal,
                        color: AppColors.textSecondary(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Switch(
                        value: _isBaseCurrency,
                        onChanged: hasBaseCurrency && !_isBaseCurrency 
                          ? null // تعطيل إذا كانت هناك عملة أساسية أخرى
                          : (value) {
                              setState(() {
                                _isBaseCurrency = value;
                              });
                            },
                        activeColor: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('عملة أساسية', style: TextStyle(
                            fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textPrimary(isDark),
                          )),
                          if (hasBaseCurrency && !_isBaseCurrency)
                            Text(
                              'يوجد عملة أساسية بالفعل',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: Colors.orange,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildCurrencyActionButtons(isDark, currency != null, hasBaseCurrency),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteCurrencyDialog(Map<String, dynamic> currency) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String code = currency['code'] ?? '';
    final String name = currency['name'] ?? '';
    final bool isBase = currency['is_base'] == 1 || currency['is_base'] == true;

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
                  Text('هل أنت متأكد من حذف عملة $name ($code)?', style: TextStyle(
                    fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDark)),
                  ),
                  if (isBase) ...[
                    SizedBox(height:8.h),
                    Text('تحذير: هذه العملة أساسية ولا يمكن حذفها!', style: TextStyle(
                      fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
                      color: AppColors.error,
                    )),
                  ],
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
                          backgroundColor: isBase ? Colors.grey : AppColors.error,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        onPressed: isBase || controller.isLoading.value ? null : () {
                          final id = currency['id'] ?? currency['code'];
                          controller.deleteCurrency(idOrCode: id);
                          Get.back();
                        },
                        child: controller.isLoading.value
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

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, 
      bool isDark, {String hintText = '', TextInputType keyboardType = TextInputType.text}) {
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
        hintText: hintText,
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

  Widget _buildColorActionButtons(bool isDark, bool isEdit) {
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
          onPressed: controller.isLoading.value ? null : () async {
            if (_colorNameController.text.isEmpty || _colorHexController.text.isEmpty) {
              Get.snackbar('تحذير', 'الرجاء إدخال جميع الحقول',
                backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }
            
            bool success;
            if (isEdit && _editingColor != null) {
              success = await controller.updateColor(
                id: _editingColor!.id,
                name: _colorNameController.text,
                hexCode: _colorHexController.text,
              );
            } else {
              success = await controller.createColor(
                name: _colorNameController.text,
                hexCode: _colorHexController.text,
              );
            }
            
            if (success) {
              Get.back();
              // إعادة تحميل الألوان بعد الإضافة/التعديل
              controller.fetchColors();
            }
          },
          child: controller.isLoading.value
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isEdit ? Icons.edit : Icons.add, size: 20.r),
                SizedBox(width: 8.w),
                Text(isEdit ? 'تحديث' : 'إضافة', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                )),
              ]),
        )),
      ],
    );
  }

  Widget _buildCurrencyActionButtons(bool isDark, bool isEdit, bool hasBaseCurrency) {
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
          onPressed: controller.isLoading.value ? null : () async {
            if (_currencyNameController.text.isEmpty || 
                _currencyCodeController.text.isEmpty || 
                _currencyRateController.text.isEmpty) {
              Get.snackbar('تحذير', 'الرجاء إدخال جميع الحقول',
                backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }
            
            final rate = double.tryParse(_currencyRateController.text);
            if (rate == null || rate <= 0) {
              Get.snackbar('تحذير', 'الرجاء إدخال سعر صرف صحيح',
                backgroundColor: Colors.orange, colorText: Colors.white);
              return;
            }
            
            bool success;
            if (isEdit && _editingCurrency != null) {
              final id = _editingCurrency!['id'] ?? _editingCurrency!['code'];
              success = await controller.updateCurrency(
                idOrCode: id,
                name: _currencyNameController.text,
                code: _currencyCodeController.text,
                symbol: _currencySymbolController.text,
                rate: rate,
                isBase: _isBaseCurrency,
              );
            } else {
              success = await controller.createCurrency(
                name: _currencyNameController.text,
                code: _currencyCodeController.text,
                symbol: _currencySymbolController.text,
                rate: rate,
                isBase: _isBaseCurrency,
              );
            }
            
            if (success) {
              Get.back();
              // إعادة تحميل العملات بعد الإضافة/التعديل
              controller.fetchCurrencies();
            }
          },
          child: controller.isLoading.value
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isEdit ? Icons.edit : Icons.add, size: 20.r),
                SizedBox(width: 8.w),
                Text(isEdit ? 'تحديث' : 'إضافة', style: TextStyle(
                  fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                )),
              ]),
        )),
      ],
    );
  }

  Widget _buildBaseCurrencyBadge(bool isBase) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isBase ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isBase ? Colors.green : Colors.grey),
      ),
      child: Text(
        isBase ? 'أساسية' : 'ثانوية',
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.bold,
          color: isBase ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  // دالة لتحويل سعر الصرف إلى نص واضح
  String _formatExchangeRate(Map<String, dynamic> currency) {
    final bool isBase = currency['is_base'] == 1 || currency['is_base'] == true;
    final double rate = double.tryParse(currency['rate']?.toString() ?? '1.0') ?? 1.0;
    final String code = currency['code'] ?? '';
    
    if (isBase) {
      return 'العملة الأساسية (1 $code)';
    } else {
      // البحث عن العملة الأساسية
      final baseCurrency = controller.currencies.firstWhere(
        (c) => c['is_base'] == 1 || c['is_base'] == true,
        orElse: () => {'code': 'SYP', 'rate': 1.0},
      );
      
      final String baseCode = baseCurrency['code'] ?? 'SYP';
      final double baseRate = double.tryParse(baseCurrency['rate']?.toString() ?? '1.0') ?? 1.0;
      
      if (baseRate == 0) return 'سعر غير محدد';
      
      final double equivalent = rate / baseRate;
      return '1 $code = ${equivalent.toStringAsFixed(2)} $baseCode';
    }
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
            Text('إدارة الألوان والعملات', style: TextStyle(
              fontSize:19.sp, fontFamily: AppTextStyles.tajawal,
              fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark),
            )),
            SizedBox(height:16.h),
            
            // قسم الألوان
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius:12, offset: Offset(0,4),
                  )]),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('الألوان الرئيسية', style: TextStyle(
                            fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w700, 
                            color: AppColors.textPrimary(isDark),
                          )),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add, size:18.r),
                            label: Text('إضافة لون', style: TextStyle(
                              fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                              fontWeight: FontWeight.w600,
                            )),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: EdgeInsets.symmetric(vertical:12.h, horizontal:20.w),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                            onPressed: () => _showColorDialog(),
                          ),
                        ],
                      ),
                      SizedBox(height:16.h),
                      Obx(() {
                        if (controller.isLoading.value && controller.colorsList.isEmpty) {
                          return Center(child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth:3.r));
                        }
                        
                        if (controller.colorsList.isEmpty) {
                          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.color_lens, size:64.r, color: AppColors.textSecondary(isDark)),
                            SizedBox(height:16.h),
                            Text('لا توجد ألوان', style: TextStyle(
                              fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                              color: AppColors.textSecondary(isDark),
                            )),
                          ]));
                        }
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.h,
                            childAspectRatio: 2.5,
                          ),
                          itemCount: controller.colorsList.length,
                          itemBuilder: (context, index) {
                            final color = controller.colorsList[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface(isDark),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColors.border(isDark)),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 30.r,
                                  height: 30.r,
                                  decoration: BoxDecoration(
                                    color: controller.colorFromHex(color.hexCode),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: AppColors.border(isDark)),
                                  ),
                                ),
                                title: Text(color.name, style: TextStyle(
                                  fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textPrimary(isDark),
                                )),
                                subtitle: Text(color.hexCode, style: TextStyle(
                                  fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
                                  color: AppColors.textSecondary(isDark),
                                )),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit, size:18.r, color: AppColors.primary),
                                  onPressed: () => _showColorDialog(color: color),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height:24.h),
            
            // قسم العملات
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius:12, offset: Offset(0,4),
                  )]),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('إدارة العملات', style: TextStyle(
                            fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w700, 
                            color: AppColors.textPrimary(isDark),
                          )),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              // Dropdown للتصفية
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                decoration: BoxDecoration(
                                  color: AppColors.surface(isDark),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: AppColors.border(isDark)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _currencyFilter,
                                    items: ['الكل', 'أساسية', 'ثانوية']
                                      .map((String value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textPrimary(isDark),
                                        )),
                                      )).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _currencyFilter = newValue!;
                                        // تطبيق التصفية
                                        if (_currencyFilter == 'أساسية') {
                                          controller.sortCurrencies('is_base');
                                        } else if (_currencyFilter == 'ثانوية') {
                                          controller.sortCurrencies('is_base', desc: true);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              ElevatedButton.icon(
                                icon: Icon(Icons.add, size:18.r),
                                label: Text('إضافة عملة', style: TextStyle(
                                  fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                                  fontWeight: FontWeight.w600,
                                )),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  padding: EdgeInsets.symmetric(vertical:12.h, horizontal:20.w),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                                onPressed: () => _showCurrencyDialog(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height:16.h),
                      Expanded(
                        child: Obx(() {
                          if (controller.isCurrenciesLoading.value && controller.currencies.isEmpty) {
                            return Center(child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth:3.r));
                          }
                          
                          if (controller.currencies.isEmpty) {
                            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.currency_exchange, size:64.r, color: AppColors.textSecondary(isDark)),
                              SizedBox(height:16.h),
                              Text('لا توجد عملات', style: TextStyle(
                                fontSize:16.sp, fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDark),
                              )),
                            ]));
                          }
                          
                          // تصفية العملات حسب الاختيار
                          List<Map<String, dynamic>> filteredCurrencies = controller.currencies;
                          if (_currencyFilter == 'أساسية') {
                            filteredCurrencies = controller.currencies.where((c) => 
                              c['is_base'] == 1 || c['is_base'] == true).toList();
                          } else if (_currencyFilter == 'ثانوية') {
                            filteredCurrencies = controller.currencies.where((c) => 
                              !(c['is_base'] == 1 || c['is_base'] == true)).toList();
                          }
                          
                          return ListView.builder(
                            itemCount: filteredCurrencies.length,
                            itemBuilder: (context, index) {
                              final currency = filteredCurrencies[index];
                              final isBase = currency['is_base'] == 1 || currency['is_base'] == true;
                              
                              return Container(
                                margin: EdgeInsets.only(bottom: 8.h),
                                decoration: BoxDecoration(
                                  color: index % 2 == 0 ? rowColor1 : rowColor2,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ListTile(
                                  leading: _buildBaseCurrencyBadge(isBase),
                                  title: Text('${currency['name']} (${currency['code']})', style: TextStyle(
                                    fontSize:14.sp, fontFamily: AppTextStyles.tajawal,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(isDark),
                                  )),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_formatExchangeRate(currency), style: TextStyle(
                                        fontSize:12.sp, fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.textSecondary(isDark),
                                      )),
                                      if (currency['symbol'] != null && currency['symbol'].toString().isNotEmpty)
                                        Text('الرمز: ${currency['symbol']}', style: TextStyle(
                                          fontSize:11.sp, fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        )),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!isBase) IconButton(
                                        icon: Icon(Icons.flag, size:18.r, color: Colors.blue),
                                        tooltip: 'تعيين كعملة أساسية',
                                        onPressed: () {
                                          final id = currency['id'] ?? currency['code'];
                                          controller.setBaseCurrency(idOrCode: id).then((_) {
                                            // إعادة تحميل العملات بعد التغيير
                                            controller.fetchCurrencies();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, size:18.r, color: AppColors.primary),
                                        tooltip: 'تعديل العملة',
                                        onPressed: () => _showCurrencyDialog(currency: currency),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, size:18.r, color: AppColors.error),
                                        tooltip: 'حذف العملة',
                                        onPressed: () => _showDeleteCurrencyDialog(currency),
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
              ),
            ),
          ]),
        )),
      ]),
    );
  }
}