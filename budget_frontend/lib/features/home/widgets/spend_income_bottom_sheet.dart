import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/core/widgets/app_date_picker_dialog.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/categories/bloc/category_bloc.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpendIncomeBottomSheet extends StatefulWidget {
  const SpendIncomeBottomSheet({
    super.key,
    this.selectedTabIndex,
  });

  final ValueNotifier<int>? selectedTabIndex;

  /// Opens the spend and income bottom sheet with the toggle buttons in the title.
  static Future<void> show(BuildContext context, {int initialTabIndex = 0}) {
    final selectedTabIndex = ValueNotifier<int>(initialTabIndex);

    return AppBottomSheet.show(
      context: context,
      title: _SpendIncomeToggle(
        selectedTabIndex: selectedTabIndex,
      ),
      child: SpendIncomeBottomSheet(
        selectedTabIndex: selectedTabIndex,
      ),
    ).whenComplete(() {
      selectedTabIndex.dispose();
    });
  }

  @override
  State<SpendIncomeBottomSheet> createState() => _SpendIncomeBottomSheetState();
}

class _SpendIncomeBottomSheetState extends State<SpendIncomeBottomSheet> {
  String? _selectedSpendCategoryId;
  String? _selectedIncomeCategoryId;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _dateController;
  final FocusNode _amountFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();
  String? _amountError;
  bool _isSaving = false;

