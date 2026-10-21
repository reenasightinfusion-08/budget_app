import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

enum _PickerView { date, month, year }

class AppDatePickerDialog extends StatefulWidget {
  const AppDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.accentColor = AppColors.popDeep,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color accentColor;

  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    Color accentColor = AppColors.popDeep,
  }) {
    return showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        accentColor: accentColor,
      ),
    );
  }

  @override
  State<AppDatePickerDialog> createState() => _AppDatePickerDialogState();
}

class _AppDatePickerDialogState extends State<AppDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  _PickerView _currentView = _PickerView.date;

  static const List<String> _weekdays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  double _calculateContentHeight() {
    final availableWidth = 285.w;
    final cellWidth = (availableWidth - (6 * 3.w)) / 7;
    final cellHeight = cellWidth / 1.15;
    // Matches the height of: Weekday Row (18.h) + Spacing (8.h) + 6 Grid Rows + Bottom Spacing (6.h)
    return 18.h + 8.h + (6 * cellHeight + 5 * 3.h) + 6.h;
  }

  Widget _buildCalendarBadge() {
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Container(
        width: 50.h,
        height: 50.h,
        decoration: BoxDecoration(
          color: widget.accentColor,
          borderRadius: AppBorderRadius.chip,
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Top ring 1
            Positioned(
              top: -4.h,
              left: 12.w,
              child: Container(
                width: 5.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: AppColors.popDeep,
                  borderRadius: AppBorderRadius.bar,
                ),
              ),
            ),
            // Top ring 2
            Positioned(
              top: -4.h,
              right: 12.w,
              child: Container(
                width: 5.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: AppColors.popDeep,
                  borderRadius: AppBorderRadius.bar,
                ),
              ),
            ),
            // Day number text
            Text(
              _twoDigits(_selectedDate.day),
              style: AppTextStyle.title.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.onAccent,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    return SizedBox(
      height: _calculateContentHeight(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1.85,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final m = index + 1;
          final isSelected = _displayedMonth.month == m;

          // Condition supporting past months (spend/income) and future months (goal bottom sheet)
          final monthStart = DateTime(_displayedMonth.year, m, 1);
          final monthEnd = DateTime(_displayedMonth.year, m + 1, 0, 23, 59, 59);
          final bool isPast = monthEnd.isBefore(widget.firstDate);
          final bool isFuture = monthStart.isAfter(widget.lastDate);
          final bool isDisabled = isPast || isFuture;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                      setState(() {
                        _displayedMonth = DateTime(_displayedMonth.year, m, 1);
                        _currentView = _PickerView.date;
                      });
                    },
              borderRadius: AppBorderRadius.chip,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.accentColor
                      : (isDisabled
                          ? AppColors.fill.withValues(alpha: 0.4)
                          : AppColors.fill),
                  borderRadius: AppBorderRadius.chip,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  AppFormatters.monthName(m),
                  style: AppTextStyle.dayLabelActive.copyWith(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? AppColors.onAccent
                        : (isDisabled
                            ? AppColors.faint.withValues(alpha: 0.4)
                            : AppColors.ink),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearGrid() {
    final startYear = widget.firstDate.year;
    final endYear = widget.lastDate.year;
    final minYear = startYear <= endYear ? startYear : endYear;
    final maxYear = startYear <= endYear ? endYear : startYear;
    final yearCount = (maxYear - minYear + 1).clamp(1, 100);

    return SizedBox(
      height: _calculateContentHeight(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1.85,
        ),
        itemCount: yearCount,
        itemBuilder: (context, index) {
          final year = minYear + index;
          final isSelected = _displayedMonth.year == year;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _displayedMonth = DateTime(year, _displayedMonth.month, 1);
                  _currentView = _PickerView.date;
                });
              },
              borderRadius: AppBorderRadius.chip,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? widget.accentColor : AppColors.fill,
                  borderRadius: AppBorderRadius.chip,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$year',
                  style: AppTextStyle.dayLabelActive.copyWith(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.onAccent : AppColors.ink,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysInCurrentMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final daysInPrevMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      0,
    ).day;

    // Sunday = 0, Monday = 1, ..., Saturday = 6
    final firstWeekday = _displayedMonth.weekday % 7;
    final totalDaysCovered = firstWeekday + daysInCurrentMonth;
    final weeksCount = (totalDaysCovered / 7).ceil();
    final totalGridCells = weeksCount * 7;

    return Dialog(
      backgroundColor: Colors.transparent,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Section: Title & Interactive Selector Pills (Left) + Calendar Graphic (Right)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date',
                        style: AppTextStyle.dialogTitle.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      10.verticalSpace,
                      Row(
                        children: [
                          // Month Selector Pill
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _currentView =
                                      _currentView == _PickerView.month
                                          ? _PickerView.date
                                          : _PickerView.month;
                                });
                              },
                              borderRadius: AppBorderRadius.track,
                              child: Container(
                                height: 32.h,
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                decoration: BoxDecoration(
                                  color: _currentView == _PickerView.month
                                      ? widget.accentColor.withValues(
                                          alpha: 0.15,
                                        )
                                      : AppColors.fill,
                                  borderRadius: AppBorderRadius.track,
                                  border: _currentView == _PickerView.month
                                      ? Border.all(
                                          color: widget.accentColor,
                                          width: 1.2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppFormatters.monthName(
                                        _displayedMonth.month,
                                      ),
                                      style: AppTextStyle.dayLabelActive
                                          .copyWith(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _currentView ==
                                                        _PickerView.month
                                                    ? widget.accentColor
                                                    : AppColors.ink,
                                          ),
                                    ),
                                    4.horizontalSpace,
                                    Icon(
                                      _currentView == _PickerView.month
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color:
                                          _currentView == _PickerView.month
                                              ? widget.accentColor
                                              : AppColors.ink,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          8.horizontalSpace,

                          // Year Selector Pill
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _currentView =
                                      _currentView == _PickerView.year
                                          ? _PickerView.date
                                          : _PickerView.year;
                                });
                              },
                              borderRadius: AppBorderRadius.track,
                              child: Container(
                                height: 32.h,
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                decoration: BoxDecoration(
                                  color: _currentView == _PickerView.year
                                      ? widget.accentColor.withValues(
                                          alpha: 0.15,
                                        )
                                      : AppColors.fill,
                                  borderRadius: AppBorderRadius.track,
                                  border: _currentView == _PickerView.year
                                      ? Border.all(
                                          color: widget.accentColor,
                                          width: 1.2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_displayedMonth.year}',
                                      style: AppTextStyle.dayLabelActive
                                          .copyWith(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _currentView == _PickerView.year
                                                    ? widget.accentColor
                                                    : AppColors.ink,
                                          ),
                                    ),
                                    4.horizontalSpace,
                                    Icon(
                                      _currentView == _PickerView.year
                                          ? Icons.arrow_drop_up
                                          : Icons.arrow_drop_down,
                                      color:
                                          _currentView == _PickerView.year
                                              ? widget.accentColor
                                              : AppColors.ink,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                12.horizontalSpace,
                _buildCalendarBadge(),
              ],
            ),
            18.verticalSpace,

            // 2. Main Middle Section: Date Grid OR In-Dialog Month/Year 3x4 Grid
            if (_currentView == _PickerView.date) ...[
              // Weekday Row
              Row(
                children: _weekdays.map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTextStyle.tag.copyWith(
                          color: AppColors.ink,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              8.verticalSpace,

              // Compact 7-column Calendar Grid
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 3.h,
                  crossAxisSpacing: 3.w,
                  childAspectRatio: 1.15,
                ),
                itemCount: totalGridCells,
                itemBuilder: (context, index) {
                  // Previous month days
                  if (index < firstWeekday) {
                    final prevDayNumber =
                        daysInPrevMonth - firstWeekday + index + 1;
                    return Center(
                      child: Text(
                        _twoDigits(prevDayNumber),
                        style: AppTextStyle.dayLabel.copyWith(
                          color: AppColors.faint.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }

                  // Next month days
                  if (index >= totalDaysCovered) {
                    final nextDayNumber = index - totalDaysCovered + 1;
                    return Center(
                      child: Text(
                        _twoDigits(nextDayNumber),
                        style: AppTextStyle.dayLabel.copyWith(
                          color: AppColors.faint.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }

                  // Current month days
                  final dayNumber = index - firstWeekday + 1;
                  final cellDate = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month,
                    dayNumber,
                  );

                  final isSelected = _isSameDay(cellDate, _selectedDate);
                  final isTodayDate = _isSameDay(cellDate, today);
                  final isDisabled = cellDate.isAfter(widget.lastDate) ||
                      cellDate.isBefore(widget.firstDate);

                  Color textColor;
                  if (isDisabled) {
                    textColor = AppColors.faint.withValues(alpha: 0.4);
                  } else if (isSelected) {
                    textColor = AppColors.onAccent;
                  } else {
                    textColor = AppColors.ink;
                  }

                  return InkWell(
                    onTap: isDisabled
                        ? null
                        : () {
                            setState(() {
                              _selectedDate = cellDate;
                            });
                          },
                    borderRadius: AppBorderRadius.dayCell,
                    child: Container(
                      decoration: isSelected
                          ? BoxDecoration(
                              color: widget.accentColor,
                              borderRadius: AppBorderRadius.dayCell,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      widget.accentColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            )
                          : null,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _twoDigits(dayNumber),
                            style: AppTextStyle.dayLabelActive.copyWith(
                              fontWeight: (isSelected || isTodayDate)
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          if (isTodayDate && !isSelected) ...[
                            1.verticalSpace,
                            Container(
                              width: 14.w,
                              height: 2.h,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                borderRadius: AppBorderRadius.indicator,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Spacing between calendar grid and action buttons:
              // When month has 6 weeks: tight/no extra space between last date row and buttons.
              // Otherwise: space is added with the exact height that one date row occupies.
              Builder(
                builder: (context) {
                  if (weeksCount >= 6) {
                    return 6.verticalSpace;
                  }
                  final availableWidth = 285.w;
                  final cellWidth = (availableWidth - (6 * 3.w)) / 7;
                  final cellHeight = cellWidth / 1.15;
                  final oneRowHeight = cellHeight + 3.h;
                  final extraSpace = (6 - weeksCount) * oneRowHeight;
                  return SizedBox(height: 6.h + extraSpace);
                },
              ),
            ] else if (_currentView == _PickerView.month) ...[
              _buildMonthGrid(),
            ] else ...[
              _buildYearGrid(),
            ],

            // 3. Action Buttons (Cancel & Confirm)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 35.h,
                  child: TextButton(
                    onPressed: () {
                      if (_currentView != _PickerView.date) {
                        setState(() => _currentView = _PickerView.date);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.buttonAction.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.faint,
                      ),
                    ),
                  ),
                ),
                10.horizontalSpace,
                SizedBox(
                  width: 95.w,
                  height: 35.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedDate),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      backgroundColor: widget.accentColor,
                      foregroundColor: AppColors.onAccent,
                      elevation: 2,
                      shadowColor: widget.accentColor.withValues(alpha: 0.45),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.chip,
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: AppTextStyle.buttonAction.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.onAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
