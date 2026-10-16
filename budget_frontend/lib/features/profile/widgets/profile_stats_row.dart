import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/profile/widgets/data_card.dart';
import 'package:budget_frontend/features/savings/bloc/goal_bloc.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class ProfileStatsRow extends StatefulWidget {
  const ProfileStatsRow({super.key});

  @override
  State<ProfileStatsRow> createState() => _ProfileStatsRowState();
}

class _ProfileStatsRowState extends State<ProfileStatsRow> {
  static int _cachedEntriesCount = 0;
  static int _cachedMonthsCount = 0;

  int _entriesCount = _cachedEntriesCount;
  int _monthsCount = _cachedMonthsCount;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final txService = context.read<TransactionService>();
      final txs = await txService.getTransactions(limit: 100);
      if (!mounted) return;
      final uniqueMonths = txs
          .map((t) => '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}')
          .toSet();

      _cachedEntriesCount = txs.length;
      _cachedMonthsCount = uniqueMonths.length;

      setState(() {
        _entriesCount = txs.length;
        _monthsCount = uniqueMonths.length;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final goalState = context.watch<GoalBloc>().state;
    final goalsCount = goalState.goals.length;

    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        _loadStats();
      },
      child: Row(
        children: [
          DataCard(
            count: '$_entriesCount',
            name: "Entries",
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.history);
            },
          ),
          10.horizontalSpace,
          DataCard(
            count: '$goalsCount',
            name: "Goals",
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.savings,
                arguments: {'showBackButton': true},
              );
            },
          ),
          10.horizontalSpace,
          DataCard(
            count: '$_monthsCount',
            name: "Months",
          ),
        ],
      ),
    );
  }
}
