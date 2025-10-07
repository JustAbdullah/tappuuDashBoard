// lib/views/CitiesViewDeskTop.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/CityController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../core/data/model/City.dart';
import '../AdminSidebarDeskTop.dart';

class CitiesViewDeskTop extends StatefulWidget {
  const CitiesViewDeskTop({Key? key}) : super(key: key);

  @override
  _CitiesViewDeskTopState createState() => _CitiesViewDeskTopState();
}

class _CitiesViewDeskTopState extends State<CitiesViewDeskTop> {
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
              minWidth: 400.w,
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
                      Icon(
                        isEdit ? Icons.edit : Icons.add,
                        size: 24.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        isEdit ? 'تعديل المدينة' : 'إضافة مدينة',
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
                  SizedBox(height: 24.h),
                  Text(
                    'سيتم توليد الترجمة الإنجليزية تلقائيًا',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          _resetForm();
                          Get.back();
                        },
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ),
                      Obx(() {
                        if (cityController.isSaving.value) {
                          return CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3.r,
                          );
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: EdgeInsets.symmetric(
                                horizontal: 28.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () async {
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isEdit ? Icons.edit : Icons.add, size: 20.r),
                              SizedBox(width: 8.w),
                              Text(
                                isEdit ? 'تحديث' : 'إضافة',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

  void _showDeleteDialog(int cityId) {
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
                      Icon(Icons.warning_amber_rounded,
                          size: 24.r, color: AppColors.error),
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
                    'هل أنت متأكد من حذف هذه المدينة؟',
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
                      Obx(() {
                        if (cityController.isDeleting.value) {
                          return CircularProgressIndicator(
                            color: AppColors.error,
                            strokeWidth: 3.r,
                          );
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 28.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            cityController.deleteCity(id: cityId);
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
                        );
                      }),
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
                        'إدارة المدن',
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
                          'إضافة مدينة',
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
                        onPressed: () {
                          _resetForm();
                          _showAddEditDialog();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
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
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.h, horizontal: 16.w),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppColors.grey800
                                      : AppColors.grey200,
                                ),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "المعرف",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "الاسم الفريد",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "الدولة",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "الاسم (عربي)",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "الاسم (إنجليزي)",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "تاريخ الإنشاء",
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: AppTextStyles.tajawal,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColors.textPrimary(isDarkMode),
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
                                          color:
                                              AppColors.textPrimary(isDarkMode),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Obx(() {
                              if (cityController.isLoading.value) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 3.r,
                                    ),
                                  ),
                                );
                              }

                              if (cityController.citiesList.isEmpty) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_city,
                                            size: 64.r,
                                            color: AppColors.textSecondary(
                                                isDarkMode)),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'لا يوجد مدن',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontFamily: AppTextStyles.tajawal,
                                            color: AppColors.textSecondary(
                                                isDarkMode),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final city =
                                        cityController.citiesList[index];
                                    final arabicName = cityController.getCityName(city, lang: 'ar');
                                    final englishName = cityController.getCityName(city, lang: 'en');
                                    final rowColor = index % 2 == 0
                                        ? rowColor1
                                        : rowColor2;

                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 14.h, horizontal: 16.w),
                                      color: rowColor,
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              city.id.toString(),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(
                                                    isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              city.slug,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(
                                                    isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              city.country,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(
                                                    isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              arabicName,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary(
                                                    isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              englishName,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textPrimary(
                                                    isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _formatDaysAgo(city.createdAt),
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontFamily: AppTextStyles.tajawal,
                                                color: AppColors.textSecondary(
                                                    isDarkMode),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit,
                                                      size: 18.r,
                                                      color: AppColors.primary),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      BoxConstraints(),
                                                  onPressed: () {
                                                    _showAddEditDialog(
                                                        city: city);
                                                  },
                                                ),
                                                SizedBox(width: 8.w),
                                                IconButton(
                                                  icon: Icon(Icons.delete,
                                                      size: 18.r,
                                                      color: AppColors.error),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      BoxConstraints(),
                                                  onPressed: () =>
                                                      _showDeleteDialog(
                                                          city.id),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount:
                                      cityController.citiesList.length,
                                ),
                              );
                            }),
                          ],
                        ),
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