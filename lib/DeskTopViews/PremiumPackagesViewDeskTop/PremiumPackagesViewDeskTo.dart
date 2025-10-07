import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/DeskTopViews/AdminSidebarDeskTop.dart';
import 'package:tappuu_dashboard/controllers/PremiumPackageController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../core/data/model/PackageType.dart';
import '../../core/data/model/PremiumPackage.dart';

class PackageDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final Function(PremiumPackage) onSave;
  final bool isDark;
  final bool isEdit;
  final PremiumPackage? packageToEdit;

  const PackageDialog({
    Key? key,
    required this.title,
    required this.icon,
    required this.onSave,
    required this.isDark,
    this.isEdit = false,
    this.packageToEdit,
  }) : super(key: key);

  @override
  _PackageDialogState createState() => _PackageDialogState();
}

class _PackageDialogState extends State<PackageDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();

  final PremiumPackageController controller = Get.find<PremiumPackageController>();
  int? _selectedPackageTypeId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    
    if (widget.isEdit && widget.packageToEdit != null) {
      _nameController.text = widget.packageToEdit!.name;
      _descController.text = widget.packageToEdit!.description ?? '';
      _durationController.text = widget.packageToEdit!.durationDays.toString();
      _priceController.text = widget.packageToEdit!.price.toString();
      _sortOrderController.text = widget.packageToEdit!.sortOrder.toString();
      _selectedPackageTypeId = widget.packageToEdit!.packageTypeId;
      _isActive = widget.packageToEdit!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.72;

    return Dialog(
      backgroundColor: AppColors.surface(widget.isDark),
      insetPadding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 40.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720.w, minWidth: 420.w, maxHeight: maxDialogHeight),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(widget.icon, size: 24.r, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Text(widget.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontFamily: AppTextStyles.tajawal,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(widget.isDark),
                        )),
                  ],
                ),
                SizedBox(height: 18.h),

                _buildTextField('اسم الباقة', Icons.text_fields, _nameController, widget.isDark),
                SizedBox(height: 12.h),
                _buildTextField('وصف الباقة', Icons.description, _descController, widget.isDark, maxLines: 3),
                SizedBox(height: 12.h),

                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: _buildTextField('المدة (أيام)', Icons.calendar_today, _durationController, widget.isDark, keyboardType: TextInputType.number),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField('السعر', Icons.attach_money, _priceController, widget.isDark, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: _buildTextField('ترتيب العرض', Icons.sort, _sortOrderController, widget.isDark, keyboardType: TextInputType.number),
                    ),
                    SizedBox(width: 12.w),

                    // Dropdown for package types
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('نوع الباقة', style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(widget.isDark),
                          )),
                          SizedBox(height: 8.h),
                          Obx(() {
                            if (controller.isLoadingTypes.value) {
                              return Container(
                                height: 48.h,
                                decoration: BoxDecoration(
                                  color: AppColors.card(widget.isDark),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Center(child: SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(strokeWidth: 2.r))),
                              );
                            }

                            if (controller.packageTypesList.isEmpty) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: AppColors.card(widget.isDark),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text('لا توجد أنواع باقات', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(widget.isDark)))),
                                    SizedBox(width: 8.w),
                                    ElevatedButton(
                                      onPressed: () {
                                        // سيتم تنفيذ إضافة نوع جديد
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                      ),
                                      child: Text('إضافة نوع', style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal)),
                                    )
                                  ],
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.card(widget.isDark),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              height: 48.h,
                              child: DropdownButton<int?>(
                                value: _selectedPackageTypeId,
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: Icon(Icons.arrow_drop_down, size: 24.r),
                                items: [
                                  DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('اختر نوع الباقة', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(widget.isDark))),
                                  ),
                                  ...controller.packageTypesList.map((type) {
                                    return DropdownMenuItem<int?>(
                                      value: type.id,
                                      child: Text(type.name, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(widget.isDark))),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedPackageTypeId = value;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Status
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('حالة الباقة', style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(widget.isDark),
                          )),
                          SizedBox(height: 8.h),
                          StatefulBuilder(builder: (BuildContext context, StateSetter setStateDialog) {
                            return SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_isActive ? 'مفعلة' : 'غير مفعلة', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(widget.isDark))),
                              value: _isActive,
                              onChanged: (value) => setStateDialog(() => _isActive = value),
                              activeColor: AppColors.primary,
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(width: 120.w),
                  ],
                ),

                SizedBox(height: 18.h),
                _buildActionButtons(widget.isDark, widget.isEdit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool isDark, 
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          fontSize: 14.sp,
          fontFamily: AppTextStyles.tajawal,
          color: AppColors.textSecondary(isDark),
        )),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              prefixIcon: Icon(icon, size: 20.r, color: AppColors.textSecondary(isDark)),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark, bool isEdit) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.isEmpty ||
                  _durationController.text.isEmpty ||
                  _priceController.text.isEmpty) {
                Get.snackbar('تحذير', 'الرجاء إدخال الحقول المطلوبة',
                    backgroundColor: Colors.orange, colorText: Colors.white);
                return;
              }

              final package = PremiumPackage(
                id: isEdit ? widget.packageToEdit?.id : null,
                name: _nameController.text,
                description: _descController.text,
                durationDays: int.parse(_durationController.text),
                price: double.parse(_priceController.text),
                currency: 'SYP',
                isActive: _isActive,
                sortOrder: _sortOrderController.text.isNotEmpty ? int.parse(_sortOrderController.text) : 0,
                packageTypeId: _selectedPackageTypeId,
              );

              widget.onSave(package);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Obx(() => controller.isSavingPackage.value
                ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                : Text(isEdit ? 'حفظ التعديلات' : 'إضافة الباقة', 
                    style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: Colors.white))),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              side: BorderSide(color: AppColors.primary),
            ),
            child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}

