import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/CityController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../core/data/model/City.dart';
import '../AdminSidebar.dart';

class CitiesViewMobile extends StatefulWidget {
  const CitiesViewMobile({Key? key}) : super(key: key);

  @override
  _CitiesViewMobileState createState() => _CitiesViewMobileState();
}

class _CitiesViewMobileState extends State<CitiesViewMobile> {
  final CityController cityController = Get.put(CityController());
  final TextEditingController _arabicNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cityController.fetchCities(country: 'SY', language: 'ar');
  }

  String _formatDaysAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      final days = difference.inDays;
      return 'منذ $days يوم';
    } catch (e) {
      return dateString;
    }
  }

  void _resetForm() {
    _arabicNameController.clear();
    _countryController.clear();
  }

  void _showAddEditDialog({TheCity? city}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEdit = city != null;

    if (isEdit) {
      final arabicName = cityController.getCityName(city, lang: 'ar');
      _arabicNameController.text = arabicName;
      _countryController.text = city.country;
    } else {
      _resetForm();
    }

    Get.bottomSheet(
      _buildBottomSheet(
        title: isEdit ? 'تعديل المدينة' : 'إضافة مدينة',
        icon: isEdit ? Icons.edit : Icons.add,
        onSave: () async {
          if (_arabicNameController.text.isEmpty) {
            Get.snackbar(
              'تحذير',
              'يرجى إدخال اسم المدينة',
              backgroundColor: Colors.orange,
              colorText: Colors.white
            );
            return;
          }

          if (_countryController.text.isEmpty) {
            Get.snackbar(
              'تحذير',
              'يرجى إدخال رمز الدولة',
              backgroundColor: Colors.orange,
              colorText: Colors.white
            );
            return;
          }

          bool success;
          if (isEdit) {
            success = await cityController.updateCity(
              id: city!.id,
              arabicName: _arabicNameController.text,
              country: _countryController.text,
            );
          } else {
            success = await cityController.createCity(
              arabicName: _arabicNameController.text,
              country: _countryController.text,
            );
          }

          if (success) {
            _resetForm();
            Get.back();
          }
        },
        isDarkMode: isDarkMode,
        isEdit: isEdit,
        city: city,
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDarkMode),
    );
  }

  Widget _buildBottomSheet({
    required String title,
    required IconData icon,
    required VoidCallback onSave,
    required bool isDarkMode,
    required bool isEdit,
    TheCity? city,
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
                color: AppColors.textPrimary(isDarkMode),
              )),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 22.r),
                onPressed: () {
                  _resetForm();
                  Get.back();
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _arabicNameController,
            label: 'اسم المدينة (عربي)',
            icon: Icons.location_city,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _countryController,
            label: 'رمز الدولة (مثال: SY)',
            icon: Icons.flag,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: 16.h),
          Text(
            'سيتم توليد الترجمة الإنجليزية تلقائيًا',
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: AppTextStyles.tajawal,
              color: AppColors.textSecondary(isDarkMode),
            ),
          ),
          SizedBox(height: 24.h),
          _buildActionButtons(onSave, isDarkMode, isEdit),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 16.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDarkMode),
      ),
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
        prefixIcon: Icon(icon, size: 22.r),
      ),
    );
  }

  Widget _buildActionButtons(VoidCallback onSave, bool isDarkMode, bool isEdit) {
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
            onPressed: cityController.isSaving.value ? null : onSave,
            child: cityController.isSaving.value
              ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isEdit ? Icons.edit : Icons.add, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(isEdit ? 'تحديث' : 'إضافة', style: TextStyle(
                      fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.bold,
                    )),
                  ]),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: TextButton(
            onPressed: () {
              _resetForm();
              Get.back();
            },
            child: Text('إلغاء', style: TextStyle(
              fontSize: 14.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textSecondary(isDarkMode),
            )),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(int cityId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface(isDarkMode),
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
            Text('هل أنت متأكد من حذف هذه المدينة؟', style: TextStyle(
              fontSize:13.sp, fontFamily: AppTextStyles.tajawal,
              color: AppColors.textPrimary(isDarkMode)),
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
              color: AppColors.textSecondary(isDarkMode),
            )),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal:28.w, vertical:12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
            onPressed: cityController.isDeleting.value ? null : () {
              cityController.deleteCity(id: cityId);
              Get.back();
            },
            child: cityController.isDeleting.value
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: Drawer(
        child: AdminSidebar(
          isMobile: true,
          onClose: () => Navigator.pop(context),
        ),
      ),
      appBar: AppBar(
        title: Text('إدارة المدن', 
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          )
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 22.r),
            onPressed: () {
              _resetForm();
              _showAddEditDialog();
            },
            tooltip: 'إضافة مدينة',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Obx(() {
          if (cityController.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary, 
                strokeWidth: 3.r
              ),
            );
          }
          
          if (cityController.citiesList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_city, size: 64.r, 
                       color: AppColors.textSecondary(isDarkMode)),
                  SizedBox(height: 16.h),
                  Text('لا يوجد مدن', style: TextStyle(
                    fontSize: 16.sp, fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDarkMode),
                  )),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: cityController.citiesList.length,
            itemBuilder: (context, index) {
              final city = cityController.citiesList[index];
              return _buildCityCard(city, isDarkMode);
            },
          );
        }),
      ),
    );
  }

  Widget _buildCityCard(TheCity city, bool isDarkMode) {
    final arabicName = cityController.getCityName(city, lang: 'ar');
    final englishName = cityController.getCityName(city, lang: 'en');
    
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
                  arabicName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDarkMode),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    city.country,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Text(
              'الاسم الإنجليزي: $englishName',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDarkMode),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              'المعرف الفريد: ${city.slug}',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDarkMode),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              'تاريخ الإنشاء: ${_formatDaysAgo(city.createdAt)}',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDarkMode),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit, size: 18.r),
                    label: Text('تعديل', style: TextStyle(fontSize: 12.sp)),
                    onPressed: () => _showAddEditDialog(city: city),
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
                    onPressed: () => _showDeleteDialog(city.id),
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
}