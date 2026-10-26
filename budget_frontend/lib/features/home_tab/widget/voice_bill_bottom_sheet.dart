import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/network/api_exception.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/widgets/app_bottom_sheet.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';
import 'package:budget_frontend/features/home_tab/widget/audio_waveform_widget.dart';
import 'package:budget_frontend/features/home_tab/widget/smart_add_views.dart';
import 'package:budget_frontend/features/home_tab/widget/voice_text_parser.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

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
  List<SmartAddReviewItem> _reviewItems = [];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    _focusNode = FocusNode();
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
    for (final item in _reviewItems) {
      item.amountController.dispose();
    }
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
              final words = result.recognizedWords;
              setState(() {
                _textController.value = TextEditingValue(
                  text: words,
                  selection: TextSelection.collapsed(offset: words.length),
                );
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

  Future<void> _processAndReview() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _inlineError = 'Please speak or type an expense first.';
      });
      return;
    }

    final parsedList = VoiceTextParser.parseEntries(text);
    if (parsedList.isEmpty) {
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

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    for (final item in _reviewItems) {
      item.amountController.dispose();
    }

    _reviewItems = parsedList.map((parsed) {
      return SmartAddReviewItem(
        title: parsed.note,
        amountController: TextEditingController(
          text: parsed.amount.toStringAsFixed(parsed.amount % 1 == 0 ? 0 : 2),
        ),
        category: parsed.category,
        date: DateTime.now(),
        transactionType: parsed.transactionType,
        isSelected: true,
      );
    }).toList();

    setState(() {
      _isProcessing = false;
      _isReviewReady = true;
    });
  }

  Future<void> _saveReviewedEntries() async {
    if (_isSaving) return;

    final selectedItems = _reviewItems.where((i) => i.isSelected).toList();
    if (selectedItems.isEmpty) {
      AppToast.show(context, message: 'Please select at least one entry');
      return;
    }

    for (final item in selectedItems) {
      final amt = double.tryParse(item.amountController.text.trim()) ?? 0.0;
      if (amt <= 0) {
        AppToast.show(
            context, message: 'Please enter a valid amount for ${item.title}');
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final txService = context.read<TransactionService>();

      // Prepare payload exactly for POST /api/transactions/bulk
      final entriesToBulk = selectedItems.map((item) {
        final amt = double.tryParse(item.amountController.text.trim()) ?? 0.0;
        final entry = TransactionService.prepareEntry(
          amount: amt,
          transactionType: item.transactionType,
          category: item.category,
          note: item.title,
          entryDate: item.date,
        );
        return entry.toMap();
      }).toList();

      final today = AppFormatters.dateForApi(DateTime.now());
      final msg = await txService.bulkTransactions(
        today: today,
        entries: entriesToBulk,
      );

      if (!mounted) return;
      context.read<WalletBloc>().add(const RefreshWalletSummary());
      AppToast.show(context, message: msg);
      Navigator.of(context).pop('entry_added');
    } catch (e) {
      if (!mounted) return;
      final err = e is ApiException ? e.message : 'Failed to save entries';
      AppToast.show(context, message: err);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onBackFromReview() {
    if (_isSaving) return;
    setState(() {
      _isReviewReady = false;
    });
  }

  String _formatDate(DateTime date) => AppFormatters.dateSlash(date);

  @override
  Widget build(BuildContext context) {
    if (_isReviewReady) {
      return _buildReviewView();
    }

    final hasText = _textController.text.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextInputCard(),
        14.verticalSpace,
        _buildWaveformOrTip(),
        14.verticalSpace,
        if (_inlineError != null) ...[
          _buildErrorBanner(_inlineError!),
          14.verticalSpace,
        ],
        _buildActionButtons(hasText),
        10.verticalSpace,
        _buildAddByHandButton(),
        8.verticalSpace,
      ],
    );
  }

  Widget _buildReviewView() {
    final availableCats = {
      ...CategoryRegistry.expenses.map((c) => c.label),
      ...CategoryRegistry.incomes.map((c) => c.label),
    }.toList();

    return SmartAddMultiReviewView(
      items: _reviewItems,
      categories: availableCats.isNotEmpty
          ? availableCats
          : const [
              'Food',
              'Travel',
              'Shopping',
              'Bills',
              'Health',
              'Income',
              'Other'
            ],
      rawReadText: _reviewItems.map((item) {
        return 'Item: ${item.title}\nCategory: ${item.category}\nAmount: ₹${item.amountController.text}\nDate: ${_formatDate(item.date)}\nType: ${item.transactionType}';
      }).join('\n---\n'),
      isSaving: _isSaving,
      onSave: _saveReviewedEntries,
      onBack: _onBackFromReview,
    );
  }

  Widget _buildTextInputCard() {
    return Container(
      height: 150.h,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.sm,
        border: Border.all(
          color: AppColors.line,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14.sp,
                color: AppColors.ink,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Or type it: lunch 250 and fuel 500 yesterday',
                hintStyle: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13.sp,
                  color: AppColors.faint,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.popDeep,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              GestureDetector(
                onTap: _toggleListening,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: _isListening ? AppColors.accent : AppColors.popDeep,
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
                      _isListening ? AppIcons.stop : AppIcons.mic,
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
    );
  }

  Widget _buildWaveformOrTip() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isListening
          ? Container(
              key: const ValueKey('waveform'),
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AudioWaveformWidget(),
                  6.verticalSpace,
                  Text(
                    'Listening... Speak now',
                    style: TextStyle(
                      fontFamily: 'DMSans',
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.fill.withValues(alpha: 0.8),
                borderRadius: AppBorderRadius.chip,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('💡', style: TextStyle(fontSize: 14.sp)),
                  8.horizontalSpace,
                  Flexible(
                    child: Text(
                      'Try: "Dinner with friends 450" or "Uber 180 yesterday"',
                      style: TextStyle(
                        fontFamily: 'DMSans',
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
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: AppBorderRadius.chip,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.error,
            color: AppColors.error,
            size: 20.sp,
          ),
          10.horizontalSpace,
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontFamily: 'DMSans',
                color: AppColors.error,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool hasText) {
    return GestureDetector(
      onTap: hasText && !_isProcessing ? _processAndReview : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: hasText && !_isProcessing
              ? AppColors.accent
              : AppColors.pop.withValues(alpha: 0.65),
          borderRadius: AppBorderRadius.dialog,
          boxShadow: hasText && !_isProcessing
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isProcessing ? 'Reading with Budgie...' : 'Add entries',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: hasText
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
              if (_isProcessing) ...[
                10.horizontalSpace,
                SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddByHandButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop('manual');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.dialog,
          border: Border.all(
            color: AppColors.line,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            'Add by hand instead',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
