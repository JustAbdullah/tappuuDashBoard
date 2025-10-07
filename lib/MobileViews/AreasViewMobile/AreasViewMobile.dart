import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/CityController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import 'package:tappuu_dashboard/controllers/areaController.dart';
import 'package:tappuu_dashboard/core/data/model/Area.dart';

import '../AdminSidebar.dart';

class AreasViewMobile extends StatefulWidget {
  const AreasViewMobile({Key? key}) : super(key: key);

  @override
  _AreasViewMobileState createState() => _AreasViewMobileState();
}

class _AreasViewMobileState extends State<AreasViewMobile> {
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

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          left: 16.w,
          right: 16.w,
          top: 20.h
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(isDarkMode),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
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
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDarkMode),
    );
  }

  void _showDeleteDialog(int areaId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
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
                    fontSize: 18.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'هل أنت متأكد من حذف هذه المنطقة؟',
              style: TextStyle(
                fontSize: 16.sp,
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
                      fontSize: 14.sp,
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
                    child: Text(
                      'حذف',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
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
        title: Text('إدارة المناطق', 
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
            tooltip: 'إضافة منطقة',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صندوق التصفية حسب المدينة
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.card(isDarkMode),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: 12.h),
                  // Dropdown لاختيار المدينة للتصفية
                  Obx(() {
                    if (cityController.isLoading.value) {
                      return Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    
                    return DropdownButtonFormField<int>(
                      value: _filterCityId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.border(isDarkMode)),
                        ),
                        filled: true,
                        fillColor: AppColors.surface(isDarkMode),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                      isExpanded: true,
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
                    );
                  }),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'تطبيق التصفية',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: AppTextStyles.tajawal,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      if (_filterCityId != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: Text(
                              'إلغاء التصفية',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // قائمة المناطق
            Expanded(
              child: Obx(() {
                if (areaController.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3.r,
                    ),
                  );
                }

                if (areaController.areas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            size: 64.r,
                            color: AppColors.textSecondary(isDarkMode)),
                        SizedBox(height: 16.h),
                        Text(
                          _filterCityId != null 
                            ? 'لا توجد مناطق في المدينة المحددة'
                            : 'لا يوجد مناطق',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: areaController.areas.length,
                  itemBuilder: (context, index) {
                    final area = areaController.areas[index];
                    return _buildAreaCard(area, isDarkMode);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaCard(Area area, bool isDarkMode) {
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
                  area.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: AppTextStyles.tajawal,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(isDarkMode),
                  ),
                ),
                Text(
                  'المعرف: ${area.id}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textSecondary(isDarkMode),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Text(
              'المدينة: ${area.cityName ?? 'غير معروف'}',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textPrimary(isDarkMode),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              area.createdAt != null
                  ? 'تاريخ الإنشاء: ${_formatDaysAgo(area.createdAt!.toIso8601String())}'
                  : 'تاريخ الإنشاء: غير معروف',
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
                    onPressed: () => _showAddEditDialog(area: area),
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
                    onPressed: () => _showDeleteDialog(area.id),
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