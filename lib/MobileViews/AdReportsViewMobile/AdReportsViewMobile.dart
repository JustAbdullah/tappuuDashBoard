// lib/views/AdReportsViewMobile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../controllers/ad_report_controller.dart';
import '../../core/data/model/ad_report_model.dart';
import '../AdminSidebar.dart';

class AdReportsViewMobile extends StatefulWidget {
  const AdReportsViewMobile({Key? key}) : super(key: key);

  @override
  _AdReportsViewMobileState createState() => _AdReportsViewMobileState();
}

class _AdReportsViewMobileState extends State<AdReportsViewMobile> {
  final AdReportController reportController = Get.put(AdReportController());
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    reportController.fetchReports();
  }

  String _formatDaysAgo(DateTime? date) {
    if (date == null) return 'غير محدد';
    final now = DateTime.now();
    final difference = now.difference(date);
    final days = difference.inDays;
    if (days == 0) return 'اليوم';
    return 'منذ $days يوم';
  }

  void _showUpdateStatusDialog(int reportId, String currentStatus) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String? newStatus = currentStatus;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.update, size: 24.r, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Text(
                    'تحديث حالة البلاغ',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'اختر الحالة الجديدة للبلاغ:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: AppTextStyles.tajawal,
                  color: AppColors.textPrimary(isDarkMode),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.card(isDarkMode),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border(isDarkMode)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: newStatus,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text(
                          'معلق',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'in_review',
                        child: Text(
                          'قيد المراجعة',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'resolved',
                        child: Text(
                          'تم الحل',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'rejected',
                        child: Text(
                          'مرفوض',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        newStatus = value;
                      });
                    },
                  ),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (newStatus != null && newStatus != currentStatus) {
                        reportController.updateStatus(
                          id: reportId,
                          status: newStatus!,
                        );
                        Get.back();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.update, size: 20.r),
                        SizedBox(width: 8.w),
                        Text(
                          'تحديث',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(AdReportModel report) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تفاصيل البلاغ',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontFamily: AppTextStyles.tajawal,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24.r),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        // Report Details
                        Text(
                          'معلومات البلاغ:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        _buildDetailRow('معرف البلاغ:', report.id.toString(), isDarkMode),
                        _buildDetailRow('السبب:', report.reason ?? 'غير محدد', isDarkMode),
                        _buildDetailRow('التفاصيل:', report.details ?? 'غير محدد', isDarkMode),
                        _buildDetailRow('الحالة:', _getStatusText(report.status), isDarkMode),
                        _buildDetailRow('تاريخ البلاغ:', _formatDaysAgo(report.date), isDarkMode),
                        _buildDetailRow('تم التعامل معه في:', _formatDaysAgo(report.handledAt), isDarkMode),
                        
                        SizedBox(height: 20.h),
                        
                        // Reporter Details
                        Text(
                          'معلومات مقدم البلاغ:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        if (report.isAnonymous)
                          _buildDetailRow('النوع:', 'مجهول', isDarkMode)
                        else if (report.reporter != null)
                          Column(
                            children: [
                              _buildDetailRow('المعرف:', report.reporter!.id.toString(), isDarkMode),
                              _buildDetailRow('البريد الإلكتروني:', report.reporter!.email ?? 'غير محدد', isDarkMode),
                            ],
                          )
                        else
                          _buildDetailRow('المستخدم:', 'غير محدد', isDarkMode),
                        
                        SizedBox(height: 20.h),
                        
                        // Ad Details
                        Text(
                          'معلومات الإعلان:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: AppTextStyles.tajawal,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(isDarkMode),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        if (report.ad != null)
                          Column(
                            children: [
                              _buildDetailRow('معرف الإعلان:', report.ad!.id.toString(), isDarkMode),
                              _buildDetailRow('عنوان الإعلان:', report.ad!.title ?? 'غير محدد', isDarkMode),
                              _buildDetailRow('السعر:', report.ad!.price?.toString() ?? 'غير محدد', isDarkMode),
                              _buildDetailRow('الحالة:', report.ad!.status ?? 'غير محدد', isDarkMode),
                              _buildDetailRow('عدد المشاهدات:', report.ad!.views?.toString() ?? '0', isDarkMode),
                            ],
                          )
                        else
                          _buildDetailRow('الإعلان:', 'تم حذف الإعلان', isDarkMode),
                        
                        SizedBox(height: 20.h),
                        
                        // Evidence
                        if (report.evidence.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.rtl,
                            children: [
                              Text(
                                'الأدلة:',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: AppTextStyles.tajawal,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(isDarkMode),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Wrap(
                                spacing: 10.w,
                                runSpacing: 10.h,
                                children: report.evidence.map((evidence) {
                                  return Image.network(
                                    evidence,
                                    width: 100.w,
                                    height: 100.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100.w,
                                        height: 100.h,
                                        color: Colors.grey,
                                        child: Icon(Icons.broken_image),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDarkMode),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDarkMode),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'in_review':
        return 'قيد المراجعة';
      case 'resolved':
        return 'تم الحل';
      case 'rejected':
        return 'مرفوض';
      default:
        return status ?? 'غير محدد';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_review':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(int reportId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface(isDarkMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 24.r, color: AppColors.error),
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
                'هل أنت متأكد من حذف هذا البلاغ؟',
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      reportController.deleteReport(reportId);
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
                ),
              ],
            ),
          ],
        ),
      ),
    ));
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
        title: Text(
          'إدارة البلاغات',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          ),
        ),
        actions: [
          // Filter dropdown
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.card(isDarkMode),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border(isDarkMode)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: Icon(Icons.filter_list, size: 20.r),
                  items: [
                    DropdownMenuItem(
                      value: 'الكل',
                      child: Text(
                        'الكل',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text(
                        'معلق',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'in_review',
                      child: Text(
                        'قيد المراجعة',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text(
                        'تم الحل',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text(
                        'مرفوض',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                      if (_selectedFilter == 'الكل') {
                        reportController.fetchReports();
                      } else {
                        reportController.fetchReports(reportStatus: _selectedFilter);
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // Search bar
            Container(
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن بلاغ...',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: AppTextStyles.tajawal,
                          color: AppColors.textSecondary(isDarkMode),
                        ),
                        prefixIcon: Icon(Icons.search, size: 22.r),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        reportController.fetchReports(searchTitle: _searchController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      elevation: 1,
                    ),
                    child: Text(
                      'بحث',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppTextStyles.tajawal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Reports list
            Expanded(
              child: Obx(() {
                if (reportController.isLoadingReports.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3.r,
                    ),
                  );
                }
                
                if (reportController.reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.report_problem, size: 48.r, 
                             color: AppColors.textSecondary(isDarkMode)),
                        SizedBox(height: 16.h),
                        Text(
                          'لا يوجد بلاغات',
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
                  itemCount: reportController.reports.length,
                  itemBuilder: (context, index) {
                    final report = reportController.reports[index];
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'البلاغ #${report.id}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: AppTextStyles.tajawal,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(isDarkMode),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(report.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    _getStatusText(report.status),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontFamily: AppTextStyles.tajawal,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(report.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 12.h),
                            
                            Text(
                              report.reason ?? 'لا يوجد سبب',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textPrimary(isDarkMode),
                              ),
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            Text(
                              'الإعلان: ${report.ad?.title ?? 'تم حذف الإعلان'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDarkMode),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            Text(
                              'المبلغ: ${report.isAnonymous ? 'مجهول' : (report.reporter?.email ?? 'غير محدد')}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: AppTextStyles.tajawal,
                                color: AppColors.textSecondary(isDarkMode),
                              ),
                            ),
                            
                            SizedBox(height: 8.h),
                            
                            Text(
                              _formatDaysAgo(report.date),
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
                                IconButton(
                                  icon: Icon(Icons.visibility, size: 20.r, color: AppColors.primary),
                                  onPressed: () => _showDetailsDialog(report),
                                ),
                                IconButton(
                                  icon: Icon(Icons.update, size: 20.r, color: Colors.orange),
                                  onPressed: () => _showUpdateStatusDialog(report.id, report.status ?? 'pending'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 20.r, color: AppColors.error),
                                  onPressed: () => _showDeleteDialog(report.id),
                                ),
                              ],
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
}