import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_validators.dart';
import 'package:budget_frontend/core/widgets/app_amount_field.dart';
import 'package:budget_frontend/features/setup/widgets/setup_budget_hint.dart';

class SetupBudgetCard extends StatelessWidget {
  const SetupBudgetCard({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppGradients.moneyCard,
          borderRadius: AppBorderRadius.card,
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 34.r,
              spreadRadius: -18.r,
              offset: Offset(0, 18.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppBorderRadius.card,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.moneyCardGlow)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your monthly budget', style: AppTextStyle.cardLabel),
                    4.verticalSpace,
                    AppAmountField(
                      controller: controller,
                      validator: AppValidators.budget,
                      onChanged: onChanged,
                    ),
                    6.verticalSpace,
                    const SetupBudgetHint(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
