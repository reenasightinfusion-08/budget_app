import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';
import 'package:budget_frontend/features/history/widgets/history_transaction_card.dart';

/// Displays a list of transactions using [GridView.builder].
class HistoryGridView extends StatelessWidget {
  const HistoryGridView({
    super.key,
    required this.transactions,
    this.onDelete,
    this.onTap,
    this.crossAxisCount = 1,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
  });

  final List<HistoryTransactionModel> transactions;
  final ValueChanged<HistoryTransactionModel>? onDelete;
  final ValueChanged<HistoryTransactionModel>? onTap;
  final int crossAxisCount;
  final ScrollPhysics physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    if (transactions.isEmpty) {
      return Padding(
        padding: isTablet
            ? const EdgeInsets.symmetric(vertical: 40)
            : EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text('No transactions found.', style: AppTextStyle.emptyState),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: transactions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: isTablet ? 14 : 12.h,
        crossAxisSpacing: isTablet ? 14 : 12.w,
        mainAxisExtent: isTablet ? 78 : 78.h,
      ),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return HistoryTransactionCard(
          transaction: tx,
          onTap: onTap != null ? () => onTap!(tx) : null,
          onDelete: onDelete != null ? () => onDelete!(tx) : null,
        );
      },
    );
  }
}
