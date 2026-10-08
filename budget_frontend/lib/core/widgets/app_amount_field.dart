import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/indian_digits_formatter.dart';

/// Large rupee input meant to sit on the blue money card.
class AppAmountField extends StatelessWidget {
  const AppAmountField({
    super.key,
    required this.controller,
    required this.validator,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('₹', style: AppTextStyle.amountSymbol),
          6.horizontalSpace,
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              inputFormatters: const [IndianDigitsFormatter()],
              style: AppTextStyle.amount,
              cursorColor: AppColors.onAccent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '30,000',
                hintStyle: AppTextStyle.amountHint,
                errorStyle: AppTextStyle.cardError,
              ),
            ),
          ),
        ],
      );
}
