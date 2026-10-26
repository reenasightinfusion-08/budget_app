import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';
import 'package:budget_frontend/features/home_tab/widget/smart_add_views.dart';
import 'package:budget_frontend/features/smart_add/services/smart_add_service.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScanBillBottomSheet extends StatefulWidget {
  const ScanBillBottomSheet({super.key});

  /// Opens the Smart Add / Scan Bill bottom sheet.
  static Future<void> show(BuildContext context) async {
    final result = await AppBottomSheet.show<String>(
      context: context,
      title: Text(
        'Smart add',
        textAlign: TextAlign.center,
        style: AppTextStyle.dialogTitle.copyWith(fontSize: 22.sp),
      ),
      child: const ScanBillBottomSheet(),
    );

    if (result == 'manual' && context.mounted) {
      SpendIncomeBottomSheet.show(context);
    }
  }

  @override
  State<ScanBillBottomSheet> createState() => _ScanBillBottomSheetState();
}

class _ScanBillBottomSheetState extends State<ScanBillBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;

  // Processing state for API upload
  double _progressRatio = 0.25;
  String _progressText = 'Initializing api 25%';
  String? _errorMessage;
  String? _createdTransactionId;
  TransactionService? _txService;

  // Review state
  bool _isReviewReady = false;
  bool _isSaving = false;
  String _brandName = 'Bill Receipt';
  late final TextEditingController _amountController;
  String _category = 'Food';
  String _transactionType = 'Spend'; // 'Spend' or 'Income'
  DateTime _entryDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _checkLostData();
  }

  Future<void> _checkLostData() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return;
      final file = response.file;
      if (file != null && mounted) {
        await _processImageWithSmartAdd(file);
      } else if (response.exception != null && mounted) {
        setState(() {
          _errorMessage =
              response.exception!.message ?? 'Error retrieving captured photo';
        });
      }
    } catch (e) {
      debugPrint('Error retrieving lost camera data: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _txService = context.read<TransactionService>();
  }

  @override
  void dispose() {
    if (_createdTransactionId != null) {
      try {
        final txId = _createdTransactionId!;
        _txService?.deleteTransaction(txId);
      } catch (_) {}
    }
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image != null && mounted) {
        await _processImageWithSmartAdd(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processImageWithSmartAdd(XFile image) async {
    setState(() {
      _selectedImage = image;
      _errorMessage = null;
      _isReviewReady = false;
      _progressRatio = 0.25;
      _progressText = 'Reading bill photo 25%';
    });

    try {
      final bytes = await image.readAsBytes();
      if (bytes.length > 3 * 1024 * 1024) {
        throw const ApiException('Photo is too large. Keep it under about 3 MB.');
      }

      if (!mounted) return;
      setState(() {
        _progressRatio = 0.50;
        _progressText = 'Uploading & analyzing receipt 50%';
      });

      final ext = image.name.toLowerCase();
      final mimeType = ext.endsWith('.png')
          ? 'image/png'
          : (ext.endsWith('.webp') ? 'image/webp' : 'image/jpeg');

      final smartAddService = context.read<SmartAddService>();
      final txService = context.read<TransactionService>();

      // Record existing transactions before API call to detect the newly added one
      final beforeTxs = await txService.getTransactions(limit: 50);
      final beforeIds = beforeTxs.map((t) => t.id).toSet();

      // Call API
      await smartAddService.smartAddFile(
        bytes: bytes,
        mimeType: mimeType,
        inputType: 'image',
      );

      if (!mounted) return;
      setState(() {
        _progressRatio = 0.85;
        _progressText = 'Extracting items & verifying total 85%';
      });

      // Fetch transactions after API call
      final afterTxs = await txService.getTransactions(limit: 50);

      // Find the newly added transaction by diffing IDs
      final newCandidates =
          afterTxs.where((t) => !beforeIds.contains(t.id)).toList();
      final newTx = newCandidates.isNotEmpty
          ? (newCandidates
            ..sort((a, b) {
              if (a.createdAt != null && b.createdAt != null) {
                return b.createdAt!.compareTo(a.createdAt!);
              }
              return 0;
            }))
              .first
          : null;

      if (newTx == null) {
        throw const ApiException(
          'No bill amount found in this photo. Please upload a clear receipt or bill.',
        );
      }
      _createdTransactionId = newTx.id;
      _amountController.text =
          newTx.amount.toStringAsFixed(newTx.amount % 1 == 0 ? 0 : 2);
      _brandName = newTx.description.isNotEmpty ? newTx.description : 'Bill Receipt';
      _category = newTx.category;
      _entryDate = newTx.date;
      _transactionType = newTx.isIncome ? 'Income' : 'Spend';

      setState(() {
        _progressRatio = 1.0;
        _progressText = 'Finished 100%';
      });

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _isReviewReady = true;
      });
    } catch (e) {
      debugPrint('Error preparing scan review: $e');
      if (!mounted) return;
      final msg = sanitizeSmartAddError(
        e,
        noAmountFallback:
            'Could not find any bill amount in this photo. Please upload a clear receipt or bill.',
      );
      setState(() {
        _errorMessage = msg;
        _progressRatio = 0.0;
      });
    }
  }

  Future<void> _saveReviewedEntry() async {
    if (_isSaving) return;

    final amountDouble = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amountDouble <= 0) {
      AppToast.show(context, message: 'Please enter a valid amount');
      return;
    }

    setState(() => _isSaving = true);

    final entry = TransactionService.prepareEntry(
      amount: amountDouble,
      transactionType: _transactionType,
      category: _category,
      note: _brandName,
      entryDate: _entryDate,
    );

    try {
      final txService = context.read<TransactionService>();

      // Create the verified transaction first to prevent data loss
      await txService.createTransactionEntry(entry);

      // Clean up the draft/candidate transaction created by OCR
      final oldTxId = _createdTransactionId;
      _createdTransactionId = null;
      if (oldTxId != null) {
        try {
          await txService.deleteTransaction(oldTxId);
        } catch (_) {}
      }

      if (!mounted) return;
      context.read<WalletBloc>().add(const RefreshWalletSummary());
      AppToast.show(context, message: 'Transaction added');
      Navigator.of(context).pop('entry_added');
    } catch (e) {
      if (!mounted) return;
      final err = e is ApiException ? e.message : 'Failed to save entry';
      AppToast.show(context, message: err);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) => AppFormatters.dateSlash(date);

  @override
  Widget build(BuildContext context) {
    // 3. Review / Confirmation State: Uses common SmartAddReviewView
    if (_isReviewReady) {
      final isSpend = _transactionType == 'Spend';
      final availableCats = isSpend
          ? CategoryRegistry.expenses.map((c) => c.label).toList()
          : CategoryRegistry.incomes.map((c) => c.label).toList();

      return SmartAddReviewView(
        brandName: _brandName,
        amountController: _amountController,
        category: _category,
        isSaving: _isSaving,
        categories: availableCats.isNotEmpty ? availableCats : const ['Food', 'Shopping', 'Bills', 'Other'],
        onCategoryChanged: (val) => setState(() => _category = val),
        entryDate: _entryDate,
        onDateChanged: (val) => setState(() => _entryDate = val),
        transactionType: _transactionType,
        onToggleTransactionType: () {
          setState(() {
            _transactionType = _transactionType == 'Spend' ? 'Income' : 'Spend';
          });
        },
        rawReadText:
            'TAX INVOICE\n$_brandName\nDate: ${_formatDate(_entryDate)}\nType: $_transactionType\nAmount: ₹${_amountController.text}',
        onAddEntry: _saveReviewedEntry,
        onBack: () async {
          if (_isSaving) return;
          if (_createdTransactionId != null) {
            try {
              final txService = context.read<TransactionService>();
              await txService.deleteTransaction(_createdTransactionId!);
            } catch (_) {}
            _createdTransactionId = null;
          }
          setState(() {
            _isReviewReady = false;
            _selectedImage = null;
            _errorMessage = null;
            _progressRatio = 0.25;
            _progressText = 'Initializing api 25%';
          });
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedImage == null) ...[
          // 1. Empty / Picker State: Uses common SmartAddPickerCard
          SmartAddPickerCard(
            icon: Icon(
              AppIcons.camera,
              color: Colors.white,
              size: 26.sp,
            ),
            title: 'Snap or upload a bill',
            subtitle: 'Budgie reads the total, store and date for you',
            actionButtons: [
              // Take photo button
              GestureDetector(
                onTap: _isLoading ? null : () => _pickImage(ImageSource.camera),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: AppBorderRadius.dialog,
                  ),
                  child: Text(
                    'Take photo',
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              12.horizontalSpace,

              // Choose image button
              GestureDetector(
                onTap: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppBorderRadius.dialog,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Choose image',
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
            onAddByHand: () {
              Navigator.of(context).pop('manual');
            },
          ),
        ] else ...[
          // 2. Processing / Progress State: Uses common SmartAddProcessingView
          SmartAddProcessingView(
            previewChild: ClipRRect(
              borderRadius: AppBorderRadius.xs,
              child: kIsWeb
                  ? Image.network(
                      _selectedImage!.path,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.contain,
                    ),
            ),
            progressRatio: _progressRatio,
            progressText: _progressText,
            errorMessage: _errorMessage,
            changeButtonLabel: 'Change bill photo',
            onChange: () {
              setState(() {
                _selectedImage = null;
                _errorMessage = null;
                _progressRatio = 0.25;
                _progressText = 'Initializing api 25%';
              });
            },
            onAddByHand: () => Navigator.of(context).pop('manual'),
          ),
        ],
        8.verticalSpace,
      ],
    );
  }
}
