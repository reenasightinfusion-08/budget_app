import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

/// Lightweight model representing a selected PDF file
class SelectedPdfData {
  final String name;
  final int sizeInBytes;
  final String? path;

  SelectedPdfData({required this.name, required this.sizeInBytes, this.path});
}

class PdfBillBottomSheet extends StatefulWidget {
  const PdfBillBottomSheet({super.key});

  /// Opens the Smart Add / PDF Bill bottom sheet.
  static Future<void> show(BuildContext context) async {
    final result = await AppBottomSheet.show<String>(
      context: context,
      title: Text(
        'Smart add',
        textAlign: TextAlign.center,
        style: AppTextStyle.dialogTitle.copyWith(fontSize: 22.sp),
      ),
      child: const PdfBillBottomSheet(),
    );

    if (result == 'manual' && context.mounted) {
      SpendIncomeBottomSheet.show(context);
    }
  }

  @override
  State<PdfBillBottomSheet> createState() => _PdfBillBottomSheetState();
}

class _PdfBillBottomSheetState extends State<PdfBillBottomSheet> {
  SelectedPdfData? _selectedPdf;
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
  String _itemName = 'PDF Invoice';
  late final TextEditingController _amountController;
  String _category = 'Shopping';
  String _transactionType = 'Spend'; // 'Spend' or 'Income'
  DateTime _entryDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
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

  Future<void> _processPdfWithSmartAdd(PlatformFile file) async {
    int fileSize = file.lengthSync() ?? (await file.length()) ?? 1024;

    setState(() {
      _selectedPdf = SelectedPdfData(
        name: file.name,
        sizeInBytes: fileSize > 0 ? fileSize : 1024,
        path: file.path,
      );
      _errorMessage = null;
      _isReviewReady = false;
      _progressRatio = 0.25;
      _progressText = 'Reading PDF document 25%';
    });

    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const ApiException(
          'Could not read the PDF file. Please try again.',
        );
      }
      if (bytes.length > 3 * 1024 * 1024) {
        throw const ApiException('PDF is too large. Keep it under about 3 MB.');
      }

      if (!mounted) return;
      setState(() {
        _progressRatio = 0.50;
        _progressText = 'Uploading & analyzing statement 50%';
      });

      final smartAddService = context.read<SmartAddService>();
      final txService = context.read<TransactionService>();

      // Record existing transactions before API call to detect the newly added one
      final beforeTxs = await txService.getTransactions(limit: 50);
      final beforeIds = beforeTxs.map((t) => t.id).toSet();

      // Call API
      await smartAddService.smartAddFile(
        bytes: bytes,
        mimeType: 'application/pdf',
        inputType: 'pdf',
      );

      if (!mounted) return;
      setState(() {
        _progressRatio = 0.85;
        _progressText = 'Extracting invoice details 85%';
      });

      // Fetch transactions after API call
      final afterTxs = await txService.getTransactions(limit: 50);

      // Find the newly added transaction by diffing IDs
      final newCandidates = afterTxs
          .where((t) => !beforeIds.contains(t.id))
          .toList();
      final newTx = newCandidates.isNotEmpty
          ? (newCandidates..sort((a, b) {
                  if (a.createdAt != null && b.createdAt != null) {
                    return b.createdAt!.compareTo(a.createdAt!);
                  }
                  return 0;
                }))
                .first
          : null;

      if (newTx == null) {
        throw const ApiException(
          'No bill amount found in this PDF. Please upload a clear invoice or bill.',
        );
      }
      _createdTransactionId = newTx.id;
      _amountController.text = newTx.amount.toStringAsFixed(
        newTx.amount % 1 == 0 ? 0 : 2,
      );
      _itemName = newTx.description.isNotEmpty
          ? newTx.description
          : 'PDF Invoice';
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
      debugPrint('Error preparing PDF review: $e');
      if (!mounted) return;
      final msg = sanitizeSmartAddError(
        e,
        noAmountFallback:
            'Could not find any bill amount in this PDF. Please upload a clear invoice or bill.',
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
      note: _itemName,
      entryDate: _entryDate,
      defaultExpenseKey: 'shopping',
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

  Future<void> _pickPdf() async {
    setState(() => _isLoading = true);
    try {
      PlatformFile? file;
      try {
        file = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
      } catch (customErr) {
        debugPrint(
          'Custom PDF filter failed: $customErr, falling back to any type',
        );
        try {
          file = await FilePicker.pickFile(type: FileType.any);
        } catch (anyErr) {
          debugPrint('File picker general fallback failed: $anyErr');
          rethrow;
        }
      }

      if (file != null && mounted) {
        await _processPdfWithSmartAdd(file);
      }
    } on MissingPluginException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Please restart the app to enable the native file picker on your phone.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file picker: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) => AppFormatters.dateSlash(date);

  @override
  Widget build(BuildContext context) {
    // 3. Review State: Matches shared SmartAddReviewView
    if (_isReviewReady) {
      final isSpend = _transactionType == 'Spend';
      final availableCats = isSpend
          ? CategoryRegistry.expenses.map((c) => c.label).toList()
          : CategoryRegistry.incomes.map((c) => c.label).toList();

      return SmartAddReviewView(
        brandName: _itemName,
        amountController: _amountController,
        category: _category,
        isSaving: _isSaving,
        categories: availableCats.isNotEmpty
            ? availableCats
            : const ['Shopping', 'Bills', 'Food', 'Other'],
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
            'STATEMENT OF ACCOUNTS\nDescription: $_itemName\nDate: ${_formatDate(_entryDate)}\nCategory: $_category\nAmount: ₹${_amountController.text}\nType: $_transactionType',
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
            _selectedPdf = null;
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
        if (_selectedPdf == null) ...[
          // 1. Empty / Picker State: Matches screenshot 1
          SmartAddPickerCard(
            icon: Icon(AppIcons.article, color: Colors.white, size: 26.sp),
            title: 'Upload a bill or statement PDF',
            subtitle:
                'Budgie reads invoices and bank statements, even scanned ones',
            actionButtons: [
              // Choose PDF button
              GestureDetector(
                onTap: _isLoading ? null : _pickPdf,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: AppBorderRadius.dialog,
                  ),
                  child: Text(
                    'Choose PDF',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
          // 2. Processing State: Uses common SmartAddProcessingView with PDF Document Card
          SmartAddProcessingView(
            previewChild: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: AppBorderRadius.chip,
                  ),
                  child: Icon(
                    AppIcons.pdf,
                    color: AppColors.error,
                    size: 25.sp,
                  ),
                ),
                10.verticalSpace,
                Text(
                  _selectedPdf!.name,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                4.verticalSpace,
                Text(
                  '${(_selectedPdf!.sizeInBytes / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            progressRatio: _progressRatio,
            progressText: _progressText,
            errorMessage: _errorMessage,
            changeButtonLabel: 'Change PDF file',
            onChange: () {
              setState(() {
                _selectedPdf = null;
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
