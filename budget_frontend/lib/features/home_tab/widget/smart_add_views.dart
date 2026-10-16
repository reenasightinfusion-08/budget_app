import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/core/widgets/app_progress_bar.dart';
import 'package:budget_frontend/core/widgets/dashed_border_painter.dart';

class SmartAddPickerCard extends StatelessWidget {
  const SmartAddPickerCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionButtons,
    required this.onAddByHand,
    this.iconBgColor = const Color(0xFF3B6EA5),
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
              borderRadius: BorderRadius.circular(24.r),
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
                  style: GoogleFonts.dmSans(
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
                  style: GoogleFonts.dmSans(
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
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                'Add by hand instead',
                style: GoogleFonts.dmSans(
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
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(22.r),
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
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22.sp),
                10.horizontalSpace,
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: GoogleFonts.dmSans(
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
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    changeButtonLabel,
                    style: GoogleFonts.dmSans(
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
                      backgroundColor: const Color(0xFF3B6EA5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Add by hand',
                      style: GoogleFonts.dmSans(
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
              color: const Color(0xFF3B6EA5),
            ),
          ),
          14.verticalSpace,

          // Progress Text
          Text(
            progressText,
            style: GoogleFonts.dmSans(
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
              style: GoogleFonts.dmSans(
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
              style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B6EA5),
              ),
            ),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
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
          style: GoogleFonts.dmSans(
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
            borderRadius: BorderRadius.circular(20.r),
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
                      color: Color(0xFF3B6EA5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  10.horizontalSpace,

                  // Store / Brand name
                  Expanded(
                    child: Text(
                      widget.brandName,
                      style: GoogleFonts.dmSans(
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
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹',
                          style: GoogleFonts.dmSans(
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
                            style: GoogleFonts.dmSans(
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

              // Row 2: Category dropdown + Date pill + Spend/Income toggle badge
              Row(
                children: [
                  // Category Dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: widget.category,
                        isDense: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.sp,
                          color: AppColors.ink,
                        ),
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                        items: {
                          ...widget.categories,
                          widget.category,
                        }
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) widget.onCategoryChanged(val);
                        },
                      ),
                    ),
                  ),
                  8.horizontalSpace,

                  // Date Pill
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: widget.entryDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          widget.onDateChanged(picked);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatDate(widget.entryDate),
                              style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            6.horizontalSpace,
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14.sp,
                              color: AppColors.ink,
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
                        color: isSpend ? const Color(0xFFE8F0FA) : AppColors.successSoft,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        widget.transactionType,
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isSpend ? const Color(0xFF3B6EA5) : AppColors.success,
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
                _isTextExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                size: 22.sp,
                color: AppColors.muted,
              ),
              4.horizontalSpace,
              Text(
                'Text Budgie read',
                style: GoogleFonts.dmSans(
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
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              widget.rawReadText,
              style: GoogleFonts.dmSans(
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
                  ? const Color(0xFF3B6EA5).withValues(alpha: 0.7)
                  : const Color(0xFF3B6EA5),
              borderRadius: BorderRadius.circular(28.r),
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
                        style: GoogleFonts.dmSans(
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
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: AppColors.line,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Back',
              style: GoogleFonts.dmSans(
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
