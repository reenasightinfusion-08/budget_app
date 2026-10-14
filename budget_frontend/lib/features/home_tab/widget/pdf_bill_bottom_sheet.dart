import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';
import 'package:budget_frontend/features/home_tab/widget/smart_add_views.dart';

/// Lightweight model representing a selected PDF file
class SelectedPdfData {
  final String name;
  final int sizeInBytes;
  final String? path;

  SelectedPdfData({
    required this.name,
    required this.sizeInBytes,
    this.path,
  });
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

  // Simulation state for API processing
  double _progressRatio = 0.25;
  String _progressText = 'Initializing api 25%';
  Timer? _simulationTimer;

  // Review state after 100% completion
  bool _isReviewReady = false;
  final String _itemName = 'Items Purchased';
  late final TextEditingController _amountController;
  String _category = 'Shopping';
  String _transactionType = 'Spend'; // 'Spend' or 'Income'
  DateTime _entryDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '1444.9');
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _startProgressSimulation() {
    _simulationTimer?.cancel();
    setState(() {
      _isReviewReady = false;
      _progressRatio = 0.25;
      _progressText = 'Initializing api 25%';
    });

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_progressRatio < 0.50) {
          _progressRatio = 0.50;
          _progressText = 'Reading PDF document 50%';
        } else if (_progressRatio < 0.75) {
          _progressRatio = 0.75;
          _progressText = 'Extracting line items & total 75%';
        } else if (_progressRatio < 1.0) {
          _progressRatio = 1.0;
          _progressText = 'Finished 100%';
          timer.cancel();

          // Smoothly transition to the review card upon 100% completion
          Future.delayed(const Duration(milliseconds: 450), () {
            if (mounted) {
              setState(() {
                _isReviewReady = true;
              });
            }
          });
        } else {
          timer.cancel();
        }
      });
    });
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
        debugPrint('Custom PDF filter failed: $customErr, falling back to any type');
        try {
          file = await FilePicker.pickFile(type: FileType.any);
        } catch (anyErr) {
          debugPrint('File picker general fallback failed: $anyErr');
          rethrow;
        }
      }

      if (file != null && mounted) {
        final pickedFile = file;
        setState(() {
          _selectedPdf = SelectedPdfData(
            name: pickedFile.name,
            sizeInBytes: pickedFile.lengthSync() ?? 102400,
            path: pickedFile.path,
          );
        });
        _startProgressSimulation();
      }
    } on MissingPluginException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFD2513F),
            content: Text(
              'Please restart the app (press Stop ⏹ then Run ▶ in Android Studio) to enable the native file picker on your phone.',
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

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // 3. Review State: Matches screenshot 2
    if (_isReviewReady) {
      return SmartAddReviewView(
        brandName: _itemName,
        amountController: _amountController,
        category: _category,
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
            'STATEMENT OF ACCOUNTS\nDescription: $_itemName\nDate: ${_formatDate(_entryDate)}\nCategory: $_category\nAmount: ₹${_amountController.text}\nPayment: Online Debit\nStatus: Cleared',
        onAddEntry: () {
          Navigator.of(context).pop('entry_added');
        },
        onBack: () {
          setState(() {
            _isReviewReady = false;
            _selectedPdf = null;
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
            icon: Icon(
              Icons.article_outlined,
              color: Colors.white,
              size: 26.sp,
            ),
            title: 'Upload a bill or statement PDF',
            subtitle:
                'Budgie reads invoices and bank statements, even scanned ones',
            actionButtons: [
              // Choose PDF button
              GestureDetector(
                onTap: _isLoading ? null : _pickPdf,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B6EA5),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(
                    'Choose PDF',
                    style: GoogleFonts.dmSans(
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
                    color: const Color(0xFFD9534F).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: const Color(0xFFD9534F),
                    size: 25.sp,
                  ),
                ),
                10.verticalSpace,
                Text(
                  _selectedPdf!.name,
                  style: GoogleFonts.dmSans(
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
                  style: GoogleFonts.dmSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            progressRatio: _progressRatio,
            progressText: _progressText,
            changeButtonLabel: 'Change PDF file',
            onChange: () {
              _simulationTimer?.cancel();
              setState(() {
                _selectedPdf = null;
                _progressRatio = 0.25;
                _progressText = 'Initializing api 25%';
              });
            },
          ),
        ],
        8.verticalSpace,
      ],
    );
  }
}
