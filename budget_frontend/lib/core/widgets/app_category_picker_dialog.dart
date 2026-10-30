import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';

/// Centered modal dialog to pick a category in a clean 2-column grid.
class AppCategoryPickerDialog extends StatelessWidget {
  final String title;
  final String currentCategory;
  final String transactionType;
  final List<String> categories;

  const AppCategoryPickerDialog({
    super.key,
    this.title = 'Select category',
    required this.currentCategory,
    required this.transactionType,
    required this.categories,
  });

  static Future<String?> show({
    required BuildContext context,
    String title = 'Select category',
    required String currentCategory,
    required String transactionType,
    required List<String> categories,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppCategoryPickerDialog(
        title: title,
        currentCategory: currentCategory,
        transactionType: transactionType,
        categories: categories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final isSpend =
        transactionType.toLowerCase() == 'spend' ||
        transactionType.toLowerCase() == 'expense';
    final type = isSpend ? 'expense' : 'income';

    final allCategories = {
      ...categories,
      currentCategory,
    }.where((c) => c.trim().isNotEmpty).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 40 : 24.w,
        vertical: 24.h,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 380 : 330,
          maxHeight: MediaQuery.sizeOf(context).height * 0.70,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: AppColors.fill,
                      child: Icon(
                        AppIcons.close,
                        size: 14.sp,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              12.verticalSpace,

              // 2-column Grid of Categories
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: allCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: isTablet ? 3.1 : 2.85,
                  ),
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    final isSelected =
                        cat.toLowerCase() == currentCategory.toLowerCase();
                    final icon = CategoryRegistry.getIcon(cat, type);
                    final color = CategoryRegistry.getColor(
                      cat,
                      type,
                      !isSpend,
                    );

                    return GestureDetector(
                      onTap: () => Navigator.of(context).pop(cat),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.10)
                              : AppColors.fill.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14.r),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.accent,
                                  width: 1.4.w,
                                )
                              : Border.all(
                                  color: AppColors.line.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(icon, size: 15.sp, color: color),
                            ),
                            6.horizontalSpace,
                            Expanded(
                              child: Text(
                                cat,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12.5.sp,
                                  height: 1.15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.ink,
                                ),
                              ),
                            ),
                            if (isSelected) ...[
                              4.horizontalSpace,
                              Icon(
                                AppIcons.check,
                                color: AppColors.accent,
                                size: 15.sp,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
