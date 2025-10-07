import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tappuu_dashboard/controllers/TermsAndConditionsController.dart';
import 'package:tappuu_dashboard/core/constant/app_text_styles.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';
import '../../core/data/model/TermsAndConditions.dart';
import '../AdminSidebar.dart';

class TermsAndConditionsViewMobile extends StatefulWidget {
  const TermsAndConditionsViewMobile({Key? key}) : super(key: key);

  @override
  _TermsAndConditionsViewMobileState createState() => _TermsAndConditionsViewMobileState();
}

class _TermsAndConditionsViewMobileState extends State<TermsAndConditionsViewMobile> {
  final TermsAndConditionsController termsController = Get.put(TermsAndConditionsController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = 'ar'; // اللغة الافتراضية
    
    // عند تحميل البيانات، نملأ الحقول - نفس تصميم الحاسوب
    ever(termsController.termsList, (termsList) {
      if (termsList.isNotEmpty && _selectedLanguage != null) {
        final term = termsList.firstWhereOrNull((t) => t.language == _selectedLanguage);
        if (term != null) {
          _titleController.text = term.title;
          _contentController.text = term.content;
        }
      }
    });
  }

  void _resetForm() {
    _titleController.clear();
    _contentController.clear();
    _selectedLanguage = 'ar';
  }

