import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/history/models/history_transaction_model.dart';
import 'package:budget_frontend/features/history/widgets/history_grid_view.dart';
import 'package:budget_frontend/features/history/widgets/history_header.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.initialFilterIndex = 0});

  final int initialFilterIndex;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<HistoryTransactionModel> _transactions =
      List.from(HistoryTransactionModel.dummyData);
  String _searchQuery = '';
  late int _selectedFilterIndex;

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
  }

  List<HistoryTransactionModel> get _filteredTransactions {
    return _transactions.where((tx) {
      // 1. Filter by transaction type
      if (_selectedFilterIndex == 1 && !tx.isSpend) return false;
      if (_selectedFilterIndex == 2 && !tx.isIncome) return false;

      // 2. Filter by search query
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final matchesDesc = tx.description.toLowerCase().contains(query);
        final matchesCat = tx.category.toLowerCase().contains(query);
        final matchesAmt = tx.amount.toString().contains(query);
        if (!matchesDesc && !matchesCat && !matchesAmt) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                onFilterIndexChanged: (index) {
                  setState(() => _selectedFilterIndex = index);
                },
                onChanged: (query) {
                  setState(() => _searchQuery = query);
                },
                onClear: () {
                  setState(() => _searchQuery = '');
                },
              ),
              16.verticalSpace,

              // GridView.builder displaying transaction items
              HistoryGridView(
                transactions: _filteredTransactions,
                onDelete: (tx) {
                  setState(() {
                    _transactions.removeWhere((item) => item.id == tx.id);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
