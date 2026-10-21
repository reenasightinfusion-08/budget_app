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
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_month_year_picker.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/savings/bloc/goal_bloc.dart';
import 'package:budget_frontend/features/savings/services/goal_service.dart';

/// Model holding the data points of a created goal.
class NewGoalData {
  final String title;
  final IconData icon;
  final int amount;
  final DateTime targetDate;

  const NewGoalData({
    required this.title,
    required this.icon,
    required this.amount,
    required this.targetDate,
  });

  @override
  String toString() =>
      'NewGoalData(title: $title, icon: $icon, amount: $amount, targetDate: $targetDate)';
}

class NewGoalBottomSheet extends StatefulWidget {
  const NewGoalBottomSheet({super.key, this.onSubmit});

  final ValueChanged<NewGoalData>? onSubmit;

  /// Opens the new goal bottom sheet.
  static Future<NewGoalData?> show(
    BuildContext context, {
    ValueChanged<NewGoalData>? onSubmit,
  }) {
    return AppBottomSheet.show<NewGoalData>(
      context: context,
      title: Text(
        'New goal',
        textAlign: TextAlign.center,
        style: AppTextStyle.dialogTitle.copyWith(fontSize: 22.sp),
      ),
      child: NewGoalBottomSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<NewGoalBottomSheet> createState() => _NewGoalBottomSheetState();
}

class _NewGoalBottomSheetState extends State<NewGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final DateTime currentMonthYear =
      DateTime(DateTime.now().year, DateTime.now().month);

  String get currentMonthYearText =>
      '${AppFormatters.monthName(currentMonthYear.month)} ${currentMonthYear.year}';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedGoalDate;
  int selectedIconIndex = 2; // Default to 'plane'
  bool _isSaving = false;

  // Icons matching backend enum: ['shield', 'phone', 'plane', 'house', 'gift', 'star']
  static const List<(IconData, String)> goalIcons = [
    (AppIcons.shield, 'shield'),
    (AppIcons.phone, 'phone'),
    (AppIcons.plane, 'plane'),
    (AppIcons.home, 'house'),
    (AppIcons.gift, 'gift'),
    (AppIcons.star, 'star'),
  ];

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _pickMonthYear() async {
    final picked = await AppMonthYearPickerDialog.show(
      context,
      initialDate: selectedGoalDate ?? currentMonthYear,
      selectedDate: selectedGoalDate,
      minDate: currentMonthYear,
      maxDate: DateTime(currentMonthYear.year + 20, 12),
    );

    if (picked != null) {
      setState(() {
        selectedGoalDate = picked;
        dateController.text =
            '${AppFormatters.monthName(picked.month)} ${picked.year}';
      });
      _formKey.currentState?.validate();
    }
  }

  Future<void> _submitForm() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) return;

    if (selectedGoalDate == null) {
      AppToast.show(context, message: 'Please select a target date');
      return;
    }

    setState(() => _isSaving = true);

    final name = nameController.text.trim();
    final iconEntry = goalIcons[selectedIconIndex];
    final amountRupees = AppFormatters.parseDigits(amountController.text);
    final targetMonth =
        '${selectedGoalDate!.year}-${selectedGoalDate!.month.toString().padLeft(2, '0')}';

    try {
      final goalService = context.read<GoalService>();
      await goalService.createGoal(
        name: name,
        icon: iconEntry.$2,
        targetAmountPaise: amountRupees * 100,
        targetMonth: targetMonth,
      );

      if (!mounted) return;
      context.read<GoalBloc>().add(const LoadGoals());

      final goalData = NewGoalData(
        title: name,
        icon: iconEntry.$1,
        amount: amountRupees,
        targetDate: selectedGoalDate!,
      );
      widget.onSubmit?.call(goalData);

      AppToast.show(context, message: 'Goal created');
      Navigator.of(context).pop(goalData);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        message: e.message,
        backgroundColor: AppColors.error,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        message: 'Failed to create goal. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you saving for?',
            style: AppTextStyle.fieldLabel.copyWith(fontSize: 15),
          ),
          6.verticalSpace,
          AppTextField(
            borderRadius: AppBorderRadius.card,
            fillColor: AppColors.surface,
            controller: nameController,
            hint: 'e.g. Goa trip',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter what you are saving for';
              }
              if (value.trim().length > 28) {
                return 'Name must be 28 characters or less';
              }
              return null;
            },
          ),
          14.verticalSpace,
          Text(
            'Pick an icon',
            style: AppTextStyle.fieldLabel.copyWith(fontSize: 15),
          ),
          8.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(goalIcons.length, (index) {
              final isSelected = selectedIconIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIconIndex = index;
                  });
                },
                child: Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected ? AppGradients.card : null,
                    color: isSelected ? null : AppColors.surface,
                  ),
                  child: Icon(
                    goalIcons[index].$1,
                    size: 20.sp,
                    color: isSelected ? AppColors.pop : AppColors.catOther,
                  ),
                ),
              );
            }),
          ),
          14.verticalSpace,
          Text(
            'How much do you need? (₹)',
            style: AppTextStyle.fieldLabel.copyWith(fontSize: 15),
          ),
          6.verticalSpace,
          AppTextField(
            borderRadius: AppBorderRadius.card,
            fillColor: AppColors.surface,
            controller: amountController,
            hint: 'e.g. 20000',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an amount';
              }
              final amount = int.tryParse(value.replaceAll(RegExp(r'\D'), ''));
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          14.verticalSpace,
          Text(
            'By when?',
            style: AppTextStyle.fieldLabel.copyWith(fontSize: 15),
          ),
          6.verticalSpace,
          AppTextField(
            borderRadius: AppBorderRadius.card,
            fillColor: AppColors.surface,
            controller: dateController,
            readOnly: true,
            onTap: _pickMonthYear,
            hint: currentMonthYearText,
            suffixIcon: GestureDetector(
              onTap: _pickMonthYear,
              child: Icon(
                AppIcons.calendar,
                color: AppColors.ink,
                size: 20.sp,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please select a target date';
              }
              return null;
            },
          ),
          45.verticalSpace,
          AppButton(
            label: 'Create goal',
            isCentered: true,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _submitForm,
          ),
        ],
      ),
    );
  }
}

typedef NewGoalSheet = NewGoalBottomSheet;
typedef NewGoalWidget = NewGoalBottomSheet;

