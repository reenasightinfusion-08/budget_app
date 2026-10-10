import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryIconBadge extends StatelessWidget {
  const CategoryIconBadge({
    super.key,
    required this.icon,
    required this.size,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final double size;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 20.sp),
    );
  }
}
