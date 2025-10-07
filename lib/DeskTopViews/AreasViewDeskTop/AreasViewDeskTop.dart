import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/CityController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../controllers/areaController.dart';
import '../../core/data/model/Area.dart';
import '../AdminSidebarDeskTop.dart';

class AreasViewDeskTop extends StatefulWidget {
  const AreasViewDeskTop({Key? key}) : super(key: key);

  @override
  _AreasViewDeskTopState createState() => _AreasViewDeskTopState();
}

class _AreasViewDeskTopState extends State<AreasViewDeskTop> {
  final AreaController areaController = Get.put(AreaController());
  final CityController cityController = Get.put(CityController());
  final TextEditingController _nameController = TextEditingController();
  int? _selectedCityId;
  int? _filterCityId;

  @override
  void initState() {
    super.initState();
    cityController.fetchCities(country: 'SY', language: 'ar');
    areaController.fetchAreas(); // جلب جميع المناطق أولاً
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
    _nameController.clear();
    _selectedCityId = null;
  }

  void _applyFilter() {
    areaController.fetchAreas(cityId: _filterCityId);
  }

  void _clearFilter() {
    setState(() {
      _filterCityId = null;
    });
    areaController.fetchAreas(); // جلب جميع المناطق بدون تصفية
  }

  void _showAddEditDialog({Area? area}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEdit = area != null;

    if (isEdit) {
      _nameController.text = area.name;
      _selectedCityId = area.cityId;
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
                        isEdit ? 'تعديل المنطقة' : 'إضافة منطقة',
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
                  
                  // حقل اختيار المدينة
                  Obx(() {
                    if (cityController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    return DropdownButtonFormField<int>(
                      value: _selectedCityId,
                      decoration: InputDecoration(
                        labelText: 'اختر المدينة',
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
                        prefixIcon: Icon(Icons.location_city, size: 22.r),
                      ),
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text('اختر المدينة', style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                          )),
                        ),
                        ...cityController.citiesList.map((city) {
                          final cityName = cityController.getCityName(city, lang: 'ar');
                          return DropdownMenuItem<int>(
                            value: city.id,
                            child: Text(cityName),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCityId = value;
                        });
                      },
                    );
                  }),
                  
                  SizedBox(height: 16.h),
                  
                  // حقل اسم المنطقة
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                    decoration: InputDecoration(
                      labelText: 'اسم المنطقة',
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
                      prefixIcon: Icon(Icons.location_on, size: 22.r),
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
                        if (areaController.isSaving.value) {
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
                            if (_selectedCityId == null) {
                              Get.snackbar(
                                'تحذير',
                                'يرجى اختيار المدينة',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white
                              );
                              return;
                            }

                            if (_nameController.text.isEmpty) {
                              Get.snackbar(
                                'تحذير',
                                'يرجى إدخال اسم المنطقة',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white
                              );
                              return;
                            }

                            bool success;
                            if (isEdit) {
                              success = await areaController.updateArea(
                                id: area!.id,
                                name: _nameController.text,
                              );
                            } else {
                              success = await areaController.createArea(
                                cityId: _selectedCityId!,
                                name: _nameController.text,
                              );
                            }

                            if (success) {
                              _resetForm();
                              Get.back();
                              // إعادة تحميل البيانات بعد الإضافة/التعديل
                              if (_filterCityId != null) {
                                areaController.fetchAreas(cityId: _filterCityId);
                              } else {
                                areaController.fetchAreas();
                              }
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

  void _showDeleteDialog(int areaId) {
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
                    'هل أنت متأكد من حذف هذه المنطقة؟',
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
                        if (areaController.isDeleting.value) {
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
                            areaController.deleteArea(id: areaId);
                            Get.back();
                            // إعادة تحميل البيانات بعد الحذف
                            if (_filterCityId != null) {
                              areaController.fetchAreas(cityId: _filterCityId);
                            } else {
                              areaController.fetchAreas();
                            }
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
                        'إدارة المناطق',
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
                          'إضافة منطقة',
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
                  SizedBox(height: 16.h),
                  
                  // صندوق التصفية حسب المدينة
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDarkMode),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          'تصفية حسب المدينة:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Dropdown لاختيار المدينة للتصفية
                        Obx(() {
                          if (cityController.isLoading.value) {
                            return CircularProgressIndicator(color: AppColors.primary);
                          }
                          
                          return Container(
                            width: 250.w,
                            decoration: BoxDecoration(
                              color: AppColors.surface(isDarkMode),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppColors.border(isDarkMode)),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: DropdownButton<int>(
                              value: _filterCityId,
                              isExpanded: true,
                              underline: SizedBox(),
                              items: [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text(
                                    'جميع المدن',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: AppTextStyles.tajawal,
                                      color: AppColors.textPrimary(isDarkMode),
                                    ),
                                  ),
                                ),
                                ...cityController.citiesList.map((city) {
                                  final cityName = cityController.getCityName(city, lang: 'ar');
                                  return DropdownMenuItem<int>(
                                    value: city.id,
                                    child: Text(
                                      cityName,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: AppTextStyles.tajawal,
                                        color: AppColors.textPrimary(isDarkMode),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _filterCityId = value;
                                });
                              },
                            ),
                          );
                        }),
                        SizedBox(width: 16.w),
                        ElevatedButton(
                          onPressed: _applyFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          ),
                          child: Text(
                            'تطبيق التصفية',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (_filterCityId != null)
                          ElevatedButton(
                            onPressed: _clearFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            ),
                            child: Text(
                              'إلغاء التصفية',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                              ),
                            ),
                          ),
                      ],
                    ),
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
                                        "اسم المنطقة",
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
                                        "المدينة",
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
                              if (areaController.isLoading.value) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 3.r,
                                    ),
                                  ),
                                );
                              }

                              if (areaController.areas.isEmpty) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 64.r,
                                            color: AppColors.textSecondary(
                                                isDarkMode)),
                                        SizedBox(height: 16.h),
                                        Text(
                                          _filterCityId != null 
                                            ? 'لا توجد مناطق في المدينة المحددة'
                                            : 'لا يوجد مناطق',
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
                                    final area =
                                        areaController.areas[index];
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
                                              area.id.toString(),
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
                                              area.name,
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
                                              area.cityName ?? 'غير معروف',
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
                                              area.createdAt != null
                                                  ? _formatDaysAgo(area.createdAt!.toIso8601String())
                                                  : 'غير معروف',
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
                                                        area: area);
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
                                                          area.id),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount:
                                      areaController.areas.length,
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