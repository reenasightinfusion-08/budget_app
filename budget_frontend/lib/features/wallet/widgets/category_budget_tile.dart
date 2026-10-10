import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/amount_input_dialog.dart';
import 'package:budget_frontend/core/widgets/app_progress_bar.dart';
import 'package:budget_frontend/core/widgets/category_icon_badge.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';
import 'package:budget_frontend/features/wallet/widgets/limit_pill.dart';

class CategoryBudgetTile extends StatelessWidget {
  const CategoryBudgetTile({
    super.key,
    required this.category,
    required this.onEditLimit,
    this.showDivider = true,
  });

  final BudgetCategoryModel category;
  final ValueChanged<int> onEditLimit;
  final bool showDivider;

  Future<void> editLimit(BuildContext context) async {
    final limit = await AmountInputDialog.show(
      context,
      title: 'Edit ${category.label} Plan',
      hint: 'Enter plan limit',
      initialValue: category.limit,
    );
    if (limit != null) onEditLimit(limit);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 13.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryIconBadge(
                    icon: category.icon,
                    size: 44,
                    iconColor: AppColors.accent,
                    backgroundColor: AppColors.fill,
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.label, style: AppTextStyle.toggleTitle),
                        2.verticalSpace,
                        Text(
                          category.statusText,
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.horizontalSpace,
                  LimitPill(
                    spent: category.spent,
                    limit: category.limit,
                    onTap: () => editLimit(context),
                  ),
                ],
              ),
              10.verticalSpace,
              AppProgressBar(
                ratio: category.progressRatio,
                height: 8,
                gradient: AppGradients.accent,
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1.h, thickness: 1.h, color: AppColors.line),
      ],
    );
  }
}
