import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tappuu_dashboard/core/constant/appcolors.dart';

class ImageUploadWidget extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const ImageUploadWidget({
    Key? key,
    required this.imageBytes,
    required this.onPickImage,
    required this.onRemoveImage,
  }) : super(key: key);

  // دالة للتحقق إذا كانت الصورة بصيغة SVG
  bool _isSvg(Uint8List bytes) {
    if (bytes.isEmpty) return false;
    final header = String.fromCharCodes(bytes.sublist(0, 5)).toLowerCase();
    return header.contains('<svg') || header.contains('<?xml');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border(isDarkMode),
          width: 1.r,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Expanded(
            child: imageBytes != null
                ? Stack(
                    children: [
                      // عرض SVG إذا كان الملف من هذا النوع
                      if (_isSvg(imageBytes!))
                        SvgPicture.memory(
                          imageBytes!,
                          width: double.infinity,
                          height: double.infinity,
                          placeholderBuilder: (context) => Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      // عرض الصور العادية (JPG, PNG, إلخ)
                      else
                        Image.memory(
                          imageBytes!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      Positioned(
                        top: 8.r,
                        right: 8.r,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white, size: 20.r),
                            onPressed: onRemoveImage,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 40.r, color: AppColors.textSecondary(isDarkMode)),
                        SizedBox(height: 8.h),
                        Text(
                          'لم يتم اختيار صورة',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.card(isDarkMode),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(11.r),
                bottomRight: Radius.circular(11.r),
              ),
            ),
            child: TextButton(
              onPressed: onPickImage,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 18.r, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Text(
                    'اختر صورة',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
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