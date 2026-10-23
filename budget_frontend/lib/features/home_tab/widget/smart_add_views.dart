import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/core/widgets/app_category_picker_dialog.dart';
import 'package:budget_frontend/core/widgets/app_date_picker_dialog.dart';
import 'package:budget_frontend/core/widgets/app_progress_bar.dart';
import 'package:budget_frontend/core/widgets/dashed_border_painter.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';

class SmartAddPickerCard extends StatelessWidget {
  const SmartAddPickerCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionButtons,
    required this.onAddByHand,
    this.iconBgColor = AppColors.accent,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final List<Widget> actionButtons;
  final VoidCallback onAddByHand;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomPaint(
          painter: DashedBorderPainter(
            color: AppColors.faint,
            radius: AppBorderRadius.dialog.topLeft,
            strokeWidth: 1.0,
            dashWidth: 4.0,
            dashGap: 3.0,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 26.h),
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.dialog,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon circle badge
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBgColor,
                  ),
                  alignment: Alignment.center,
                  child: icon,
                ),
                16.verticalSpace,

                // Title
                Text(
                  title,
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                6.verticalSpace,

                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
                20.verticalSpace,

                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: actionButtons,
                ),
              ],
            ),
          ),
        ),
        24.verticalSpace,

        // Bottom "Add by hand instead" button
        GestureDetector(
          onTap: onAddByHand,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppBorderRadius.dialog,
              border: Border.all(
                color: AppColors.line,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                'Add by hand instead',
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 2. Processing / Progress UI: Preview card, progress bar, progress text, disclaimer note & change action
class SmartAddProcessingView extends StatelessWidget {
  const SmartAddProcessingView({
    super.key,
    required this.previewChild,
    required this.progressRatio,
    required this.progressText,
    this.noteText = "The first scan downloads the reader once (about 15 MB),\nthen it's quick.",
    this.changeButtonLabel = 'Change bill photo',
    required this.onChange,
    this.errorMessage,
    this.onAddByHand,
  });

  final Widget previewChild;
  final double progressRatio;
  final String progressText;
  final String noteText;
  final String changeButtonLabel;
  final VoidCallback onChange;
  final String? errorMessage;
  final VoidCallback? onAddByHand;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Centered receipt / file preview card
        Container(
          width: 130.w,
          height: 135.h,
          decoration: BoxDecoration(
            color: AppColors.fill,
            borderRadius: AppBorderRadius.tile,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(12.r),
          alignment: Alignment.center,
          child: previewChild,
        ),
        20.verticalSpace,

        if (errorMessage != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: AppBorderRadius.dialogInput,
              border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(AppIcons.error, color: AppColors.error, size: 22.sp),
                10.horizontalSpace,
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          20.verticalSpace,
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onChange,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: AppColors.fill,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.chip,
                    ),
                  ),
                  child: Text(
                    changeButtonLabel,
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              if (onAddByHand != null) ...[
                10.horizontalSpace,
                Expanded(
                  child: TextButton(
                    onPressed: onAddByHand,
                    style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.chip,
                    ),
                  ),
                    child: Text(
                      'Add by hand',
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ] else ...[
          // Progress Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: AppProgressBar(
              ratio: progressRatio,
              height: 6,
              color: AppColors.accent,
            ),
          ),
          14.verticalSpace,

          // Progress Text
          Text(
            progressText,
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          18.verticalSpace,

          // Note
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              noteText,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: AppColors.faint,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          16.verticalSpace,

          // Change button
          TextButton(
            onPressed: onChange,
            child: Text(
              changeButtonLabel,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Model for an entry in multi-item smart add review
class SmartAddReviewItem {
  final String id;
  String title;
  final TextEditingController amountController;
  String category;
  DateTime date;
  String transactionType; // 'Spend' or 'Income'
  bool isSelected;

  SmartAddReviewItem({
    this.id = '',
    required this.title,
    required this.amountController,
    required this.category,
    required this.date,
    this.transactionType = 'Spend',
    this.isSelected = true,
  });
}

/// Multi-item Review / Confirmation UI: displays multiple cards when multiple
/// entries/categories are detected (e.g. "lunch 250 and Uber 120").
class SmartAddMultiReviewView extends StatefulWidget {
  const SmartAddMultiReviewView({
    super.key,
    required this.items,
    required this.rawReadText,
    required this.onSave,
    required this.onBack,
    this.isSaving = false,
    this.categories = const [
      'Food',
      'Travel',
      'Shopping',
      'Bills',
      'Health',
      'Income',
      'Other',
    ],
  });

  final List<SmartAddReviewItem> items;
  final String rawReadText;
  final VoidCallback onSave;
  final VoidCallback onBack;
  final bool isSaving;
  final List<String> categories;

  @override
  State<SmartAddMultiReviewView> createState() => _SmartAddMultiReviewViewState();
}

class _SmartAddMultiReviewViewState extends State<SmartAddMultiReviewView> {
  bool _isTextExpanded = false;

  String _formatDate(DateTime date) => AppFormatters.dateSlash(date);

  Future<void> _showCategoryPicker(
      BuildContext context, SmartAddReviewItem item) async {
    final selected = await AppCategoryPickerDialog.show(
      context: context,
      currentCategory: item.category,
      transactionType: item.transactionType,
      categories: widget.categories,
    );

    if (selected != null && mounted) {
      setState(() {
        item.category = selected;
      });
    }
  }

  Widget _buildItemCard(SmartAddReviewItem item) {
    final isSpend = item.transactionType == 'Spend';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: item.isSelected ? 1.0 : 0.45,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorderRadius.md,
          border: Border.all(
            color: item.isSelected
                ? AppColors.line.withValues(alpha: 0.9)
                : AppColors.line.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Check icon (toggleable) + Brand name + Editable Amount box
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      item.isSelected = !item.isSelected;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      color: item.isSelected ? AppColors.accent : AppColors.fill,
                      shape: BoxShape.circle,
                      border: item.isSelected
                          ? null
                          : Border.all(color: AppColors.line),
                    ),
                    child: Icon(
                      AppIcons.check,
                      size: 16.sp,
                      color: item.isSelected ? Colors.white : AppColors.muted,
                    ),
                  ),
                ),
                10.horizontalSpace,

                // Title
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Amount container with ₹ symbol and editable TextField
                Container(
                  width: 105.w,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    borderRadius: AppBorderRadius.chip,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      6.horizontalSpace,
                      Expanded(
                        child: TextField(
                          controller: item.amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            14.verticalSpace,

            // Row 2: Category Picker Pill + Date Pill + Spend/Income toggle badge
            Row(
              children: [
                // Category Picker Pill
                GestureDetector(
                  onTap: () => _showCategoryPicker(context, item),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      borderRadius: AppBorderRadius.chip,
                      border: Border.all(
                        color: AppColors.line.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CategoryRegistry.getIcon(
                            item.category,
                            isSpend ? 'expense' : 'income',
                          ),
                          size: 16.sp,
                          color: CategoryRegistry.getColor(
                            item.category,
                            isSpend ? 'expense' : 'income',
                            !isSpend,
                          ),
                        ),
                        6.horizontalSpace,
                        Text(
                          item.category,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        4.horizontalSpace,
                        Icon(
                          AppIcons.arrowDown,
                          size: 15.sp,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
                8.horizontalSpace,

                // Date Pill
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await AppDatePickerDialog.show(
                        context: context,
                        initialDate: item.date,
                        firstDate: DateTime(now.year - 5, 1, 1),
                        lastDate: DateTime(now.year + 1, 12, 31),
                      );
                      if (picked != null) {
                        setState(() {
                          item.date = picked;
                        });
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.fill,
                        borderRadius: AppBorderRadius.chip,
                        border: Border.all(
                          color: AppColors.line.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDate(item.date),
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          6.horizontalSpace,
                          Icon(
                            AppIcons.calendar,
                            size: 14.sp,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                8.horizontalSpace,

                // Type badge: "Spend" / "Income" toggle loop
                GestureDetector(
                  onTap: () {
                    setState(() {
                      item.transactionType =
                          item.transactionType == 'Spend' ? 'Income' : 'Spend';
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSpend ? AppColors.popSoft : AppColors.successSoft,
                      borderRadius: AppBorderRadius.chip,
                    ),
                    child: Text(
                      item.transactionType,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: isSpend ? AppColors.accent : AppColors.success,
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

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.items.where((i) => i.isSelected).length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Subtitle
        Text(
          'Budgie read this. Check it, then save.',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.muted,
          ),
        ),
        16.verticalSpace,

        // List of recognized entry cards
        ...widget.items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildItemCard(item),
            )),

        4.verticalSpace,

        // Expandable: "▶ Text Budgie read"
        GestureDetector(
          onTap: () {
            setState(() {
              _isTextExpanded = !_isTextExpanded;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                _isTextExpanded
                    ? AppIcons.arrowDropDown
                    : AppIcons.chevronRight,
                size: 22.sp,
                color: AppColors.muted,
              ),
              4.horizontalSpace,
              Text(
                'Text Budgie read',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),

        if (_isTextExpanded) ...[
          8.verticalSpace,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: AppBorderRadius.xs,
            ),
            child: Text(
              widget.rawReadText,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12.sp,
                height: 1.4,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
        24.verticalSpace,

        // Primary Button: "Add X entries •" -> closes bottom sheet
        GestureDetector(
          onTap: (widget.isSaving || selectedCount == 0) ? null : widget.onSave,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52.h,
            decoration: BoxDecoration(
              color: (widget.isSaving || selectedCount == 0)
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : AppColors.accent,
              borderRadius: AppBorderRadius.button,
            ),
            child: widget.isSaving
                ? Center(
                    child: SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedCount == 1
                            ? 'Add 1 entry'
                            : 'Add $selectedCount entries',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      8.horizontalSpace,
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        12.verticalSpace,

        // Secondary Button: "Back" -> returns to previous state
        GestureDetector(
          onTap: widget.isSaving ? null : widget.onBack,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.button,
              border: Border.all(
                color: AppColors.line,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Back',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: widget.isSaving ? AppColors.muted : AppColors.ink,
              ),
            ),
          ),
        ),
        8.verticalSpace,
      ],
    );
  }
}

/// 3. Review / Confirmation UI: Editable card, category, date, spend/income toggle, expandable raw text & buttons
class SmartAddReviewView extends StatefulWidget {
  const SmartAddReviewView({
    super.key,
    required this.brandName,
    required this.amountController,
    required this.category,
    required this.onCategoryChanged,
    required this.entryDate,
    required this.onDateChanged,
    required this.transactionType,
    required this.onToggleTransactionType,
    required this.rawReadText,
    required this.onAddEntry,
    required this.onBack,
    this.isSaving = false,
    this.categories = const [
      'Food',
      'Travel',
      'Shopping',
      'Bills',
      'Health',
      'Income',
      'Other',
    ],
  });

  final String brandName;
  final TextEditingController amountController;
  final String category;
  final ValueChanged<String> onCategoryChanged;
  final DateTime entryDate;
  final ValueChanged<DateTime> onDateChanged;
  final String transactionType; // 'Spend' or 'Income'
  final VoidCallback onToggleTransactionType;
  final String rawReadText;
  final VoidCallback onAddEntry;
  final VoidCallback onBack;
  final bool isSaving;
  final List<String> categories;

  @override
  State<SmartAddReviewView> createState() => _SmartAddReviewViewState();
}

class _SmartAddReviewViewState extends State<SmartAddReviewView> {
  bool _isTextExpanded = false;

  String _formatDate(DateTime date) => AppFormatters.dateSlash(date);

  Future<void> _showCategoryPicker(BuildContext context) async {
    final selected = await AppCategoryPickerDialog.show(
      context: context,
      currentCategory: widget.category,
      transactionType: widget.transactionType,
      categories: widget.categories,
    );

    if (selected != null && mounted) {
      widget.onCategoryChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpend = widget.transactionType == 'Spend';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Subtitle: "Budgie read this. Check it, then save."
        Text(
          'Budgie read this. Check it, then save.',
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.muted,
          ),
        ),
        16.verticalSpace,

        // Main White Card containing the recognized entry
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorderRadius.md,
            border: Border.all(
              color: AppColors.line.withValues(alpha: 0.9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Check icon + Brand name + Editable Amount box
              Row(
                children: [
                  Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.check,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  10.horizontalSpace,

                  // Store / Brand name
                  Expanded(
                    child: Text(
                      widget.brandName,
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Amount container with ₹ symbol and editable TextField
                  Container(
                    width: 105.w,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.fill,
                      borderRadius: AppBorderRadius.chip,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹',
                          style: TextStyle(fontFamily: 'DMSans', 
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        6.horizontalSpace,
                        Expanded(
                          child: TextField(
                            controller: widget.amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            style: TextStyle(fontFamily: 'DMSans', 
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.verticalSpace,

              // Row 2: Category Picker Pill + Date Pill + Spend/Income toggle badge
              Row(
                children: [
                  // Category Picker Pill
                  GestureDetector(
                    onTap: () => _showCategoryPicker(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.fill,
                        borderRadius: AppBorderRadius.chip,
                        border: Border.all(
                          color: AppColors.line.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CategoryRegistry.getIcon(
                              widget.category,
                              isSpend ? 'expense' : 'income',
                            ),
                            size: 16.sp,
                            color: CategoryRegistry.getColor(
                              widget.category,
                              isSpend ? 'expense' : 'income',
                              !isSpend,
                            ),
                          ),
                          6.horizontalSpace,
                          Text(
                            widget.category,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          4.horizontalSpace,
                          Icon(
                            AppIcons.arrowDown,
                            size: 15.sp,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  8.horizontalSpace,

                  // Date Pill
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await AppDatePickerDialog.show(
                          context: context,
                          initialDate: widget.entryDate,
                          firstDate: DateTime(now.year - 5, 1, 1),
                          lastDate: DateTime(now.year + 1, 12, 31),
                        );
                        if (picked != null) {
                          widget.onDateChanged(picked);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.fill,
                          borderRadius: AppBorderRadius.chip,
                          border: Border.all(
                            color: AppColors.line.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatDate(widget.entryDate),
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            6.horizontalSpace,
                            Icon(
                              AppIcons.calendar,
                              size: 14.sp,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  8.horizontalSpace,

                  // Type badge: "Spend" / "Income" toggle loop
                  GestureDetector(
                    onTap: widget.onToggleTransactionType,
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSpend ? AppColors.popSoft : AppColors.successSoft,
                        borderRadius: AppBorderRadius.chip,
                      ),
                      child: Text(
                        widget.transactionType,
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isSpend ? AppColors.accent : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        16.verticalSpace,

        // Expandable: "▶ Text Budgie read"
        GestureDetector(
          onTap: () {
            setState(() {
              _isTextExpanded = !_isTextExpanded;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                _isTextExpanded ? AppIcons.arrowDropDown : AppIcons.chevronRight,
                size: 22.sp,
                color: AppColors.muted,
              ),
              4.horizontalSpace,
              Text(
                'Text Budgie read',
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),

        if (_isTextExpanded) ...[
          8.verticalSpace,
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: AppBorderRadius.xs,
            ),
            child: Text(
              widget.rawReadText,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: 12.sp,
                height: 1.4,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
        24.verticalSpace,

        // Primary Button: "Add 1 entry •" -> closes bottom sheet
        GestureDetector(
          onTap: widget.isSaving ? null : widget.onAddEntry,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52.h,
            decoration: BoxDecoration(
              color: widget.isSaving
                  ? AppColors.accent.withValues(alpha: 0.7)
                  : AppColors.accent,
              borderRadius: AppBorderRadius.button,
            ),
            child: widget.isSaving
                ? Center(
                    child: SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add 1 entry',
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      8.horizontalSpace,
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        12.verticalSpace,

        // Secondary Button: "Back" -> returns to previous state
        GestureDetector(
          onTap: widget.isSaving ? null : widget.onBack,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.button,
              border: Border.all(
                color: AppColors.line,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Back',
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: widget.isSaving ? AppColors.muted : AppColors.ink,
              ),
            ),
          ),
        ),
        8.verticalSpace,
      ],
    );
  }
}

/// Sanitizes backend / AI provider errors into clean, human-friendly messages
/// without exposing stack traces, internal URLs (e.g. vercel.app), or status codes.
String sanitizeSmartAddError(Object error, {required String noAmountFallback}) {
  if (error is ApiException) {
    final status = error.statusCode;
    final rawMsg = error.message.toLowerCase();

    // 1. Rate limit / Daily limit
    if (status == 429 || rawMsg.contains('daily') || rawMsg.contains('limit reached')) {
      return 'Daily Smart add limit reached. Please try again tomorrow or add by hand.';
    }

    // 2. File too large
    if (status == 413 ||
        rawMsg.contains('too large') ||
        rawMsg.contains('3 mb') ||
        rawMsg.contains('4 mb')) {
      return 'File is too large. Please select a file under 3 MB.';
    }

    // 3. No amount found
    if (status == 422 ||
        rawMsg.contains('could not find any amount') ||
        rawMsg.contains('no bill amount')) {
      return noAmountFallback;
    }

    // 4. AI Provider / Vercel / 500 / 502 / 503 / GoogleGenerativeAI Error
    if (status == 500 ||
        status == 502 ||
        status == 503 ||
        rawMsg.contains('503') ||
        rawMsg.contains('500') ||
        rawMsg.contains('502') ||
        rawMsg.contains('ai-hub') ||
        rawMsg.contains('generative') ||
        rawMsg.contains('google') ||
        rawMsg.contains('vercel') ||
        rawMsg.contains('http') ||
        rawMsg.contains('service')) {
      return 'The AI reader is temporarily busy. Please try again in a moment or add by hand.';
    }

    // If message is clean and doesn't contain URLs or technical error traces
    if (!rawMsg.contains('http') &&
        !rawMsg.contains('.app') &&
        !rawMsg.contains('error:') &&
        !rawMsg.contains('syntax') &&
        !rawMsg.contains('exception')) {
      return error.message;
    }
  }

  // Network connection error
  final errStr = error.toString().toLowerCase();
  if (errStr.contains('socket') ||
      errStr.contains('network') ||
      errStr.contains('connection') ||
      errStr.contains('failed host lookup')) {
    return 'Network connection error. Please check your internet connection.';
  }

  return 'The AI reader is temporarily busy. Please try again in a moment or add by hand.';
}
