import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

/// A custom, compact Month & Year picker dialog matching the app design system.
///
/// Features:
/// - Compact month row spacing (no stretched/excessive empty vertical gaps)
/// - Disables past months (greyed out and unclickable)
/// - Disables the previous year navigation button when viewing the minimum/current year
/// - Highlights selected month with [AppColors.accent]
class AppMonthYearPickerDialog extends StatefulWidget {
  const AppMonthYearPickerDialog({
    super.key,
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    this.selectedDate,
  });

  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;
  final DateTime? selectedDate;

  /// Shows the Month & Year picker dialog and returns the selected [DateTime] (month & year).
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    DateTime? selectedDate,
  }) {
    final now = DateTime.now();
    return showDialog<DateTime>(
      context: context,
      builder: (_) => AppMonthYearPickerDialog(
        initialDate: initialDate ?? selectedDate ?? now,
        minDate: minDate ?? DateTime(now.year, now.month),
        maxDate: maxDate ?? DateTime(now.year + 20, 12),
        selectedDate: selectedDate ?? initialDate,
      ),
    );
  }

  @override
  State<AppMonthYearPickerDialog> createState() =>
      _AppMonthYearPickerDialogState();
}

class _AppMonthYearPickerDialogState extends State<AppMonthYearPickerDialog> {
  late int _displayedYear;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _displayedYear = widget.initialDate.year;
    if (_displayedYear < widget.minDate.year) {
      _displayedYear = widget.minDate.year;
    } else if (_displayedYear > widget.maxDate.year) {
      _displayedYear = widget.maxDate.year;
    }
    _selectedDate = widget.selectedDate;
  }

  void _previousYear() {
    if (_displayedYear > widget.minDate.year) {
      setState(() => _displayedYear--);
    }
  }

  void _nextYear() {
    if (_displayedYear < widget.maxDate.year) {
      setState(() => _displayedYear++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = _displayedYear > widget.minDate.year;
    final bool canGoNext = _displayedYear < widget.maxDate.year;

    final minMonthDate = DateTime(widget.minDate.year, widget.minDate.month);
    final maxMonthDate = DateTime(widget.maxDate.year, widget.maxDate.month);

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: 325.w,
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.xl,
          boxShadow: [
            BoxShadow(
              color: AppColors.sheetShadow.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Displayed Year with Prev & Next Arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_displayedYear',
                  style: AppTextStyle.cardTitle,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Previous Year Button (Disabled if viewing current/minimum year)
                    InkWell(
                      onTap: canGoPrevious ? _previousYear : null,
                      borderRadius: AppBorderRadius.md,
                      child: Container(
                        width: 34.r,
                        height: 34.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: canGoPrevious
                              ? AppColors.fill
                              : AppColors.fill.withValues(alpha: 0.4),
                        ),
                        child: Icon(
                          AppIcons.arrowBack,
                          size: 14.sp,
                          color: canGoPrevious
                              ? AppColors.ink
                              : AppColors.faint.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    8.horizontalSpace,
                    // Next Year Button
                    InkWell(
                      onTap: canGoNext ? _nextYear : null,
                      borderRadius: AppBorderRadius.md,
                      child: Container(
                        width: 34.r,
                        height: 34.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: canGoNext
                              ? AppColors.fill
                              : AppColors.fill.withValues(alpha: 0.4),
                        ),
                        child: Icon(
                          AppIcons.arrowForward,
                          size: 14.sp,
                          color: canGoNext
                              ? AppColors.ink
                              : AppColors.faint.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            14.verticalSpace,
            // Month Grid: 3 columns x 4 rows with compact row spacing
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.h, // reduced space between rows
                crossAxisSpacing: 10.w,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                final monthDate = DateTime(_displayedYear, month);

                final bool isPast = monthDate.isBefore(minMonthDate);
                final bool isFuture = monthDate.isAfter(maxMonthDate);
                final bool isDisabled = isPast || isFuture;

                final bool isSelected = _selectedDate != null &&
                    _selectedDate!.year == _displayedYear &&
                    _selectedDate!.month == month;

                final String label = AppFormatters.monthShort(month);

                if (isDisabled) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.xs,
                    ),
                    child: Text(
                      label,
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.faint.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return Material(
                  color: isSelected ? AppColors.accent : AppColors.fill,
                  borderRadius: AppBorderRadius.xs,
                  child: InkWell(
                    borderRadius: AppBorderRadius.xs,
                    onTap: () {
                      final selected = DateTime(_displayedYear, month);
                      setState(() => _selectedDate = selected);
                      Navigator.of(context).pop(selected);
                    },
                    child: Center(
                      child: Text(
                        label,
                        style: AppTextStyle.chip.copyWith(
                          color: isSelected ? Colors.white : AppColors.ink,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
