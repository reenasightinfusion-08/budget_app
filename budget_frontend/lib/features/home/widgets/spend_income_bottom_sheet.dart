import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_config.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/features/wallet/models/budget_category_model.dart';
import 'package:date_picker_plus/date_picker_plus.dart';

class SpendIncomeBottomSheet extends StatefulWidget {
  const SpendIncomeBottomSheet({
    super.key,
    this.selectedTabIndex,
  });

  final ValueNotifier<int>? selectedTabIndex;

  /// Income categories list: 1. Salary 2. Side Work 3. Gift 4. Other.
  static final List<BudgetCategoryModel> incomeCategories = [
    BudgetCategoryModel(
      id: 'salary',
      label: 'Salary',
      icon: Icons.payments_rounded,
      color: AppColors.success,
      spent: 0,
      limit: 0,
    ),
    BudgetCategoryModel(
      id: 'side_work',
      label: 'Side Work',
      icon: Icons.work_rounded,
      color: AppColors.catBills,
      spent: 0,
      limit: 0,
    ),
    BudgetCategoryModel(
      id: 'gift',
      label: 'Gift',
      icon: Icons.card_giftcard_rounded,
      color: AppColors.catFun,
      spent: 0,
      limit: 0,
    ),
    BudgetCategoryModel(
      id: 'other',
      label: 'Other',
      icon: Icons.more_horiz_rounded,
      color: AppColors.catOther,
      spent: 0,
      limit: 0,
    ),
  ];

  /// Opens the spend and income bottom sheet with the toggle buttons in the title.
  static Future<void> show(BuildContext context) {
    final selectedTabIndex = ValueNotifier<int>(0);

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
  late final List<BudgetCategoryModel> _categories;
  List<BudgetCategoryModel> get incomeCategories => SpendIncomeBottomSheet.incomeCategories;
  String _selectedSpendCategoryId = 'food';
  String _selectedIncomeCategoryId = 'salary';
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _dateController;
  final FocusNode _amountFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();
  String? _amountError;

  String _formatDate(DateTime date) {
    return '${date.day} ${AppFormatters.monthShort(date.month)} ${date.year}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePickerDialog(
      context: context,
      minDate: DateTime(now.year - 5, 1, 1),
      maxDate: today,
      selectedDate: _selectedDate,
      displayedDate: _selectedDate,
      dialogBackground: AppColors.surface,
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
    _categories = BudgetCategoryModel.generateInitial(AppConfig.defaultMonthlyBudget);
    if (_categories.isNotEmpty) {
      _selectedSpendCategoryId = _categories.first.id;
    }
    if (incomeCategories.isNotEmpty) {
      _selectedIncomeCategoryId = incomeCategories.first.id;
    }
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
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
              decoration: BoxDecoration(
                gradient: AppGradients.card,
                borderRadius: AppBorderRadius.card,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => FocusScope.of(context).requestFocus(_amountFocusNode),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '₹',
                          style: GoogleFonts.outfit(
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.onAccentMuted,
                          ),
                        ),
                        IntrinsicWidth(
                          child: TextField(
                            cursorHeight: 55.sp,
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration.collapsed(
                              hintText: '0',
                              hintStyle: GoogleFonts.outfit(
                                fontSize: 55.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onAccent.withValues(alpha: 0.4),
                              ),
                            ),
                            style: GoogleFonts.outfit(
                              fontSize: 55.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    selectedIndex == 0
                        ? 'How much did you spend?'
                        : 'How much come in?',
                    style: GoogleFonts.dmSans(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onAccentMuted,
                    ),
                  ),
                ],
              ),
            ),
            16.verticalSpace,

            // 2. Horizontally scrollable row with categories based on selectedIndex
            SingleChildScrollView(
              key: ValueKey<int>(selectedIndex),
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  if (selectedIndex == 0) ...[
                    for (int i = 0; i < _categories.length; i++) ...[
                      if (i > 0) 10.horizontalSpace,
                      _buildCategoryChip(
                        _categories[i],
                        isSelected: _selectedSpendCategoryId == _categories[i].id,
                        onTap: () {
                          setState(() {
                            _selectedSpendCategoryId = _categories[i].id;
                          });
                        },
                      ),
                    ],
                  ] else ...[
                    for (int i = 0; i < incomeCategories.length; i++) ...[
                      if (i > 0) 10.horizontalSpace,
                      _buildCategoryChip(
                        incomeCategories[i],
                        isSelected: _selectedIncomeCategoryId == incomeCategories[i].id,
                        onTap: () {
                          setState(() {
                            _selectedIncomeCategoryId = incomeCategories[i].id;
                          });
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
            16.verticalSpace,
              AppTextField(
                icon: Icons.edit_note_rounded,
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
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              4.verticalSpace,
            ],
            8.verticalSpace,
            AppButton(
              isCentered: true,
              label: 'Save',
              onPressed: _amountController.text.trim().isEmpty
                  ? () {
                      setState(() => _amountError = 'Please enter an amount to continue');
                    }
                  : () {
                      // TODO: handle save
                    },
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
                category.id == 'food'
                    ? Icons.soup_kitchen_rounded
                    : category.icon,
                size: 17.sp,
                color: isSelected ? Colors.white : category.color,
              ),
            ),
            8.horizontalSpace,
            Text(
              category.label,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.ink,
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
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: currentIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: currentIndex == 0
                            ? Colors.white
                            : AppColors.ink,
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
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: currentIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: currentIndex == 1
                            ? Colors.white
                            : AppColors.ink,
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
