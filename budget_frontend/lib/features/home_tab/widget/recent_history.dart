import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_link_button.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';
import 'package:budget_frontend/features/history/screen/history_screen.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/history/widgets/history_transaction_card.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class RecentHistory extends StatefulWidget {
  const RecentHistory({
    super.key,
    this.onSeeAll,
  });

  final VoidCallback? onSeeAll;

  @override
  State<RecentHistory> createState() => _RecentHistoryState();
}

class _RecentHistoryState extends State<RecentHistory> {
  List<HistoryTransactionModel>? _recentTransactions;

  @override
  void initState() {
    super.initState();
    _fetchRecent();
  }

  Future<void> _fetchRecent() async {
    try {
      final txs = await context.read<TransactionService>().getTransactions(limit: 5);
      if (mounted) {
        setState(() {
          _recentTransactions = txs.take(5).toList();
        });
      }
    } catch (_) {
      // Keep existing data or fallback to walletState
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = context.watch<WalletBloc>().state;
    final walletRecent = walletState.summary?.recent ?? [];
    final recent = (_recentTransactions ?? walletRecent).take(5).toList();

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        _fetchRecent();
      },
      child: AppCard(
        color: AppColors.surface,
        radius: AppBorderRadius.card,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1st Row: "Recent" spaceBetween AppLinkButton "See all"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent',
                  style: AppTextStyle.cardTitle,
                ),
                AppLinkButton(
                  label: 'See all',
                  onPressed: widget.onSeeAll ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                ),
              ],
            ),
            14.verticalSpace,

            // 2nd: List of recent transactions (max 5) OR empty state
            if (recent.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (context, index) => 10.verticalSpace,
                itemBuilder: (context, index) {
                  return HistoryTransactionCard(
                    transaction: recent[index],
                  );
                },
              )
            else ...[
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Nothing yet. Tap + to log your first spend or income.',
                      style: AppTextStyle.emptyState.copyWith(color: AppColors.faint),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
            ],
          ],
        ),
      ),
    );
  }
}