  void _showAddEditDialog({TermsAndConditions? term}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEdit = term != null;

    if (isEdit) {
      _titleController.text = term.title;
      _contentController.text = term.content;
      _selectedLanguage = term.language ?? 'ar';
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
                    isEdit ? 'تعديل الشروط والأحكام' : 'إضافة شروط وأحكام',
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
              _buildTextField(
                controller: _titleController,
                label: 'العنوان',
                icon: Icons.title,
                isDarkMode: isDarkMode,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _contentController,
                label: 'المحتوى',
                icon: Icons.description,
                isDarkMode: isDarkMode,
                maxLines: 8,
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
                    if (termsController.isLoading.value) {
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
                        if (_titleController.text.isEmpty) {
                          Get.snackbar(
                            'تحذير',
                            'يرجى إدخال العنوان',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white
                          );
                          return;
                        }

                        if (_contentController.text.isEmpty) {
                          Get.snackbar(
                            'تحذير',
                            'يرجى إدخال المحتوى',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white
                          );
                          return;
                        }

                        if (_selectedLanguage == null) {
                          Get.snackbar(
                            'تحذير',
                            'يرجى اختيار اللغة',
                            backgroundColor: Colors.orange,
                            colorText: Colors.white
                          );
                          return;
                        }

                        bool success;
                        if (isEdit) {
                          success = await termsController.updateTerm(
                            id: term!.id,
                            title: _titleController.text,
                            content: _contentController.text,
                            language: _selectedLanguage,
                          );
                        } else {
                          success = await termsController.createTerm(
                            title: _titleController.text,
                            content: _contentController.text,
                            language: _selectedLanguage,
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
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.surface(isDarkMode),
    );
  }

  void _loadTermForSelectedLanguage() {
    final term = termsController.termsList.firstWhereOrNull(
      (t) => t.language == _selectedLanguage
    );
    
    if (term != null) {
      _titleController.text = term.title;
      _contentController.text = term.content;
    } else {
      _titleController.clear();
      _contentController.clear();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 16.sp,
        fontFamily: AppTextStyles.tajawal,
        color: AppColors.textPrimary(isDarkMode),
      ),
      maxLines: maxLines,
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

  Widget _buildLanguageBadge(String? language) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String text;
    Color color;

    switch (language) {
      case 'ar':
        text = 'عربي';
        color = Colors.green;
        break;
      case 'en':
        text = 'English';
        color = Colors.blue;
        break;
      case 'tr':
        text = 'Türkçe';
        color = Colors.red;
        break;
      case 'ku':
        text = 'Kurdî';
        color = Colors.orange;
        break;
      default:
        text = 'غير معروف';
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontFamily: AppTextStyles.tajawal,
          color: isDarkMode ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLanguageName(String? language) {
    switch (language) {
      case 'ar': return 'العربية';
      case 'en': return 'الإنجليزية';
      case 'tr': return 'التركية';
      case 'ku': return 'الكردية';
      default: return 'غير معروف';
    }
  }

  void _showDeleteDialog(int id) {
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
              'هل أنت متأكد من حذف هذه الشروط والأحكام؟',
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
                  if (termsController.isLoading.value) {
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
                      termsController.deleteTerm(id: id);
                      Get.back();
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
        title: Text('إدارة الشروط والأحكام', 
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: AppTextStyles.tajawal,
          )
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 22.r),
            onPressed: () {
              _showAddEditDialog();
            },
            tooltip: 'إضافة شروط جديدة',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Obx(() {
          if (termsController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          final terms = termsController.termsList;
          if (terms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description,
                      size: 64.r,
                      color: AppColors.textSecondary(isDarkMode)),
                  SizedBox(height: 16.h),
                  Text(
                    'لا يوجد شروط وأحكام',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'انقر على زر "إضافة شروط جديدة" لبدء الإضافة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: AppTextStyles.tajawal,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language selector
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  items: [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('الإنجليزية')),
                    DropdownMenuItem(value: 'tr', child: Text('التركية')),
                    DropdownMenuItem(value: 'ku', child: Text('الكردية')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value;
                      _loadTermForSelectedLanguage();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'اختر اللغة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.border(isDarkMode)),
                    ),
                    filled: true,
                    fillColor: AppColors.card(isDarkMode),
                    prefixIcon: Icon(Icons.language, size: 22.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              
              // Display the selected term
              Expanded(
                child: _buildTermCard(
                  terms.firstWhereOrNull((t) => t.language == _selectedLanguage),
                  isDarkMode
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // All terms list
              Text(
                'جميع اللغات المتاحة:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: AppTextStyles.tajawal,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDarkMode),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                flex: 2,
                child: _buildAllTermsList(terms, isDarkMode),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTermCard(TermsAndConditions? term, bool isDarkMode) {
    if (term == null) {
      return Card(
        color: AppColors.card(isDarkMode),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 48.r, color: Colors.orange),
                SizedBox(height: 16.h),
                Text(
                  'لا يوجد محتوى للغة المحددة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDarkMode),
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    _showAddEditDialog();
                  },
                  child: Text('إضافة محتوى لهذه اللغة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      color: AppColors.card(isDarkMode),
      elevation: 5,
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
                Expanded(
                  child: Text(
                    term.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontFamily: AppTextStyles.tajawal,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(isDarkMode),
                    ),
                  ),
                ),
                _buildLanguageBadge(term.language),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  term.content,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: AppTextStyles.tajawal,
                    color: AppColors.textPrimary(isDarkMode),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'اللغة: ${_getLanguageName(term.language)}',
              style: TextStyle(
                fontSize: 14.sp,
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
                    onPressed: () => _showAddEditDialog(term: term),
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
                    onPressed: () => _showDeleteDialog(term.id),
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

  Widget _buildAllTermsList(List<TermsAndConditions> terms, bool isDarkMode) {
    return ListView.builder(
      itemCount: terms.length,
      itemBuilder: (context, index) {
        final term = terms[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          color: AppColors.card(isDarkMode),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.r),
            title: Text(
              term.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: AppTextStyles.tajawal,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(isDarkMode),
              ),
            ),
            subtitle: Text(
              'اللغة: ${_getLanguageName(term.language)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: AppTextStyles.tajawal,
                color: AppColors.textSecondary(isDarkMode),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, size: 20.r, color: AppColors.primary),
                  onPressed: () => _showAddEditDialog(term: term),
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20.r, color: AppColors.error),
                  onPressed: () => _showDeleteDialog(term.id),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedLanguage = term.language;
                _loadTermForSelectedLanguage();
              });
            },
          ),
        );
      },
    );
  }
}