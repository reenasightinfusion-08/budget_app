import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';
import 'package:budget_frontend/features/history/screen/history_screen.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class RecentHistory extends StatefulWidget {
  const RecentHistory({super.key, this.onSeeAll});

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
      final txs = await context.read<TransactionService>().getTransactions(
        limit: 5,
      );
      if (mounted) {
        setState(() {
          _recentTransactions = txs.take(5).toList();
        });
      }
    } catch (_) {
      // Keep existing data or fallback to walletState
    }
  }

  void _navigateToHistory() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.onSeeAll != null) {
      widget.onSeeAll!();
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final count = isTablet ? 4 : 5;
    final walletState = context.watch<WalletBloc>().state;
    final walletRecent = walletState.summary?.recent ?? [];
    final recent = (_recentTransactions ?? walletRecent).take(count).toList();

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        _fetchRecent();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.line.withValues(alpha: 0.9),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.035),
              blurRadius: 12.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 14.w,
          vertical: isTablet ? 16 : 14.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row: Icon badge, "Recent" title (no index badge), and sleek "See all" button (no underline)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: isTablet ? 32 : 32.r,
                      height: isTablet ? 32 : 32.r,
                      decoration: const BoxDecoration(
                        color: AppColors.popSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        AppIcons.history,
                        size: isTablet ? 16 : 16.sp,
                        color: AppColors.accent,
                      ),
                    ),
                    isTablet ? const SizedBox(width: 10) : 9.horizontalSpace,
                    Text(
                      'Recent',
                      style: AppTextStyle.cardTitle.copyWith(
                        fontSize: isTablet ? 17 : 16.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                _SeeAllButton(isTablet: isTablet, onTap: _navigateToHistory),
              ],
            ),
            isTablet ? const SizedBox(height: 12) : 10.verticalSpace,

            // Seamless transaction rows with spacious divider OR Empty State
            if (recent.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: recent.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    left: isTablet ? 54 : 52.w,
                    right: 4.w,
                    top: 2.h,
                    bottom: 2.h,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 0.8,
                    color: AppColors.line.withValues(alpha: 0.7),
                  ),
                ),
                itemBuilder: (context, index) {
                  return _RecentTransactionTile(
                    transaction: recent[index],
                    onTap: _navigateToHistory,
                  );
                },
              )
            else
              _EmptyRecentState(
                isTablet: isTablet,
                onLogTransaction: () =>
                    SpendIncomeBottomSheet.show(context, initialTabIndex: 0),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeeAllButton extends StatefulWidget {
  const _SeeAllButton({required this.onTap, required this.isTablet});

  final VoidCallback onTap;
  final bool isTablet;

  @override
  State<_SeeAllButton> createState() => _SeeAllButtonState();
}

class _SeeAllButtonState extends State<_SeeAllButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 13 : 12.w,
            vertical: widget.isTablet ? 6.5 : 6.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.popSoft,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.pop.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: TextStyle(
                  fontSize: widget.isTablet ? 12.5 : 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  decoration: TextDecoration.none,
                  letterSpacing: -0.2,
                ),
              ),
              4.horizontalSpace,
              Icon(
                AppIcons.chevronRight,
                size: widget.isTablet ? 14 : 14.sp,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTransactionTile extends StatefulWidget {
  const _RecentTransactionTile({
    required this.transaction,
    required this.onTap,
  });

  final HistoryTransactionModel transaction;
  final VoidCallback onTap;

  @override
  State<_RecentTransactionTile> createState() => _RecentTransactionTileState();
}

class _RecentTransactionTileState extends State<_RecentTransactionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);
    final tx = widget.transaction;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 6 : 4.w,
          vertical: isTablet ? 10.5 : 9.5.h,
        ),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.fill.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: isTablet ? 40 : 40.r,
              height: isTablet ? 40 : 40.r,
              decoration: BoxDecoration(
                color: tx.bgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                tx.icon,
                size: isTablet ? 19 : 19.sp,
                color: tx.effectiveIconColor,
              ),
            ),
            isTablet ? const SizedBox(width: 12) : 11.horizontalSpace,

            // Description and Category Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tx.description,
                    style: AppTextStyle.subCardTitle.copyWith(
                      fontSize: isTablet ? 14.5 : 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -0.2,
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 2.5 : 2.h),
                  Text(
                    tx.subtitle,
                    style: AppTextStyle.description.copyWith(
                      fontSize: isTablet ? 11.5 : 11.5.sp,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            isTablet ? const SizedBox(width: 8) : 8.horizontalSpace,

            // Amount and Income/Spend tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tx.signedFormattedAmount,
                  style: AppTextStyle.subCardTitle.copyWith(
                    fontSize: isTablet ? 15 : 15.sp,
                    fontWeight: FontWeight.w700,
                    color: tx.isIncome ? AppColors.success : AppColors.ink,
                    letterSpacing: -0.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: isTablet ? 2 : 1.5.h),
                Text(
                  tx.isIncome ? 'Income' : 'Spend',
                  style: AppTextStyle.description.copyWith(
                    fontSize: isTablet ? 10.5 : 10.5.sp,
                    color: AppColors.faint,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            4.horizontalSpace,
            Icon(
              AppIcons.chevronRight,
              size: isTablet ? 14 : 14.sp,
              color: AppColors.faint.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecentState extends StatelessWidget {
  const _EmptyRecentState({
    required this.isTablet,
    required this.onLogTransaction,
  });

  final bool isTablet;
  final VoidCallback onLogTransaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 14.w,
        vertical: isTablet ? 20 : 18.h,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isTablet ? 48 : 48.r,
            height: isTablet ? 48 : 48.r,
            decoration: const BoxDecoration(
              color: AppColors.popSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              AppIcons.history,
              size: isTablet ? 22 : 22.sp,
              color: AppColors.accent,
            ),
          ),
          10.verticalSpace,
          Text(
            'No recent transactions',
            style: AppTextStyle.subCardTitle.copyWith(
              fontSize: isTablet ? 14.5 : 14.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              decoration: TextDecoration.none,
            ),
          ),
          3.verticalSpace,
          Text(
            'Transactions you log will show up here',
            style: AppTextStyle.description.copyWith(
              fontSize: isTablet ? 12 : 11.5.sp,
              color: AppColors.muted,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
          12.verticalSpace,
          GestureDetector(
            onTap: onLogTransaction,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 14 : 13.w,
                vertical: isTablet ? 7 : 6.5.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.add,
                    size: isTablet ? 15 : 15.sp,
                    color: Colors.white,
                  ),
                  6.horizontalSpace,
                  Text(
                    'Log transaction',
                    style: AppTextStyle.tag.copyWith(
                      color: Colors.white,
                      fontSize: isTablet ? 12 : 11.5.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