  Future<void> _submitTransaction(int selectedIndex) async {
    if (_isSaving) return;
    final amountText = _amountController.text.trim();
    final amount = int.tryParse(amountText) ?? 0;
    if (amountText.isEmpty || amount <= 0) {
      setState(() {
        _amountError = 'Please enter an amount to continue';
      });
      return;
    }

    setState(() {
      _amountError = null;
      _isSaving = true;
    });

    final isIncome = selectedIndex == 1;
    final type = isIncome ? 'income' : 'expense';

    final categoryState = context.read<CategoryBloc>().state;
    String category;
    if (isIncome) {
      category = (_selectedIncomeCategoryId != null && _selectedIncomeCategoryId!.isNotEmpty)
          ? _selectedIncomeCategoryId!
          : (categoryState.incomeCategories.isNotEmpty
              ? categoryState.incomeCategories.first.key
              : 'salary');
    } else {
      category = (_selectedSpendCategoryId != null && _selectedSpendCategoryId!.isNotEmpty)
          ? _selectedSpendCategoryId!
          : (categoryState.expenseCategories.isNotEmpty
              ? categoryState.expenseCategories.first.key
              : 'food');
    }
    final note = _noteController.text.trim();
    final date = AppFormatters.dateForApi(_selectedDate);
    final today = AppFormatters.dateForApi(DateTime.now());

    try {
      final transactionService = context.read<TransactionService>();
      await transactionService.createTransaction(
        type: type,
        amountPaise: amount * 100,
        category: category,
        note: note,
        date: date,
        today: today,
      );

      if (!mounted) return;
      context.read<WalletBloc>().add(const RefreshWalletSummary());
      final formattedAmount = AppFormatters.rupees(amount);
      AppToast.show(
        context,
        message: isIncome
            ? '$formattedAmount Income saved'
            : '$formattedAmount Spend saved',
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        message: e.message,
        backgroundColor: AppColors.error,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppToast.show(
        context,
        message: 'Failed to add transaction. Please try again.',
        backgroundColor: AppColors.error,
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${AppFormatters.monthShort(date.month)} ${date.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await AppDatePickerDialog.show(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5, 1, 1),
      lastDate: today,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
    _amountController.addListener(() {
      setState(() {
        if (_amountError != null && _amountController.text.isNotEmpty) {
          _amountError = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.selectedTabIndex ?? ValueNotifier<int>(0);
    final isTablet = AppLayout.isTablet(context);

    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, selectedIndex, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // 1. Card container with gradient, rupee 0, and question
            GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(_amountFocusNode),
              child: AppCard(
                width: double.infinity,
                padding: isTablet
                    ? const EdgeInsets.symmetric(vertical: 24, horizontal: 24)
                    : EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
                isGradient: true,
                radius: AppBorderRadius.card,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '₹',
                          style: AppTextStyle.amountSymbol.copyWith(
                            fontSize: isTablet ? 28 : 35.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        IntrinsicWidth(
                          child: TextField(
                            cursorHeight: isTablet ? 42 : 55.sp,
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration.collapsed(
                              hintText: '0',
                              hintStyle: AppTextStyle.amount.copyWith(
                                fontSize: isTablet ? 42 : 55.sp,
                                color: AppColors.onAccent.withValues(alpha: 0.4),
                              ),
                            ),
                            style: AppTextStyle.amount.copyWith(
                              fontSize: isTablet ? 42 : 55.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    Text(
                      selectedIndex == 0
                          ? 'How much did you spend?'
                          : 'How much come in?',
                      style: AppTextStyle.subtitle.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            16.verticalSpace,

            // 2. Horizontally scrollable row with categories based on selectedIndex
            Builder(
              builder: (context) {
                final categoryState = context.watch<CategoryBloc>().state;
                final expenseList = categoryState.expenseCategories.isNotEmpty
                    ? categoryState.expenseCategories
                        .map((c) => BudgetCategoryModel.fromCategoryModel(c))
                        .toList()
                    : BudgetCategoryModel.generateInitial(AppConfig.defaultMonthlyBudget);

                final incomeList = categoryState.incomeCategories.isNotEmpty
                    ? categoryState.incomeCategories
                        .map((c) => BudgetCategoryModel.fromCategoryModel(c))
                        .toList()
                    : BudgetCategoryModel.defaultIncomeCategories();

                final currentSpendId = (expenseList.any((c) => c.id == _selectedSpendCategoryId))
                    ? _selectedSpendCategoryId
                    : (expenseList.isNotEmpty ? expenseList.first.id : 'food');

                final currentIncomeId = (incomeList.any((c) => c.id == _selectedIncomeCategoryId))
                    ? _selectedIncomeCategoryId
                    : (incomeList.isNotEmpty ? incomeList.first.id : 'salary');

                return SingleChildScrollView(
                  key: ValueKey<int>(selectedIndex),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: AppLayout.isTablet(context) ? Clip.hardEdge : Clip.none,
                  child: Row(
                    children: [
                      if (selectedIndex == 0) ...[
                        for (int i = 0; i < expenseList.length; i++) ...[
                          if (i > 0) 10.horizontalSpace,
                          _buildCategoryChip(
                            expenseList[i],
                            isSelected: currentSpendId == expenseList[i].id,
                            onTap: () {
                              setState(() {
                                _selectedSpendCategoryId = expenseList[i].id;
                              });
                            },
                          ),
                        ],
                      ] else ...[
                        for (int i = 0; i < incomeList.length; i++) ...[
                          if (i > 0) 10.horizontalSpace,
                          _buildCategoryChip(
                            incomeList[i],
                            isSelected: currentIncomeId == incomeList[i].id,
                            onTap: () {
                              setState(() {
                                _selectedIncomeCategoryId = incomeList[i].id;
                              });
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
            16.verticalSpace,
              AppTextField(
                icon: AppIcons.editNote,
                controller: _noteController,
                hint: 'Add a note (optional)',
                fillColor: AppColors.surface,
                borderRadius: AppBorderRadius.card,
                validator: (_) => null,
              ),
              10.verticalSpace,
              AppTextField(
                icon: AppIcons.calendar,
                controller: _dateController,
                hint: 'Date',
                readOnly: true,
                onTap: _pickDate,
                fillColor: AppColors.surface,
                borderRadius: AppBorderRadius.card,
                validator: (_) => null,
              ),


            8.verticalSpace,

            // 4. Save button with validation
            if (_amountError != null) ...[
              4.verticalSpace,
              Text(
                _amountError!,
                style: AppTextStyle.error.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              4.verticalSpace,
            ],
            8.verticalSpace,
            AppButton(
              isCentered: true,
              label: 'Save',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : () => _submitTransaction(selectedIndex),
            ),
            8.verticalSpace,
          ],
        ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BudgetCategoryModel category, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(6.w, 5.h, 16.w, 5.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.card : null,
          color: isSelected ? null : Colors.white,
          borderRadius: AppBorderRadius.pill,
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : category.color.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Icon(
                category.icon,
                size: 17.sp,
                color: isSelected ? Colors.white : category.color,
              ),
            ),
            8.horizontalSpace,
            Text(
              category.label,
              style: AppTextStyle.chip.copyWith(
                color: isSelected ? Colors.white : AppColors.ink,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendIncomeToggle extends StatelessWidget {
  const _SpendIncomeToggle({
    required this.selectedTabIndex,
  });

  final ValueNotifier<int> selectedTabIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedTabIndex,
      builder: (context, currentIndex, _) {
        return SizedBox(
          width: 210.w,
          child: Row(
            children: [
              // Spend button
              Expanded(
                child: GestureDetector(
                  onTap: () => selectedTabIndex.value = 0,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.pill,
                      gradient: currentIndex == 0 ? AppGradients.card : null,
                      color: currentIndex == 0 ? null : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Spend',
                      style: AppTextStyle.input.copyWith(
                        color: currentIndex == 0
                            ? Colors.white
                            : AppColors.ink,
                        fontWeight: currentIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              // Income button
              Expanded(
                child: GestureDetector(
                  onTap: () => selectedTabIndex.value = 1,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.pill,
                      gradient: currentIndex == 1 ? AppGradients.card : null,
                      color: currentIndex == 1 ? null : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Income',
                      style: AppTextStyle.input.copyWith(
                        color: currentIndex == 1
                            ? Colors.white
                            : AppColors.ink,
                        fontWeight: currentIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
