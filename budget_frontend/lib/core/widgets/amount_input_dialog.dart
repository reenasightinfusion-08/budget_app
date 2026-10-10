import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';

/// Rupee amount prompt. Pops the entered amount, or null if cancelled or left without digits.
class AmountInputDialog extends StatefulWidget {
  const AmountInputDialog({
    super.key,
    required this.title,
    required this.hint,
    required this.initialValue,
    this.fontSize = 20,
  });

  final String title;
  final String hint;
  final int initialValue;
  final double fontSize;

  static Future<int?> show(
    BuildContext context, {
    required String title,
    required String hint,
    required int initialValue,
    double fontSize = 20,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) => AmountInputDialog(
        title: title,
        hint: hint,
        initialValue: initialValue,
        fontSize: fontSize,
      ),
    );
  }

  @override
  State<AmountInputDialog> createState() => AmountInputDialogState();
}

class AmountInputDialogState extends State<AmountInputDialog> {
  late final TextEditingController controller = TextEditingController(
    text: widget.initialValue.toString(),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    final text = controller.text;
    Navigator.of(context).pop(text.contains(RegExp(r'\d')) ? AppFormatters.parseDigits(text) : null);
  }

  @override
  Widget build(BuildContext context) {
    final inputStyle = GoogleFonts.outfit(
      fontSize: widget.fontSize.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    );

    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      title: Text(widget.title, style: AppTextStyle.dialogTitle),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: inputStyle,
        decoration: InputDecoration(
          prefixText: '₹ ',
          prefixStyle: inputStyle.copyWith(color: AppColors.muted),
          filled: true,
          fillColor: AppColors.fill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          hintText: widget.hint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: AppColors.muted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
          ),
          onPressed: save,
          child: Text(
            'Save',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