class PremiumPackagesViewDeskTop extends StatefulWidget {
  const PremiumPackagesViewDeskTop({Key? key}) : super(key: key);

  @override
  _PremiumPackagesViewDeskTopState createState() => _PremiumPackagesViewDeskTopState();
}

class _PremiumPackagesViewDeskTopState extends State<PremiumPackagesViewDeskTop> with SingleTickerProviderStateMixin {
  final PremiumPackageController controller = Get.put(PremiumPackageController());
  late TabController _tabController;

  // Text controllers for package types
  final TextEditingController _typeNameController = TextEditingController();
  final TextEditingController _typeDescController = TextEditingController();
  final TextEditingController _typeSortOrderController = TextEditingController();

  // Text controllers for editing package types
  final TextEditingController _editTypeNameController = TextEditingController();
  final TextEditingController _editTypeDescController = TextEditingController();
  final TextEditingController _editTypeSortOrderController = TextEditingController();

  String _filter = 'الكل';
  PackageType? _editingType;

  final List<Color> _statusColors = [
    const Color(0xFF85BE44), // فعال
    const Color(0xFFF44336), // غير فعال
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchPackages();
    controller.fetchPackageTypes();
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPackageDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      PackageDialog(
        title: 'إضافة باقة جديدة',
        icon: Icons.card_giftcard,
        onSave: (newPackage) async {
          await controller.createPackage(newPackage);
          Get.back();
        },
        isDark: isDark,
      ),
      barrierDismissible: false,
    );
  }

  void _showEditPackageDialog(PremiumPackage pkg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      PackageDialog(
        title: 'تعديل الباقة',
        icon: Icons.edit,
        onSave: (updatedPackage) async {
          await controller.updatePackage(updatedPackage);
          Get.back();
        },
        isDark: isDark,
        isEdit: true,
        packageToEdit: pkg,
      ),
      barrierDismissible: false,
    );
  }

  void _showAddPackageTypeDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _typeNameController.clear();
    _typeDescController.clear();
    _typeSortOrderController.clear();

    Get.dialog(
      _buildPackageTypeDialog(
        title: 'إضافة نوع باقة جديد',
        icon: Icons.category,
        onSave: () async {
          if (_typeNameController.text.isEmpty) {
            Get.snackbar('تحذير', 'الرجاء إدخال اسم نوع الباقة', backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }

          final newType = PackageType(name: _typeNameController.text, description: _typeDescController.text);
          await controller.createPackageType(newType);
          Get.back();
        },
        isDark: isDark,
      ),
      barrierDismissible: false,
    );
  }

  void _showEditPackageTypeDialog(PackageType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _editingType = type;
    _editTypeNameController.text = type.name;
    _editTypeDescController.text = type.description ?? '';
    _editTypeSortOrderController.text = '0';

    Get.dialog(
      _buildPackageTypeDialog(
        title: 'تعديل نوع الباقة',
        icon: Icons.edit,
        onSave: () async {
          if (_editTypeNameController.text.isEmpty) {
            Get.snackbar('تحذير', 'الرجاء إدخال اسم نوع الباقة', backgroundColor: Colors.orange, colorText: Colors.white);
            return;
          }

          final updatedType = PackageType(id: type.id, name: _editTypeNameController.text, description: _editTypeDescController.text);
          await controller.updatePackageType(updatedType);
          Get.back();
        },
        isDark: isDark,
        isEdit: true,
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildPackageTypeDialog({
    required String title,
    required IconData icon,
    required VoidCallback onSave,
    required bool isDark,
    bool isEdit = false,
  }) {
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.6;

    return Dialog(
      backgroundColor: AppColors.surface(isDark),
      insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 30.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520.w, minWidth: 360.w, maxHeight: maxDialogHeight),
        child: Padding(
          padding: EdgeInsets.all(18.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(textDirection: TextDirection.rtl, children: [
                  Icon(icon, size: 24.r, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Text(title, style: TextStyle(fontSize: 18.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.textPrimary(isDark))),
                ]),

                SizedBox(height: 18.h),
                _buildTextField('اسم نوع الباقة', Icons.text_fields, isEdit ? _editTypeNameController : _typeNameController, isDark),
                SizedBox(height: 12.h),
                _buildTextField('وصف نوع الباقة', Icons.description, isEdit ? _editTypeDescController : _typeDescController, isDark, maxLines: 3),
                SizedBox(height: 18.h),
                _buildActionButtons(onSave, isDark, title == 'إضافة نوع باقة جديد', controller.isSavingType),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool isDark,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: maxLines == 1 ? 16.sp : 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: AppColors.card(isDark),
        prefixIcon: Icon(icon, size: 22.r),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildActionButtons(VoidCallback onSave, bool isDark, bool isAdd, RxBool isLoading) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
        ),
        Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
              onPressed: isLoading.value ? null : onSave,
              child: isLoading.value
                  ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(isAdd ? Icons.add : Icons.save, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(isAdd ? 'إضافة' : 'حفظ التعديلات', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold)),
                    ])),
        ),
      ],
    );
  }

  void _showDeletePackageDialog(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500.w, minWidth: 300.w, maxHeight: 300.h),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(textDirection: TextDirection.rtl, children: [
                Icon(Icons.warning_amber_rounded, size: 24.r, color: AppColors.error),
                SizedBox(width: 10.w),
                Text('تأكيد الحذف', style: TextStyle(fontSize: 16.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.error)),
              ]),
              SizedBox(height: 16.h),
              Text('هل أنت متأكد من حذف هذه الباقة؟', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
              SizedBox(height: 8.h),
              Text('سيتم حذف جميع البيانات المرتبطة بها!', style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.error.withOpacity(0.8))),
              SizedBox(height: 24.h),
              Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)))),
                Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                      onPressed: controller.isDeletingPackage.value
                          ? null
                          : () {
                              controller.deletePackage(id);
                              Get.back();
                            },
                      child: controller.isDeletingPackage.value
                          ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                          : Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.delete, size: 20.r), SizedBox(width: 8.w), Text('حذف', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold))]),
                    ))
              ])
            ],
          ),
        ),
      ),
    );
  }

  void _showDeletePackageTypeDialog(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.symmetric(horizontal: 100.w, vertical: 100.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500.w, minWidth: 300.w, maxHeight: 300.h),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(textDirection: TextDirection.rtl, children: [
                Icon(Icons.warning_amber_rounded, size: 24.r, color: AppColors.error),
                SizedBox(width: 10.w),
                Text('تأكيد الحذف', style: TextStyle(fontSize: 16.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.error)),
              ]),
              SizedBox(height: 16.h),
              Text('هل أنت متأكد من حذف نوع الباقة هذا؟', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textPrimary(isDark))),
              SizedBox(height: 8.h),
              Text('سيتم حذف جميع الباقات المرتبطة به!', style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.error.withOpacity(0.8))),
              SizedBox(height: 24.h),
              Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: () => Get.back(), child: Text('إلغاء', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark)))),
                Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                      onPressed: controller.isDeletingType.value
                          ? null
                          : () {
                              controller.deletePackageType(id);
                              Get.back();
                            },
                      child: controller.isDeletingType.value
                          ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
                          : Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.delete, size: 20.r), SizedBox(width: 8.w), Text('حذف', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold))]),
                    ))
              ])
            ],
          ),
        ),
      ),
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
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            color: AppColors.background(isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                // header
                Row(textDirection: TextDirection.rtl, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('إدارة الباقات المميزة', style: TextStyle(fontSize: 22.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w800, color: AppColors.textPrimary(isDark))),
                  Row(textDirection: TextDirection.rtl, children: [
                    if (_tabController.index == 1)
                      ElevatedButton.icon(
                        icon: Icon(Icons.visibility_off, size: 18.r),
                        label: Text('إخفاء الكل', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFA000), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                        onPressed: () => controller.hideAllPackages(),
                      ),
                    SizedBox(width: 10.w),
                    ElevatedButton.icon(
                      icon: Icon(_tabController.index == 0 ? Icons.category : Icons.card_giftcard, size: 18.r),
                      label: Text(_tabController.index == 0 ? 'إضافة نوع' : 'إضافة باقة', style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                      onPressed: _tabController.index == 0 ? _showAddPackageTypeDialog : _showAddPackageDialog,
                    ),
                  ]),
                ]),

                SizedBox(height: 24.h),

                // Tabs
                Center(
                  child: Container(
                    height: 70.h,
                    width: 500.w,
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12.r, offset: Offset(0, 4.r))]),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(15.r), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 10.r, offset: Offset(0, 4.r))]),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary(isDark),
                      labelStyle: TextStyle(fontSize: 15.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w500),
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                      splashBorderRadius: BorderRadius.circular(15.r),
                      tabs: [
                        Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.category_rounded, size: 20.r), SizedBox(width: 8.w), Text('أنواع الباقات')])),
                        Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.card_giftcard_rounded, size: 20.r), SizedBox(width: 8.w), Text('الباقات')])),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Tab content
                Expanded(
                  child: TabBarView(controller: _tabController, children: [
                    // Package types tab
                    Container(
                      decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: Offset(0, 4))]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CustomScrollView(slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                              decoration: BoxDecoration(color: isDark ? AppColors.grey800 : AppColors.grey200, borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r))),
                              child: Row(textDirection: TextDirection.rtl, children: [
                                _buildHeaderCell("المعرف", 1),
                                _buildHeaderCell("الاسم", 2),
                                _buildHeaderCell("الوصف", 3),
                                _buildHeaderCell("تاريخ الإنشاء", 2),
                                _buildHeaderCell("الإجراءات", 1),
                              ]),
                            ),
                          ),
                          Obx(() {
                            if (controller.isLoadingTypes.value) {
                              return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.r)));
                            }
                            if (controller.packageTypesList.isEmpty) {
                              return SliverFillRemaining(
                                child: Center(
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.category, size: 64.r, color: AppColors.textSecondary(isDark)),
                                    SizedBox(height: 16.h),
                                    Text('لا توجد أنواع باقات', style: TextStyle(fontSize: 16.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                                  ]),
                                ),
                              );
                            }

                            return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildPackageTypeRow(controller.packageTypesList[index], index, isDark, index % 2 == 0 ? rowColor1 : rowColor2), childCount: controller.packageTypesList.length));
                          }),
                        ]),
                      ),
                    ),

                    // Packages tab
                    Container(
                      decoration: BoxDecoration(color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: Offset(0, 4))]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CustomScrollView(slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                              decoration: BoxDecoration(color: isDark ? AppColors.grey800 : AppColors.grey200, borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r))),
                              child: Row(textDirection: TextDirection.rtl, children: [
                                _buildHeaderCell("المعرف", 1),
                                _buildHeaderCell("الاسم", 2),
                                _buildHeaderCell("النوع", 1),
                                _buildHeaderCell("الوصف", 2),
                                _buildHeaderCell("المدة", 1),
                                _buildHeaderCell("السعر", 1),
                                _buildHeaderCell("الحالة", 1),
                                _buildHeaderCell("الإجراءات", 1),
                              ]),
                            ),
                          ),
                          Obx(() {
                            if (controller.isLoadingPackages.value) {
                              return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.r)));
                            }
                            if (controller.packagesList.isEmpty) {
                              return SliverFillRemaining(
                                child: Center(
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.card_giftcard, size: 64.r, color: AppColors.textSecondary(isDark)),
                                    SizedBox(height: 16.h),
                                    Text('لا توجد باقات', style: TextStyle(fontSize: 16.sp, fontFamily: AppTextStyles.tajawal, color: AppColors.textSecondary(isDark))),
                                  ]),
                                ),
                              );
                            }

                            return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildPackageRow(controller.packagesList[index], index, isDark, index % 2 == 0 ? rowColor1 : rowColor2), childCount: controller.packagesList.length));
                          }),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, fontFamily: AppTextStyles.tajawal, fontWeight: FontWeight.w700, color: AppColors.textPrimary(Theme.of(context).brightness == Brightness.dark))),
    );
  }

  Widget _buildPackageTypeRow(PackageType type, int index, bool isDark, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(type.id.toString(), 1),
        _buildCell(type.name, 2, fontWeight: FontWeight.w500),
        _buildCell(type.description ?? 'لا يوجد وصف', 3, color: AppColors.textSecondary(isDark), maxLines: 2, fontWeight: FontWeight.w500),
        _buildCell(type.createdAt ?? '-', 2),
        Expanded(flex: 1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: Icon(Icons.edit, size: 20.r, color: AppColors.primary), onPressed: () => _showEditPackageTypeDialog(type)),
          SizedBox(width: 8.w),
          IconButton(icon: Icon(Icons.delete, size: 20.r, color: AppColors.error), onPressed: () => _showDeletePackageTypeDialog(type.id!)),
        ])),
      ]),
    );
  }

  Widget _buildPackageRow(PremiumPackage pkg, int index, bool isDark, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      color: color,
      child: Row(textDirection: TextDirection.rtl, children: [
        _buildCell(pkg.id.toString(), 1),
        _buildCell(pkg.name, 2, fontWeight: FontWeight.w500),
        _buildCell(pkg.type?.name ?? 'بدون نوع', 1),
        _buildCell(pkg.description ?? 'لا يوجد وصف', 2, color: AppColors.textSecondary(isDark), maxLines: 2, fontWeight: FontWeight.w500),
        _buildCell('${pkg.durationDays} يوم', 1),
        _buildCell('${pkg.price} ${pkg.currency}', 1),
        // activation toggle
        Expanded(flex: 1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () => controller.toggleActive(pkg.id!),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(color: pkg.isActive ? _statusColors[0].withOpacity(0.2) : _statusColors[1].withOpacity(0.2), borderRadius: BorderRadius.circular(20.r), border: Border.all(color: pkg.isActive ? _statusColors[0] : _statusColors[1], width: 1)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(pkg.isActive ? Icons.visibility : Icons.visibility_off, size: 16.r, color: pkg.isActive ? _statusColors[0] : _statusColors[1]),
                SizedBox(width: 6.w),
                Text(pkg.isActive ? 'مفعلة' : 'غير مفعلة', style: TextStyle(fontSize: 12.sp, fontFamily: AppTextStyles.tajawal, color: pkg.isActive ? _statusColors[0] : _statusColors[1], fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ])),
        Expanded(flex: 1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: Icon(Icons.edit, size: 20.r, color: AppColors.primary), onPressed: () => _showEditPackageDialog(pkg)),
          SizedBox(width: 8.w),
          IconButton(icon: Icon(Icons.delete, size: 20.r, color: AppColors.error), onPressed: () => _showDeletePackageDialog(pkg.id!)),
        ])),
      ]),
    );
  }

  Widget _buildCell(String text, int flex, {Color? color, FontWeight fontWeight = FontWeight.normal, int maxLines = 1}) {
    return Expanded(
      flex: flex,
      child: Text(text, textAlign: TextAlign.center, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.sp, fontFamily: AppTextStyles.tajawal, fontWeight: fontWeight, color: color)),
    );
  }
}