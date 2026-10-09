import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/setup/widgets/setup_quick_amount_chip.dart';

class SetupQuickAmounts extends StatelessWidget {
  const SetupQuickAmounts({super.key, required this.onSelected});

  static const List<int> amounts = [15000, 30000, 50000, 75000];

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => BlocBuilder<SetupBloc, SetupState>(
        builder: (context, state) => Row(
          spacing: 8.w,
          children: [
            for (final amount in amounts)
              Expanded(
                child: SetupQuickAmountChip(
                  label: AppFormatters.rupees(amount),
                  isSelected: amount == state.budgetAmount,
                  onPressed: () => onSelected(amount),
                ),
              ),
          ],
        ),
      );
}
