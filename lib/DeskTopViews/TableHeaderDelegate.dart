import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


/// Delegate لصف ثابت أعلاه مع خصائص عامة للألوان والهوية
class TableHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  ///
  /// [child]: البنية المُراد عرضها كصف ثابت
  /// [height]: ارتفاع الصف (افتراضي 56.h)
  TableHeaderDelegate({
    required this.child,
    this.height = 56,
  });

  @override
  double get minExtent => height.h;

  @override
  double get maxExtent => height.h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant TableHeaderDelegate old) {
    return old.child != child || old.height != height;
  }
}

/// كلاس مساعد لتعريف أعمدة الجدول
class HeaderColumn {
  final String title;
  final int flex;

  HeaderColumn({required this.title, this.flex = 1});

  /// يبقى متساوياً عند تشابه العنوان والمرونة
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeaderColumn && other.title == title && other.flex == flex;
  }

  @override
  int get hashCode => title.hashCode ^ flex.hashCode;
}
