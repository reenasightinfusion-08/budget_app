import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/history/widgets/history_grid_view.dart';
import 'package:budget_frontend/features/history/widgets/history_header.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.initialFilterIndex = 0});

  final int initialFilterIndex;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<HistoryTransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  late int _selectedFilterIndex;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      String? type;
      if (_selectedFilterIndex == 1) type = 'expense';
      if (_selectedFilterIndex == 2) type = 'income';

      final txs = await context.read<TransactionService>().getTransactions(
            type: type,
            q: _searchQuery.trim().isNotEmpty ? _searchQuery.trim() : null,
          );

      if (!mounted) return;
      setState(() {
        _transactions = txs;
        _isLoading = false;
        _errorMessage = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load transactions';
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadTransactions();
    });
  }

  void _onFilterChanged(int index) {
    setState(() => _selectedFilterIndex = index);
    _loadTransactions();
  }

  void _onDelete(HistoryTransactionModel tx) async {
    final previousList = List<HistoryTransactionModel>.from(_transactions);
    setState(() {
      _transactions.removeWhere((item) => item.id == tx.id);
    });

    try {
      await context.read<TransactionService>().deleteTransaction(tx.id);
      if (!mounted) return;
      context.read<WalletBloc>().add(const RefreshWalletSummary());
      AppToast.show(
        context,
        message: 'Transaction deleted',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _transactions = previousList;
      });
      AppToast.show(
        context,
        message: 'Failed to delete transaction',
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        _loadTransactions();
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: _loadTransactions,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
              20.w,
              16.h,
              20.w,
              AppLayout.navBarClearanceOf(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top navigation row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: CircleAvatar(
                        radius: 23.r,
                        backgroundColor: AppColors.surface,
                        child: Icon(
                          AppIcons.chevronLeft,
                          color: AppColors.ink,
                          size: 25.sp,
                        ),
                      ),
                    ),
                    15.horizontalSpace,
                    Text(
                      'History',
                      style: AppTextStyle.screenTitle,
                    ),
                  ],
                ),
                16.verticalSpace,

                // Search field & filter buttons
                HistoryHeader(
                  selectedFilterIndex: _selectedFilterIndex,
                  onFilterIndexChanged: _onFilterChanged,
                  onChanged: _onSearchChanged,
                  onClear: () {
                    _searchQuery = '';
                    _loadTransactions();
                  },
                ),
                16.verticalSpace,

                // GridView.builder displaying transaction items or Loading/Error
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),
                  )
                else if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(
                      child: Column(
                        children: [
                          Text(_errorMessage!, style: AppTextStyle.error),
                          8.verticalSpace,
                          TextButton(
                            onPressed: _loadTransactions,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  HistoryGridView(
                    transactions: _transactions,
                    onDelete: _onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
