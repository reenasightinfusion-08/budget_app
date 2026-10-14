import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';
import 'package:budget_frontend/features/home_tab/widget/smart_add_views.dart';

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

  // Simulation state for API processing
  double _progressRatio = 0.25;
  String _progressText = 'Initializing api 25%';
  Timer? _simulationTimer;

  // Review state after 100% completion
  bool _isReviewReady = false;
  final String _brandName = '& Brand Name';
  late final TextEditingController _amountController;
  String _category = 'Other';
  String _transactionType = 'Spend'; // 'Spend' or 'Income' loop
  DateTime _entryDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '220');
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
          _progressText = 'Uploading bill 50%';
        } else if (_progressRatio < 0.75) {
          _progressRatio = 0.75;
          _progressText = 'Analyzing items & totals 75%';
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

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });
        _startProgressSimulation();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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
    // 3. Review / Confirmation State: Uses common SmartAddReviewView
    if (_isReviewReady) {
      return SmartAddReviewView(
        brandName: _brandName,
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
            'TAX INVOICE\nBrand Name Retail Ltd.\nDate: ${_formatDate(_entryDate)}\nItems: 1x Groceries & Supplies\nType: $_transactionType\nSubtotal: ₹${_amountController.text}\nTax: ₹0.00\nTotal: ₹${_amountController.text}',
        onAddEntry: () {
          AppToast.show(
            context,
            message: 'expenced saved',
          );
          Navigator.of(context).pop('entry_added');
        },
        onBack: () {
          setState(() {
            _isReviewReady = false;
            _selectedImage = null;
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
              Icons.camera_alt_outlined,
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
                    color: const Color(0xFF3B6EA5),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Text(
                    'Take photo',
                    style: GoogleFonts.dmSans(
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
                    borderRadius: BorderRadius.circular(24.r),
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
                    style: GoogleFonts.dmSans(
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
              borderRadius: BorderRadius.circular(12.r),
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
            changeButtonLabel: 'Change bill photo',
            onChange: () {
              _simulationTimer?.cancel();
              setState(() {
                _selectedImage = null;
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
