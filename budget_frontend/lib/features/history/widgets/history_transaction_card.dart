import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';

/// Single transaction card tile matching the history design.
class HistoryTransactionCard extends StatelessWidget {
  const HistoryTransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  final HistoryTransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppCard(
        color: AppColors.surface,
        radius: AppBorderRadius.card,
        padding: isTablet
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            // Circle icon badge
            Container(
              width: isTablet ? 48 : 48.r,
              height: isTablet ? 48 : 48.r,
              decoration: BoxDecoration(
                color: transaction.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction.icon,
                size: isTablet ? 22 : 22.sp,
                color: transaction.effectiveIconColor,
              ),
            ),
            isTablet ? const SizedBox(width: 14) : 14.horizontalSpace,

            // Description & Subtitle ("Food · Oct 11")
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.description,
                    style: AppTextStyle.subCardTitle.copyWith(
                      fontSize: isTablet ? 16 : 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isTablet ? const SizedBox(height: 3) : 3.verticalSpace,
                  Text(
                    transaction.subtitle,
                    style: AppTextStyle.description.copyWith(
                      fontSize: isTablet ? 12.5 : 12.5.sp,
                      color: AppColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            isTablet ? const SizedBox(width: 10) : 10.horizontalSpace,

            // Signed Amount ("-₹1,600")
            Text(
              transaction.signedFormattedAmount,
              style: AppTextStyle.subCardTitle.copyWith(
                fontSize: isTablet ? 16 : 16.sp,
                fontWeight: FontWeight.w700,
                color: transaction.isIncome ? AppColors.success : AppColors.ink,
              ),
            ),

            // Delete icon button (only shown when onDelete callback is provided)
            if (onDelete != null) ...[
              isTablet ? const SizedBox(width: 12) : 12.horizontalSpace,
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: isTablet
                      ? const EdgeInsets.all(4)
                      : EdgeInsets.all(4.r),
                  child: Icon(
                    AppIcons.delete,
                    size: isTablet ? 20 : 20.sp,
                    color: AppColors.faint,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A section group displaying a date header with its total day spend, followed by transaction cards.
class HistoryDateGroup extends StatelessWidget {
  const HistoryDateGroup({
    super.key,
    required this.dateLabel,
    required this.totalAmount,
    required this.transactions,
    this.onDeleteTransaction,
    this.onTapTransaction,
  });

  final String dateLabel;
  final double totalAmount;
  final List<HistoryTransactionModel> transactions;
  final ValueChanged<HistoryTransactionModel>? onDeleteTransaction;
  final ValueChanged<HistoryTransactionModel>? onTapTransaction;

  @override
  Widget build(BuildContext context) {
    final rounded = totalAmount.round();
    final signedTotal = rounded > 0
        ? '-${AppFormatters.rupees(rounded.abs())}'
        : (rounded < 0
              ? '+${AppFormatters.rupees(rounded.abs())}'
              : AppFormatters.rupees(0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateLabel,
                style: AppTextStyle.metricTitle.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              Text(
                signedTotal,
                style: AppTextStyle.metricTitle.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        for (final tx in transactions) ...[
          HistoryTransactionCard(
            transaction: tx,
            onTap: onTapTransaction != null
                ? () => onTapTransaction!(tx)
                : null,
            onDelete: onDeleteTransaction != null
                ? () => onDeleteTransaction!(tx)
                : null,
          ),
          12.verticalSpace,
        ],
      ],
    );
  }
}

/// Takes a list of transactions, groups them by date, and displays the UI matching the design.
class HistoryTransactionList extends StatelessWidget {
  const HistoryTransactionList({
    super.key,
    required this.transactions,
    this.onDelete,
    this.onTap,
  });

  final List<HistoryTransactionModel> transactions;
  final ValueChanged<HistoryTransactionModel>? onDelete;
  final ValueChanged<HistoryTransactionModel>? onTap;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text('No transactions found.', style: AppTextStyle.emptyState),
        ),
      );
    }

    // Group transactions by calendar day
    final Map<String, List<HistoryTransactionModel>> grouped = {};
    for (final tx in transactions) {
      final key = tx.formattedDate;
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          HistoryDateGroup(
            dateLabel: entry.key,
            totalAmount: entry.value.fold<double>(
              0.0,
              (sum, tx) => sum + (tx.isSpend ? tx.amount : -tx.amount),
            ),
            transactions: entry.value,
            onDeleteTransaction: onDelete,
            onTapTransaction: onTap,
          ),
        ],
      ],
    );
  }
}
