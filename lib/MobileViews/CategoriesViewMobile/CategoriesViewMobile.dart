import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/CategoriesController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../DeskTopViews/ImageUploadWidget.dart';
import '../../core/data/model/category.dart';
import '../AdminSidebar.dart';


class CategoriesViewMobile extends StatefulWidget {
  const CategoriesViewMobile({Key? key}) : super(key: key);

  @override
  _CategoriesViewMobileState createState() => _CategoriesViewMobileState();
}

class _CategoriesViewMobileState extends State<CategoriesViewMobile> {
  final CategoriesController controller = Get.put(CategoriesController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editDescController = TextEditingController();
  
  String _lang = 'ar';
  String _filter = 'الكل';
  Category? _editingCat;
  
  final List<Color> iconColors = [
    const Color(0xFFFF754B),
    const Color(0xFF3BB8C8),
    const Color(0xFF85BE44),
    const Color(0xFFECA02F),
    const Color(0xFFF48FB1),
    const Color(0xFF90CAF9),
    const Color(0xFFA5D6A7),
    const Color(0xFFCE93D8),
  ];

  @override
  void initState() {
    super.initState();
    controller.fetchCategories(language:  _lang);
  }

  Color _getIconColor(int index) => iconColors[index % iconColors.length];

  void _showAddDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    controller.resetForm();
    _nameController.clear();
    _descController.clear();

    Get.dialog(_buildDialog(
      title: 'إضافة تصنيف جديد',
      icon: Icons.category,
      nameController: _nameController,
      descController: _descController,
      onSave: () async {
        if (_nameController.text.isEmpty) {
          Get.snackbar('تحذير', 'الرجاء إدخال اسم التصنيف',
            backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
        await controller.createCategory(
          _nameController.text, _descController.text);
        Get.back();
      },
      isDark: isDark,
    ));
  }

  void _showEditDialog(Category category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _editingCat = category;
    
    final arTr = category.translations.firstWhere(
      (t) => t.language == 'ar', 
      orElse: () => Translation(id:0, categoryId:0, language:'ar', name:'', description:'')
    );
    
    _editNameController.text = arTr.name;
    _editDescController.text = arTr.description ?? '';
    
    if (category.image != null && category.image!.isNotEmpty) {
      controller.loadImageFromUrl(category.image!);
    } else {
      controller.imageBytes.value = null;
    }

    Get.dialog(_buildDialog(
      title: 'تعديل التصنيف',
      icon: Icons.edit,
      nameController: _editNameController,
      descController: _editDescController,
      onSave: () async {
        if (_editNameController.text.isEmpty) {
          Get.snackbar('تحذير', 'الرجاء إدخال اسم التصنيف',
            backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
        if (_editingCat != null) {
          await controller.updateCategory(
            _editingCat!, _editNameController.text, _editDescController.text);
        }
        Get.back();
      },
      isDark: isDark,
    ));
  }

  Widget _buildDialog({
    required String title,
    required IconData icon,
    required TextEditingController nameController,
    required TextEditingController descController,
    required VoidCallback onSave,
    required bool isDark,
  }) {
    return Dialog(
      backgroundColor: AppColors.surface(isDark),
      insetPadding: EdgeInsets.all(16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.r),
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
                    fontSize: 18.sp, 
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.w700, 
                    color: AppColors.textPrimary(isDark),
                  )),
                ],
              ),
              SizedBox(height: 16.h),
              _buildTextField('اسم التصنيف (العربية)', Icons.text_fields, nameController, isDark),
              SizedBox(height: 12.h),
              _buildTextField('وصف التصنيف (العربية)', Icons.description, descController, isDark, maxLines: 2),
              SizedBox(height: 12.h),
              Text('صورة التصنيف (اختياري)', style: TextStyle(
                fontSize: 14.sp, 
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDark),
              )),
              SizedBox(height: 8.h),
              Obx(() => ImageUploadWidget(
                imageBytes: controller.imageBytes.value,
                onPickImage: controller.pickImage,
                onRemoveImage: controller.removeImage,
              )),
              SizedBox(height: 20.h),
              _buildActionButtons(onSave, isDark, title == 'إضافة تصنيف جديد'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, 
      bool isDark, {int maxLines = 1}) {
    return TextField(
      textDirection: TextDirection.rtl,
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: maxLines == 1 ? 16.sp : 14.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14.sp, 
          fontFamily: AppTextStyles.tajawal,
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
        TextButton(
          onPressed: () => Get.back(),
          child: Text('إلغاء', style: TextStyle(
            fontSize: 14.sp, 
            fontFamily: AppTextStyles.tajawal,
            color: AppColors.textSecondary(isDark),
          ),
        )),
        Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
          onPressed: controller.isSaving.value ? null : onSave,
          child: controller.isSaving.value
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isAdd ? Icons.add : Icons.save, size: 18.r),
                SizedBox(width: 6.w),
                Text(isAdd ? 'إضافة' : 'حفظ', style: TextStyle(
                  fontSize: 14.sp, 
                  fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                )),
              ]),
        )),
      ],
    );
  }

  void _showDeleteDialog(int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDark),
        insetPadding: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.warning_amber_rounded, size:24.r, color: AppColors.error),
                  SizedBox(width:10.w),
                  Text('تأكيد الحذف', style: TextStyle(
                    fontSize:16.sp, 
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.w700, 
                    color: AppColors.error,
                  )),
                ],
              ),
              SizedBox(height:20.h),
              Text('هل أنت متأكد من حذف هذا التصنيف؟', style: TextStyle(
                fontSize:14.sp, 
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textPrimary(isDark)),
              ),
              SizedBox(height:8.h),
              Text('سيتم حذف جميع البيانات المرتبطة به!', style: TextStyle(
                fontSize:12.sp, 
                fontFamily: AppTextStyles.tajawal,
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
                      fontSize:14.sp, 
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDark),
                    )),
                  ),
                  Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal:20.w, vertical:10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                    onPressed: controller.isDeleting.value ? null : () {
                      controller.deleteCategory(id);
                      Get.back();
                    },
                    child: controller.isDeleting.value
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth:2.r))
                      : Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.delete, size:18.r),
                          SizedBox(width:6.w),
                          Text('حذف', style: TextStyle(
                            fontSize:14.sp, 
                            fontFamily: AppTextStyles.tajawal,
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
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
     drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context), // دالة إغلاق الدرج
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.appBar(isDark),
        elevation: 2,
      
        title: Text('إدارة التصنيفات', style: TextStyle(
          fontSize: 18.sp, 
          fontFamily: AppTextStyles.tajawal,
          fontWeight: FontWeight.w800, 
          color: AppColors.onPrimary,
        )),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primary),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            // Language Toggle
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLangButton('ar', 'العربية', true),
                SizedBox(width: 10.w),
                _buildLangButton('en', 'English', false),
              ],
            ),
            SizedBox(height: 16.h),
            
            // Search and Filter
            Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(14.r),
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
                        color: AppColors.textPrimary(isDark)),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن تصنيف...',
                        hintStyle: TextStyle(
                          fontSize: 14.sp, 
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDark)),
                        prefixIcon: Icon(Icons.search, size: 22.r),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                
                ],
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => controller.fetchCategories(language:  _lang,searchName:_searchController.text.toString() ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text('بحث', style: TextStyle(
                fontSize: 16.sp, 
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.bold,
              )),
            ),
            SizedBox(height: 20.h),
            Text(
              'قائمة التصنيفات (${controller.categoriesList.length})',
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingCategories.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3.r,
                    ),
                  );
                }
                
                if (controller.categoriesList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined, 
                          size: 64.r, 
                          color: AppColors.textSecondary(isDark),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد تصنيفات',
                          style: TextStyle(
                            fontSize: 16.sp, 
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDark),
                          )  ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: controller.categoriesList.length,
                  itemBuilder: (context, index) {
                    final category = controller.categoriesList[index];
                    final tr = category.translations.firstWhere(
                      (t) => t.language == _lang,
                      orElse: () => Translation(
                        id: 0,
                        categoryId: 0,
                        language: _lang,
                        name: 'N/A',
                        description: 'N/A',
                      ),
                    );
                    
               // في واجهة العرض:
final createdAt = _parseDate(category.date) ?? DateTime.now().subtract(Duration(days: 1));
final dateText = _formatDaysAgo(createdAt);
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Container(
                                  width: 50.r,
                                  height: 50.r,
                                  decoration: BoxDecoration(
                                    color: _getIconColor(index),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: category.image != null && category.image!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(25.r),
                                          child: Image.network(
                                            category.image!,
                                            width: 30.r,
                                            height: 30.r,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.category,
                                          color: Colors.white,
                                          size: 24.r,
                                        ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Text(
                                        tr.name,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(isDark),
                                         )   ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        tr.description ?? 'لا يوجد وصف',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          color: AppColors.textSecondary(isDark),
                                        )  ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Divider(height: 1, color: AppColors.divider(isDark)),
                            SizedBox(height: 12.h),
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Icon(
                                      Icons.ad_units,
                                      size: 16.r,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'الإعلانات: ${category.adsCount}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  dateText,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    color: AppColors.textSecondary(isDark),
                                  ),
                             ) ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 18.r,
                                      color: AppColors.primary,
                                    ),
                                    label: Text(
                                      'تعديل',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    onPressed: () => _showEditDialog(category),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 8.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      side: BorderSide(color: AppColors.primary),
                                    ),
                                  ),
                                )
                                
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 18.r,
                                      color: AppColors.error,
                                    ),
                                    label: Text(
                                      'حذف',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.error,
                                      ),
                                    ),
                                    onPressed: () => _showDeleteDialog(category.id),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: 8.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      side: BorderSide(color: AppColors.error),
                                    ),
                                  ),
                                ),
                             ) ],
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

  Widget _buildLangButton(String lang, String text, bool isLeft) {
    final isSelected = _lang == lang;
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _lang = lang;
            controller.fetchCategories(language:  lang);
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
              bottomLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
              topRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
              bottomRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: AppTextStyles.tajawal,
          ),
        ),
      ),
    );
  }

 String _formatDaysAgo(DateTime date) {
  final now = DateTime.now();
  final days = now.difference(date).inDays;
  return 'منذ $days يوم';
}

DateTime? _parseDate(String dateString) {
  try {
    return DateTime.parse(dateString);
  } catch (_) {
    return null;
  }
}
}