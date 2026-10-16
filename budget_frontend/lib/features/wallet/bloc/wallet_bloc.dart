import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/categories/models/category_model.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';
import 'package:budget_frontend/features/categories/services/category_service.dart';
import 'package:budget_frontend/features/history/models/month_summary_model.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/setup/services/profile_service.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_event.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_state.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';

export 'package:budget_frontend/features/wallet/bloc/wallet_event.dart';
export 'package:budget_frontend/features/wallet/bloc/wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({
    required this.profileService,
    required this.transactionService,
    this.categoryService,
    int initialBudget = AppConfig.defaultMonthlyBudget,
  }) : super(WalletState(
          monthlyBudget: initialBudget,
          categories: BudgetCategoryModel.generateInitial(initialBudget),
        )) {
    on<LoadWallet>(_onLoadWallet);
    on<RefreshWalletSummary>(_onRefreshWalletSummary);
    on<WalletUserSynced>(_onWalletUserSynced);
    on<UpdateMonthlyBudget>(_onUpdateMonthlyBudget);
    on<UpdateCategoryLimit>(_onUpdateCategoryLimit);
    on<ApplyWalletEasyFix>(_onApplyWalletEasyFix);
  }

  final ProfileService profileService;
  final TransactionService transactionService;
  final CategoryService? categoryService;
  List<CategoryModel>? _cachedCategories;

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    UserModel? user;
    MonthSummaryModel? summary;
    List<CategoryModel>? liveCategories;

    try {
      user = await profileService.getProfile();
    } catch (e) {
      debugPrint('LoadWallet profile error: $e');
    }

    try {
      summary = await transactionService.getTransactionSummary();
    } catch (e) {
      debugPrint('LoadWallet summary error: $e');
    }

    if (categoryService != null) {
      try {
        liveCategories = await categoryService!.getCategories();
        _cachedCategories = liveCategories;
      } catch (e) {
        debugPrint('LoadWallet categories error: $e');
      }
    }

    if (user != null || summary != null || liveCategories != null) {
      _syncData(
        user: user,
        summary: summary,
        liveCategories: liveCategories,
        emit: emit,
      );
    } else {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load wallet'));
    }
  }

  Future<void> _onRefreshWalletSummary(
    RefreshWalletSummary event,
    Emitter<WalletState> emit,
  ) async {
    try {
      final summary = await transactionService.getTransactionSummary(
        month: event.month,
        today: event.today,
      );
      _syncData(summary: summary, emit: emit);
    } catch (e) {
      debugPrint('RefreshWalletSummary error: $e');
    }
  }

  void _onWalletUserSynced(
    WalletUserSynced event,
    Emitter<WalletState> emit,
  ) {
    _syncData(user: event.user, emit: emit);
  }

  void _syncData({
    UserModel? user,
    MonthSummaryModel? summary,
    List<CategoryModel>? liveCategories,
    required Emitter<WalletState> emit,
  }) {
    if (liveCategories != null) {
      _cachedCategories = liveCategories;
      CategoryRegistry.setCategories(liveCategories);
    }
    final effectiveCategories = liveCategories ??
        _cachedCategories ??
        (CategoryRegistry.all.isNotEmpty ? CategoryRegistry.all : null);
    final effectiveSummary = summary ?? state.summary;
    final budgetRupees = (user != null && user.monthlyBudget > 0)
        ? (user.monthlyBudget ~/ 100)
        : state.monthlyBudget;

    final categoryLimits = user?.categoryLimits;

    var categories = BudgetCategoryModel.generateInitial(
      budgetRupees,
      categoryLimits,
      effectiveCategories,
    );

    if (effectiveSummary != null) {
      final spendMap = effectiveSummary.expenseByCategoryMap;
      categories = categories.map((c) {
        return BudgetCategoryModel(
          id: c.id,
          label: c.label,
          icon: c.icon,
          color: c.color,
          spent: spendMap[c.id] ?? 0,
          limit: c.limit,
        );
      }).toList();
    }

    emit(state.copyWith(
      monthlyBudget: budgetRupees,
      categories: categories,
      summary: effectiveSummary,
      isLoading: false,
      isInitialized: true,
    ));
  }

  Future<void> _onUpdateMonthlyBudget(
    UpdateMonthlyBudget event,
    Emitter<WalletState> emit,
  ) async {
    if (event.monthlyBudget <= 0) return;

    // Optimistic UI update
    final updatedCategories = BudgetCategoryModel.generateInitial(
      event.monthlyBudget,
      null,
      _cachedCategories,
    );
    if (state.summary != null) {
      final spendMap = state.summary!.expenseByCategoryMap;
      for (final c in updatedCategories) {
        c.spent = spendMap[c.id] ?? 0;
      }
    }
    emit(state.copyWith(
      monthlyBudget: event.monthlyBudget,
      categories: updatedCategories,
    ));

    // Save to API
    try {
      await profileService.updateMonthlyBudget(event.monthlyBudget * 100);
    } catch (e) {
      debugPrint('UpdateMonthlyBudget API error: $e');
    }
  }

  Future<void> _onUpdateCategoryLimit(
    UpdateCategoryLimit event,
    Emitter<WalletState> emit,
  ) async {
    final updated = state.categories.map((c) {
      if (c.id == event.categoryId) {
        c.limit = event.newLimit;
      }
      return c;
    }).toList();
    emit(state.copyWith(categories: updated));

    // Save all category limits to API in paise
    final limitsPaise = {
      for (final c in state.categories) c.id: c.limit * 100,
    };
    try {
      await profileService.updateCategoryLimits(limitsPaise);
    } catch (e) {
      debugPrint('UpdateCategoryLimit API error: $e');
    }
  }

  Future<void> _onApplyWalletEasyFix(
    ApplyWalletEasyFix event,
    Emitter<WalletState> emit,
  ) async {
    event.fix.from.limit -= event.fix.amount;
    event.fix.to.limit += event.fix.amount;
    emit(state.copyWith(categories: List.of(state.categories)));

    final limitsPaise = {
      for (final c in state.categories) c.id: c.limit * 100,
    };
    try {
      await profileService.updateCategoryLimits(limitsPaise);
    } catch (e) {
      debugPrint('ApplyWalletEasyFix API error: $e');
    }
  }
}

