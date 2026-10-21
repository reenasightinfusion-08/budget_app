import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/amount_input_dialog.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/savings/bloc/goal_bloc.dart';
import 'package:budget_frontend/features/savings/models/goal_model.dart';
import 'package:budget_frontend/features/savings/services/goal_service.dart';

class GoalDetailBottomSheet extends StatefulWidget {
  const GoalDetailBottomSheet({super.key, required this.goal});

  final GoalModel goal;

  /// Opens the goal detail bottom sheet for [goal].
  static Future<void> show(BuildContext context, {required GoalModel goal}) {
    return AppBottomSheet.show(
      context: context,
      title: Text(
        goal.name,
        textAlign: TextAlign.center,
        style: AppTextStyle.dialogTitle.copyWith(fontSize: 22.sp),
      ),
      child: GoalDetailBottomSheet(goal: goal),
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
  bool _isSaving = false;

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _submitContribution() async {
    if (enteredAmount <= 0) {
      setState(() {
        amountError = 'Please select or enter an amount';
      });
      return;
    }

    if (selectedTabIndex == 1 && enteredAmount > widget.goal.savedAmountRupees) {
      setState(() {
        amountError = 'Cannot take out more than saved (${AppFormatters.rupees(widget.goal.savedAmountRupees)})';
      });
      return;
    }

    setState(() {
      amountError = null;
      _isSaving = true;
    });

    final now = DateTime.now();
    final today = _formatDate(now);
    final amountPaise = (selectedTabIndex == 0 ? enteredAmount : -enteredAmount) * 100;

    try {
      final goalService = context.read<GoalService>();
      await goalService.addContribution(
        goalId: widget.goal.id,
        amountPaise: amountPaise,
        date: today,
        today: today,
      );

      if (!mounted) return;
      context.read<GoalBloc>().add(const LoadGoals());

      AppToast.show(
        context,
        message: selectedTabIndex == 0
            ? '${AppFormatters.rupees(enteredAmount)} added to goal'
            : '${AppFormatters.rupees(enteredAmount)} taken out',
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(context, message: e.message, backgroundColor: AppColors.error);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(context, message: 'Failed to update goal', backgroundColor: AppColors.error);
    }
  }

  Future<void> _deleteGoal() async {
    if (!isConfirmingDelete) {
      setState(() => isConfirmingDelete = true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final goalService = context.read<GoalService>();
      await goalService.deleteGoal(widget.goal.id);

      if (!mounted) return;
      context.read<GoalBloc>().add(const LoadGoals());

      AppToast.show(context, message: 'Goal deleted');
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(context, message: e.message, backgroundColor: AppColors.error);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(context, message: 'Failed to delete goal', backgroundColor: AppColors.error);
    }
  }

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
                    gradient: selectedTabIndex == 0 ? AppGradients.card : null,
                    color: selectedTabIndex == 0 ? null : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Add money',
                    style: AppTextStyle.chip.copyWith(
                      fontSize: 15.sp,
                      fontWeight: selectedTabIndex == 0 ? FontWeight.w700 : FontWeight.w600,
                      color: selectedTabIndex == 0 ? Colors.white : AppColors.ink,
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
                    gradient: selectedTabIndex == 1 ? AppGradients.card : null,
                    color: selectedTabIndex == 1 ? null : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Take out',
                    style: AppTextStyle.chip.copyWith(
                      fontSize: 15.sp,
                      fontWeight: selectedTabIndex == 1 ? FontWeight.w700 : FontWeight.w600,
                      color: selectedTabIndex == 1 ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        24.verticalSpace,

        // 2. Subtitle
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

        // 4. Quick amount chips (+₹500, +₹1,000, +₹2,000)
        Row(
          children: [
            _buildQuickChip('+₹500', 500),
            10.horizontalSpace,
            _buildQuickChip('+₹1,000', 1000),
            10.horizontalSpace,
            _buildQuickChip('+₹2,000', 2000),
          ],
        ),
        20.verticalSpace,

        // 5. Saved of Target progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${AppFormatters.rupees(widget.goal.savedAmountRupees)} saved of ${AppFormatters.rupees(widget.goal.targetAmountRupees)}',
              style: AppTextStyle.body.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.goal.isReached) ...[
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

        // 6. Action button (Add to goal / Take out)
        AppButton(
          label: selectedTabIndex == 0 ? 'Add to goal' : 'Take out',
          isCentered: true,
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _submitContribution,
        ),
        16.verticalSpace,

        // 7. Delete goal
        Center(
          child: GestureDetector(
            onTap: _isSaving ? null : _deleteGoal,
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

  Widget _buildQuickChip(String label, int amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            enteredAmount += amount;
            amountError = null;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 52.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppBorderRadius.tile,
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyle.chip.copyWith(fontSize: 15.sp),
          ),
        ),
      ),
    );
  }
}
