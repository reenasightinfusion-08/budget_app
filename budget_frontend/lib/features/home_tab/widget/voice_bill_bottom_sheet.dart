import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';
import 'package:budget_frontend/features/home_tab/widget/smart_add_views.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceBillBottomSheet extends StatefulWidget {
  const VoiceBillBottomSheet({super.key});

  /// Opens the Smart Add / Voice & Type bottom sheet.
  static Future<void> show(BuildContext context) async {
    final result = await AppBottomSheet.show<String>(
      context: context,
      title: Text(
        'Smart add',
        textAlign: TextAlign.center,
        style: AppTextStyle.dialogTitle.copyWith(fontSize: 22.sp),
      ),
      child: const VoiceBillBottomSheet(),
    );

    if (result == 'manual' && context.mounted) {
      SpendIncomeBottomSheet.show(context);
    }
  }

  @override
  State<VoiceBillBottomSheet> createState() => _VoiceBillBottomSheetState();
}

class _VoiceBillBottomSheetState extends State<VoiceBillBottomSheet> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  // Real speech recognition engine
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isProcessing = false;
  String? _inlineError;

  // Review state
  bool _isReviewReady = false;
  bool _isSaving = false;
  String _itemName = 'Voice Entry';
  late final TextEditingController _amountController;
  String _category = 'Food';
  String _transactionType = 'Spend'; // 'Spend' or 'Income'
  DateTime _entryDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    _focusNode = FocusNode();
    _amountController = TextEditingController();
    _initSpeech();
  }

  void _onTextChanged() {
    if (_inlineError != null) {
      setState(() => _inlineError = null);
    } else {
      if (mounted) setState(() {});
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (val) {
          debugPrint('Speech recognition error: $val');
          if (mounted) {
            setState(() {
              _isListening = false;
              _inlineError =
                  'Could not recognize speech. Please try again or type by hand.';
            });
          }
        },
        onStatus: (val) {
          debugPrint('Speech recognition status: $val');
          if (mounted && (val == 'done' || val == 'notListening')) {
            setState(() => _isListening = false);
          }
        },
      );
    } catch (e) {
      debugPrint('Speech recognition init failed: $e');
      _speechAvailable = false;
    }
  }

  @override
  void dispose() {
    try {
      _speech.stop();
    } catch (_) {}
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      try {
        await _speech.stop();
      } catch (_) {}
      if (mounted) setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      await _initSpeech();
    }

    if (_speechAvailable) {
      setState(() {
        _isListening = true;
        _inlineError = null;
      });
      try {
        await _speech.listen(
          onResult: (SpeechRecognitionResult result) {
            if (mounted) {
              setState(() {
                _textController.text = result.recognizedWords;
                _inlineError = null;
              });
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            cancelOnError: true,
          ),
        );
      } catch (e) {
        debugPrint('Speech listen failed: $e');
        if (mounted) {
          setState(() {
            _isListening = false;
            _inlineError =
                'Speech recognition failed. Please try again or type by hand.';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isListening = false;
          _inlineError =
              'Microphone permission is required for voice input, or type using the keyboard.';
        });
      }
    }
  }

  double? _parseAmountFromText(String rawText) {
    if (rawText.trim().isEmpty) return null;

    final lower = rawText.toLowerCase();

    // 1. Explicit currency patterns (e.g. ₹250, rs 250, 250 rs, 250 rupees, $50)
    final explicitCurrencyReg = RegExp(
      r'(?:(?:₹|rs\.?|inr|\$)\s*(\d+(?:\.\d+)?))|(?:(\d+(?:\.\d+)?)\s*(?:rs\.?|rupees|inr|bucks|dollars))',
    );
    final explicitMatches = explicitCurrencyReg.allMatches(lower);
    if (explicitMatches.isNotEmpty) {
      double total = 0.0;
      for (final m in explicitMatches) {
        final valStr = m.group(1) ?? m.group(2);
        if (valStr != null) {
          total += double.tryParse(valStr) ?? 0.0;
        }
      }
      if (total > 0) return total;
    }

    // 2. Strip out non-amount contextual numbers
    String cleaned = lower;

    // Ordinal dates/numbers: 1st, 2nd, 3rd, 4th, 15th, etc.
    cleaned = cleaned.replaceAll(RegExp(r'\b\d+(?:st|nd|rd|th)\b'), ' ');

    // Calendar years: 2020-2029
    cleaned = cleaned.replaceAll(RegExp(r'\b202\d\b'), ' ');

    // Context words with numbers: table 4, room 101, seat 12, gate 5, order 123, flight 402, etc.
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(?:table|room|seat|gate|flat|order|id|bus|train|flight|platform|no|number)\s*#?\s*\d+\b'),
      ' ',
    );

    // Quantities with units: 2 kg, 5 km, 3 hrs, 10 pcs, etc.
    cleaned = cleaned.replaceAll(
      RegExp(r'\b\d+\s*(?:items?|pcs|pieces?|qty|kg|kgs|km|kms|hours?|hrs|mins?|minutes?|%|percent)\b'),
      ' ',
    );

    // Quantities before common counted items: "2 pizzas", "3 coffees", "4 beers", "2 plates", "5 tickets"
    cleaned = cleaned.replaceAll(
      RegExp(r'\b\d+\s+(?:pizzas?|burgers?|coffees?|beers?|plates?|bottles?|tickets?|cups?|drinks?|cans?|packs?|people|persons?)\b'),
      ' ',
    );

    // 3. Look for numbers preceded by payment / cost prepositions (e.g. "for 250", "paid 500", "spent 120", "was 180")
    final paymentLeadReg = RegExp(
      r'(?:for|paid|spent|cost|price|bill|was|amount)\s+(\d+(?:\.\d+)?)',
    );
    final paymentMatches = paymentLeadReg.allMatches(cleaned);
    if (paymentMatches.isNotEmpty) {
      double total = 0.0;
      for (final m in paymentMatches) {
        final val = double.tryParse(m.group(1) ?? '0') ?? 0.0;
        total += val;
      }
      if (total > 0) return total;
    }

    // 4. Standalone numbers remaining in the cleaned text
    final numReg = RegExp(r'\b\d+(?:\.\d+)?\b');
    final matches = numReg.allMatches(cleaned).toList();

    if (matches.isNotEmpty) {
      // Sum only if numbers are explicitly linked with "and", "&", or "+"
      if (matches.length > 1 &&
          (cleaned.contains(' and ') || cleaned.contains(' & ') || cleaned.contains(' + '))) {
        double total = 0.0;
        for (final m in matches) {
          total += double.tryParse(m.group(0) ?? '0') ?? 0.0;
        }
        if (total > 0) return total;
      }

      // Single remaining number is the amount
      if (matches.length == 1) {
        final val = double.tryParse(matches.first.group(0) ?? '0');
        if (val != null && val > 0) return val;
      }

      // If multiple numbers without "and", prefer the largest/final monetary amount
      double maxVal = 0.0;
      for (final m in matches) {
        final val = double.tryParse(m.group(0) ?? '0') ?? 0.0;
        if (val > maxVal) maxVal = val;
      }
      if (maxVal > 0) return maxVal;
    }

    // 5. Fallback: simple English number words
    final wordMap = {
      'one': 1.0,
      'two': 2.0,
      'three': 3.0,
      'four': 4.0,
      'five': 5.0,
      'six': 6.0,
      'seven': 7.0,
      'eight': 8.0,
      'nine': 9.0,
      'ten': 10.0,
      'twenty': 20.0,
      'thirty': 30.0,
      'forty': 40.0,
      'fifty': 50.0,
      'sixty': 60.0,
      'seventy': 70.0,
      'eighty': 80.0,
      'ninety': 90.0,
      'hundred': 100.0,
      'thousand': 1000.0,
    };
    final words = cleaned.split(RegExp(r'\s+'));
    double wordTotal = 0.0;
    for (final w in words) {
      if (wordMap.containsKey(w)) {
        wordTotal += wordMap[w]!;
      }
    }
    return wordTotal > 0 ? wordTotal : null;
  }

  Future<void> _processAndReview() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _inlineError = 'Please speak or type an expense first.';
      });
      return;
    }

    final amount = _parseAmountFromText(text);
    if (amount == null || amount <= 0) {
      setState(() {
        _inlineError =
            'Could not find any amount. Please include an amount (e.g. "Lunch 250").';
      });
      return;
    }

    setState(() {
      _inlineError = null;
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    _extractDetailsFromText(text, amount);

    setState(() {
      _isProcessing = false;
      _isReviewReady = true;
      _entryDate = DateTime.now(); // default to Today so it's recent on top
    });
  }

  void _extractDetailsFromText(String rawText, double amount) {
    final lower = rawText.toLowerCase();

    _amountController.text =
        amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);

    // Clean note: strip numbers, currencies and filler prepositions
    String cleanNote = rawText
        .replaceAll(RegExp(r'\b\d+(?:\.\d+)?\b'), ' ')
        .replaceAll(RegExp(r'\b\d+(?:st|nd|rd|th)\b', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'[₹$€£,.]'), ' ')
        .replaceAll(RegExp(r'\b(?:rs\.?|rupees|inr|bucks|dollars)\b', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\b(?:for|paid|spent|cost|yesterday|today|was)\b', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleanNote.isNotEmpty) {
      cleanNote = cleanNote[0].toUpperCase() + cleanNote.substring(1);
    }

    if (lower.contains('salary') || lower.contains('income')) {
      _transactionType = 'Income';
      _category = 'Income';
      _itemName = cleanNote.isNotEmpty ? cleanNote : 'Salary Deposit';
    } else if (lower.contains('uber') || lower.contains('ola') || lower.contains('cab')) {
      _transactionType = 'Spend';
      _category = 'Travel';
      _itemName = cleanNote.isNotEmpty ? cleanNote : 'Uber Ride';
    } else if (lower.contains('fuel') || lower.contains('petrol') || lower.contains('diesel')) {
      _transactionType = 'Spend';
      _category = 'Travel';
      _itemName = cleanNote.isNotEmpty ? cleanNote : 'Fuel & Petrol';
    } else if (lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('food') ||
        lower.contains('coffee') ||
        lower.contains('tea') ||
        lower.contains('pizza') ||
        lower.contains('burger') ||
        lower.contains('grocer')) {
      _transactionType = 'Spend';
      _category = 'Food';
      _itemName = cleanNote.isNotEmpty ? cleanNote : 'Lunch & Dining';
    } else {
      _transactionType = 'Spend';
      _category = 'Other';
      _itemName = cleanNote.isNotEmpty ? cleanNote : 'Voice Entry';
    }
  }

  Future<void> _saveReviewedEntry() async {
    if (_isSaving) return;
    final amountDouble = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amountDouble <= 0) {
      AppToast.show(context, message: 'Please enter a valid amount');
      return;
    }
    final paise = (amountDouble * 100).round();
    final isIncome = _transactionType == 'Income';
    final type = isIncome ? 'income' : 'expense';

    final catModel = CategoryRegistry.find(_category, type);
    final categoryKey = catModel?.key ?? (isIncome ? 'salary' : 'food');

    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final entryDateStr =
        '${_entryDate.year}-${_entryDate.month.toString().padLeft(2, '0')}-${_entryDate.day.toString().padLeft(2, '0')}';

    setState(() => _isSaving = true);
    try {
      final txService = context.read<TransactionService>();
      final msg = await txService.bulkTransactions(
        today: today,
        entries: [
          {
            'type': type,
            'amount': paise,
            'category': categoryKey,
            'note': _itemName,
            'date': entryDateStr,
          }
        ],
      );

      if (!mounted) return;
      context.read<WalletBloc>().add(const RefreshWalletSummary());
      AppToast.show(context, message: msg);
      Navigator.of(context).pop('entry_added');
    } catch (e) {
      if (!mounted) return;
      final err = e is ApiException ? e.message : 'Failed to save entry';
      AppToast.show(context, message: err);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

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
        categories: availableCats.isNotEmpty ? availableCats : const ['Food', 'Travel', 'Shopping', 'Other'],
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
            'VOICE TRANSCRIPTION\nNote: ${_textController.text}\nDate: ${_formatDate(_entryDate)}\nCategory: $_category\nAmount: ₹${_amountController.text}\nType: $_transactionType',
        isSaving: _isSaving,
        onAddEntry: _saveReviewedEntry,
        onBack: () {
          if (_isSaving) return;
          setState(() {
            _isReviewReady = false;
          });
        },
      );
    }

    // 1. Initial State: Text box with mic button on bottom-right, chips, and actions
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Multi-line Text Area Container with Mic Button at Bottom-Right
        Container(
          height: 150.h,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF101A2B).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text Field
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Or type it: lunch 250 and fuel 500 yesterday',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Bottom Row with Circular Mic Button on the Right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status indicator if listening
                  if (_isListening)
                    Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: AppColors.popDeep,
                            shape: BoxShape.circle,
                          ),
                        ),
                        6.horizontalSpace,
                        Text(
                          'Listening...',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.popDeep,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),

                  // Circular Blue Mic Button (bottom-right)
                  GestureDetector(
                    onTap: _toggleListening,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? AppColors.accent
                            : AppColors.popDeep,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? AppColors.accent
                                    : AppColors.popDeep)
                                .withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        14.verticalSpace,

        // Continuous Audio Waveform Line (when listening) OR Natural Language Tip (when idle)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isListening
              ? Container(
                  key: const ValueKey('waveform'),
                  padding:
                      EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _AudioWaveformLine(),
                      6.verticalSpace,
                      Text(
                        'Listening... Speak now',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.popDeep,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  key: const ValueKey('tip'),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('💡', style: TextStyle(fontSize: 14.sp)),
                      8.horizontalSpace,
                      Flexible(
                        child: Text(
                          'Try: "Dinner with friends 450" or "Uber 180 yesterday"',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        14.verticalSpace,

        if (_inlineError != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 20.sp,
                ),
                10.horizontalSpace,
                Expanded(
                  child: Text(
                    _inlineError!,
                    style: GoogleFonts.dmSans(
                      color: AppColors.error,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          12.verticalSpace,
        ],

        // Action Button: "Add entries •"
        Builder(
          builder: (context) {
            final hasText = _textController.text.trim().isNotEmpty;
            return GestureDetector(
              onTap: _isProcessing ? null : _processAndReview,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: hasText && !_isProcessing
                      ? const Color(0xFF3B6EA5)
                      : const Color(0xFFA8C5E2).withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: hasText && !_isProcessing
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3B6EA5).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isProcessing ? 'Reading with Budgie...' : 'Add entries',
                      style: GoogleFonts.dmSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: hasText
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    6.horizontalSpace,
                    Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: BoxDecoration(
                        color: hasText
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        10.verticalSpace,

        // Secondary Action Button: "Add by hand instead"
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop('manual');
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Text(
                'Add by hand instead',
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ),

        8.verticalSpace,
      ],
    );
  }
}

/// Continuous audio waveform line with smooth undulating middle wave peaks (Image 2)
class _AudioWaveformLine extends StatefulWidget {
  const _AudioWaveformLine();

  @override
  State<_AudioWaveformLine> createState() => _AudioWaveformLineState();
}

class _AudioWaveformLineState extends State<_AudioWaveformLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rigid height prevents the container or parent layout from moving at all
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        width: double.infinity,
        height: 38.h,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return CustomPaint(
              painter: _AudioWaveformLinePainter(
                color: AppColors.popDeep,
                animationValue: _animController.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AudioWaveformLinePainter extends CustomPainter {
  const _AudioWaveformLinePainter({
    this.color = AppColors.popDeep,
    required this.animationValue,
  });

  final Color color;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final midY = size.height / 2;
    final w = size.width;

    // Node points matching the continuous sinusoidal audio wave in reference image
    // (xRatio, normalized amplitude from -1.0 to 1.0)
    final points = <Offset>[
      const Offset(0.00, 0.00),
      const Offset(0.12, 0.00),
      const Offset(0.14, -0.20),
      const Offset(0.16, 0.35),
      const Offset(0.18, -0.55),
      const Offset(0.20, 0.80),
      const Offset(0.22, -0.95),
      const Offset(0.24, 0.90),
      const Offset(0.26, -0.70),
      const Offset(0.28, 0.45),
      const Offset(0.30, -0.30),
      const Offset(0.32, 0.20),
      const Offset(0.34, -0.45),
      const Offset(0.36, 0.75),
      const Offset(0.38, -0.85),
      const Offset(0.40, 0.90),
      const Offset(0.42, -0.70),
      const Offset(0.44, 0.50),
      const Offset(0.46, -0.35),
      const Offset(0.48, 0.25),
      const Offset(0.50, -0.30),
      const Offset(0.52, 0.60),
      const Offset(0.54, -0.80),
      const Offset(0.56, 0.95),
      const Offset(0.58, -0.90),
      const Offset(0.60, 0.85),
      const Offset(0.62, -0.65),
      const Offset(0.64, 0.40),
      const Offset(0.66, -0.25),
      const Offset(0.68, 0.55),
      const Offset(0.70, -0.75),
      const Offset(0.72, 0.90),
      const Offset(0.74, -0.85),
      const Offset(0.76, 0.65),
      const Offset(0.78, -0.40),
      const Offset(0.80, 0.20),
      const Offset(0.82, -0.10),
      const Offset(0.85, 0.00),
      const Offset(1.00, 0.00),
    ];

    final maxAmp = size.height * 0.44;
    path.moveTo(0, midY);

    for (int i = 0; i < points.length - 1; i++) {
      final p1Base = points[i];
      final p2Base = points[i + 1];

      // Flat tails (dy == 0) remain strictly stationary on the baseline.
      // Middle wave peaks undulate smoothly with continuous harmonic phase shift.
      final factor1 = p1Base.dy == 0
          ? 0.0
          : (0.70 + 0.30 * math.sin(2 * math.pi * animationValue + i * 0.35));
      final factor2 = p2Base.dy == 0
          ? 0.0
          : (0.70 +
              0.30 *
                  math.sin(
                      2 * math.pi * animationValue + (i + 1) * 0.35));

      final dy1 = p1Base.dy * factor1;
      final dy2 = p2Base.dy * factor2;

      final p1 = Offset(p1Base.dx * w, midY + dy1 * maxAmp);
      final p2 = Offset(p2Base.dx * w, midY + dy2 * maxAmp);

      final cx = (p1.dx + p2.dx) / 2;
      path.cubicTo(cx, p1.dy, cx, p2.dy, p2.dx, p2.dy);
    }

    path.lineTo(w, midY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AudioWaveformLinePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color;
}
