import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/amount_input_dialog.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';

class GoalDetailBottomSheet extends StatefulWidget {
  const GoalDetailBottomSheet({super.key});

  /// Opens the goal detail bottom sheet.
  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: Text(
        'Goal Details',
        textAlign: TextAlign.center,
        style: AppTextStyle.dialogTitle.copyWith(fontSize: 22.sp),
      ),
      child: const GoalDetailBottomSheet(),
    );
  }

  @override
  State<GoalDetailBottomSheet> createState() => _GoalDetailBottomSheetState();
}

class _GoalDetailBottomSheetState extends State<GoalDetailBottomSheet> {
  int selectedTabIndex = 0; // 0: Add money, 1: Take out
  bool isConfirmingDelete = false;
  int enteredAmount = 0;
  String? amountError;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Row: Two buttons "Add money" & "Take out"
        Row(
          children: [
            // Add money button
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  selectedTabIndex = 0;
                  amountError = null;
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.pill,
                    gradient:
                        selectedTabIndex == 0 ? AppGradients.card : null,
                    color: selectedTabIndex == 0 ? null : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Add money',
                    style: AppTextStyle.chip.copyWith(
                      fontSize: 15.sp,
                      fontWeight: selectedTabIndex == 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: selectedTabIndex == 0
                          ? Colors.white
                          : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
            // Take out button
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  selectedTabIndex = 1;
                  amountError = null;
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.pill,
                    gradient:
                        selectedTabIndex == 1 ? AppGradients.card : null,
                    color: selectedTabIndex == 1 ? null : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Take out',
                    style: AppTextStyle.chip.copyWith(
                      fontSize: 15.sp,
                      fontWeight: selectedTabIndex == 1
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: selectedTabIndex == 1
                          ? Colors.white
                          : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        24.verticalSpace,

        // 2. Text: "How much are you putting aside?" / "How much are you taking out?"
        Center(
          child: Text(
            selectedTabIndex == 0
                ? 'How much are you putting aside?'
                : 'How much are you taking out?',
            style: AppTextStyle.subtitle.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
        ),
        8.verticalSpace,

        // 3. Amount text
        Center(
          child: GestureDetector(
            onTap: () async {
              final newAmount = await AmountInputDialog.show(
                context,
                title: selectedTabIndex == 0 ? 'Add to Goal' : 'Take out',
                hint: '0',
                initialValue: enteredAmount,
              );
              if (newAmount != null) {
                setState(() {
                  enteredAmount = newAmount;
                  if (enteredAmount > 0) amountError = null;
                });
              }
            },
            child: Text(
              '₹${AppFormatters.groupDigits(enteredAmount)}',
              style: AppTextStyle.amount.copyWith(
                fontSize: 44.sp,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
        20.verticalSpace,

        // 4. Row: Three containers with tile border radius
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    enteredAmount += 500;
                    amountError = null;
                  });
                },
                child: AppCard(
                  height: 52.h,
                  radius: AppBorderRadius.tile,
                  child: Center(
                    child: Text(
                      '+₹500',
                      style: AppTextStyle.chip.copyWith(fontSize: 15.sp),
                    ),
                  ),
                ),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    enteredAmount += 1000;
                    amountError = null;
                  });
                },
                child: AppCard(
                  height: 52.h,
                  radius: AppBorderRadius.tile,
                  child: Center(
                    child: Text(
                      '+₹1,000',
                      style: AppTextStyle.chip.copyWith(fontSize: 15.sp),
                    ),
                  ),
                ),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    enteredAmount += 2000;
                    amountError = null;
                  });
                },
                child: AppCard(
                  height: 52.h,
                  radius: AppBorderRadius.tile,
                  child: Center(
                    child: Text(
                      '+₹2,000',
                      style: AppTextStyle.chip.copyWith(fontSize: 15.sp),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        20.verticalSpace,

        // 5. Row: "₹50,200 saved of ₹50,000 · Goal reached"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₹50,200 saved of ₹50,000',
              style: AppTextStyle.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              ' · ',
              style: AppTextStyle.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Goal reached',
              style: AppTextStyle.notice,
            ),
          ],
        ),
        24.verticalSpace,

        if (amountError != null) ...[
          Center(
            child: Text(
              amountError!,
              style: AppTextStyle.error.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          8.verticalSpace,
        ],

        // 6. Button: Add to goal / Take out (using AppButton)
        AppButton(
          label: selectedTabIndex == 0 ? 'Add to goal' : 'Take out',
          isCentered: true,
          onPressed: () {
            if (enteredAmount <= 0) {
              setState(() {
                amountError = 'Please select or enter an amount';
              });
              return;
            }

            setState(() => amountError = null);
            AppToast.show(
              context,
              message: selectedTabIndex == 0 ? 'Add to goal' : 'Take out',
            );
            Navigator.of(context).pop();
          },
        ),
        16.verticalSpace,

        // 7. Delete goal (Tap again to confirm)
        Center(
          child: GestureDetector(
            onTap: () {
              if (!isConfirmingDelete) {
                setState(() => isConfirmingDelete = true);
              } else {
                AppToast.show(
                  context,
                  message: 'Goal deleted',
                );
                Navigator.of(context).pop();
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.delete,
                    size: 18.sp,
                    color: AppColors.error,
                  ),
                  6.horizontalSpace,
                  Text(
                    isConfirmingDelete
                        ? 'Tap again to delete this goal'
                        : 'Delete goal',
                    style: AppTextStyle.error.copyWith(
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        8.verticalSpace,
      ],
    );
  }
}
