/*import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/PremiumPackageController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../core/data/model/PremiumPackage.dart';
import '../AdminSidebar.dart';

class PremiumPackagesViewMobile extends StatefulWidget {
  const PremiumPackagesViewMobile({Key? key}) : super(key: key);

  @override
  _PremiumPackagesViewMobileState createState() => _PremiumPackagesViewMobileState();
}

class _PremiumPackagesViewMobileState extends State<PremiumPackagesViewMobile> {
  final PremiumPackageController controller = Get.put(PremiumPackageController());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();
  
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editDescController = TextEditingController();
  final TextEditingController _editDurationController = TextEditingController();
  final TextEditingController _editPriceController = TextEditingController();
  final TextEditingController _editSortOrderController = TextEditingController();
  
  String _filter = 'الكل';
  PremiumPackage? _editingPkg;
  bool _isActive = true;
  
  final List<Color> _statusColors = [
    const Color(0xFF85BE44), // فعال
    const Color(0xFFF44336), // غير فعال
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchPackages();
  }

  void _showAddDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _nameController.clear();
    _descController.clear();
    _durationController.clear();
    _priceController.clear();
    _sortOrderController.clear();
    _isActive = true;

    Get.bottomSheet(
      _buildBottomSheet(
        title: 'إضافة باقة جديدة',
        icon: Icons.card_giftcard,
        onSave: () async {
          if (_nameController.text.isEmpty || 
              _durationController.text.isEmpty || 
              _priceController.text.isEmpty) {
            Get.snackbar('تحذير', 'الرجاء إدخال الحقول المطلوبة',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          final newPackage = PremiumPackage(
            name: _nameController.text,
            description: _descController.text,
            durationDays: int.parse(_durationController.text),
            price: double.parse(_priceController.text),
            currency: 'SYP',
            isActive: _isActive,
            sortOrder: _sortOrderController.text.isNotEmpty 
                ? int.parse(_sortOrderController.text) 
                : 0,
          );
          
          await controller.createPackage(newPackage);
          Get.back();
        },
        isDark: isDark,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
    );
  }

  void _showEditDialog(PremiumPackage pkg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _editingPkg = pkg;
    _editNameController.text = pkg.name;
    _editDescController.text = pkg.description ?? '';
    _editDurationController.text = pkg.durationDays.toString();
    _editPriceController.text = pkg.price.toString();
    _editSortOrderController.text = pkg.sortOrder.toString();
    _isActive = pkg.isActive;

    Get.bottomSheet(
      _buildBottomSheet(
        title: 'تعديل الباقة',
        icon: Icons.edit,
        onSave: () async {
          if (_editNameController.text.isEmpty || 
              _editDurationController.text.isEmpty || 
              _editPriceController.text.isEmpty) {
            Get.snackbar('تحذير', 'الرجاء إدخال الحقول المطلوبة',
              backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }
          
          final updatedPackage = PremiumPackage(
            id: pkg.id,
            name: _editNameController.text,
            description: _editDescController.text,
            durationDays: int.parse(_editDurationController.text),
            price: double.parse(_editPriceController.text),
            currency: pkg.currency,
            isActive: _isActive,
            sortOrder: int.parse(_editSortOrderController.text),
          );
          
          await controller.updatePackage(updatedPackage);
          Get.back();
        },
        isDark: isDark,
        isEdit: true,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
    );
  }

  Widget _buildBottomSheet({
    required String title,
    required IconData icon,
    required VoidCallback onSave,
    required bool isDark,
    bool isEdit = false,
  }) {
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
              Icon(icon, size: 24.r, color: AppColors.primary),
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
          _buildTextField('اسم الباقة', Icons.text_fields, 
            isEdit ? _editNameController : _nameController, isDark),
          SizedBox(height: 16.h),
          _buildTextField('وصف الباقة', Icons.description, 
            isEdit ? _editDescController : _descController, isDark, maxLines: 2),
          SizedBox(height: 16.h),
          _buildTextField('المدة (أيام)', Icons.calendar_today, 
            isEdit ? _editDurationController : _durationController, isDark,
            keyboardType: TextInputType.number),
          SizedBox(height: 16.h),
          _buildTextField('السعر', Icons.attach_money, 
            isEdit ? _editPriceController : _priceController, isDark,
            keyboardType: TextInputType.numberWithOptions(decimal: true)),
          SizedBox(height: 16.h),
          _buildTextField('ترتيب العرض', Icons.sort, 
            isEdit ? _editSortOrderController : _sortOrderController, isDark,
            keyboardType: TextInputType.number),
          SizedBox(height: 16.h),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text('حالة الباقة', style: TextStyle(
                fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(width: 8.w),
              Switch(
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(_isActive ? 'مفعلة' : 'غير مفعلة', style: TextStyle(
                fontSize: 14.sp, 
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textPrimary(isDark),
              )),
            ],
          ),
          SizedBox(height: 24.h),
          _buildActionButtons(onSave, isDark, title == 'إضافة باقة جديدة'),
        ],
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

  Widget _buildActionButtons(VoidCallback onSave, bool isDark, bool isAdd) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
                    Icon(isAdd ? Icons.add : Icons.save, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(isAdd ? 'إضافة' : 'حفظ التعديلات', style: TextStyle(
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

  void _showDeleteDialog(int id) {
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
            Text('هل أنت متأكد من حذف هذه الباقة؟', style: TextStyle(
              fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark)),
            ),
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
              controller.deletePackage(id);
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
        title: Text('إدارة الباقات المميزة', 
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          )
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.visibility_off, size: 22.r),
            onPressed: () => controller.hideAllPackages(),
            tooltip: 'إخفاء الكل',
          ),
          IconButton(
            icon: Icon(Icons.add, size: 22.r),
            onPressed: _showAddDialog,
            tooltip: 'إضافة باقة',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Obx(() {
          if (controller.isLoadingPackages.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary, 
                strokeWidth: 3.r
              ),
            );
          }
          
          if (controller.packagesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 64.r, 
                       color: AppColors.textSecondary(isDark)),
                  SizedBox(height: 16.h),
                  Text('لا توجد باقات', style: TextStyle(
                    fontSize: 16.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDark),
                  )),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: controller.packagesList.length,
            itemBuilder: (context, index) {
              final pkg = controller.packagesList[index];
              return _buildPackageCard(pkg, isDark);
            },
          );
        }),
      ),
    );
  }

  Widget _buildPackageCard(PremiumPackage pkg, bool isDark) {
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
                  pkg.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.toggleActive(pkg.id!),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: pkg.isActive 
                        ? _statusColors[0].withOpacity(0.2) 
                        : _statusColors[1].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pkg.isActive ? Icons.visibility : Icons.visibility_off,
                          size: 14.r,
                          color: pkg.isActive ? _statusColors[0] : _statusColors[1],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          pkg.isActive ? 'مفعلة' : 'غير مفعلة',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: pkg.isActive ? _statusColors[0] : _statusColors[1],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            if (pkg.description?.isNotEmpty ?? false) ...[
              Text(
                pkg.description ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textSecondary(isDark),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
            ],
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPackageDetail('المدة', '${pkg.durationDays} يوم', Icons.calendar_today),
                _buildPackageDetail('السعر', '${pkg.price} ${pkg.currency}', Icons.attach_money),
                _buildPackageDetail('الترتيب', '${pkg.sortOrder}', Icons.sort),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit, size: 18.r),
                    label: Text('تعديل', style: TextStyle(fontSize: 12.sp)),
                    onPressed: () => _showEditDialog(pkg),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.delete, size: 18.r),
                    label: Text('حذف', style: TextStyle(fontSize: 12.sp)),
                    onPressed: () => _showDeleteDialog(pkg.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageDetail(String title, String value, IconData icon) {
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
}*/