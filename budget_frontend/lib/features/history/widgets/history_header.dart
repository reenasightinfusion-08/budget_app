import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class HistoryHeader extends StatefulWidget {
  const HistoryHeader({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hint = 'Search notes or categories',
    this.selectedFilterIndex = 0,
    this.onFilterChanged,
    this.onFilterIndexChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hint;
  final int selectedFilterIndex;
  final ValueChanged<String>? onFilterChanged;
  final ValueChanged<int>? onFilterIndexChanged;

  @override
  State<HistoryHeader> createState() => _HistoryHeaderState();
}

class _HistoryHeaderState extends State<HistoryHeader> {
  late TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  late int _selectedFilterIndex;
  bool _isFocused = false;

  static const List<String> _filters = ['All', 'Money out', 'Money in'];

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.selectedFilterIndex;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
  }

  void _onFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void didUpdateWidget(HistoryHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilterIndex != widget.selectedFilterIndex) {
      _selectedFilterIndex = widget.selectedFilterIndex;
    }
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = TextEditingController();
        _ownsController = true;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _focusNode.requestFocus(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppBorderRadius.pill,
                  border: Border.all(
                    color: _isFocused
                        ? AppColors.accent.withValues(alpha: 0.65)
                        : AppColors.line.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                          ? AppColors.accent.withValues(alpha: 0.08)
                          : AppColors.ink.withValues(alpha: 0.04),
                      blurRadius: _isFocused ? 10.r : 8.r,
                      offset: Offset(0, (isTablet ? 3 : 2.5).h),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 14 : 12.w,
                  vertical: isTablet ? 2 : 1.h,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.only(
                        left: isTablet ? 4 : 2.w,
                        right: isTablet ? 10 : 8.w,
                      ),
                      child: Icon(
                        AppIcons.search,
                        size: isTablet ? 20 : 19.sp,
                        color: _isFocused ? AppColors.accent : AppColors.muted,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        style: AppTextStyle.input.copyWith(
                          fontSize: isTablet ? 15 : 14.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                        cursorColor: AppColors.accent,
                        cursorWidth: 1.8,
                        cursorRadius: const Radius.circular(2),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: widget.hint,
                          hintStyle: AppTextStyle.hint.copyWith(
                            fontSize: isTablet ? 15 : 14.5.sp,
                            color: AppColors.faint,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isTablet ? 14 : 13.5.h,
                          ),
                        ),
                      ),
                    ),
                    if (value.text.isNotEmpty)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                          widget.onClear?.call();
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 6.w),
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.fill,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppIcons.close,
                            size: isTablet ? 13 : 12.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        isTablet ? const SizedBox(height: 16) : 15.verticalSpace,
        Row(
          children: [
            for (int i = 0; i < _filters.length; i++) ...[
              if (i > 0)
                isTablet ? const SizedBox(width: 10) : 10.horizontalSpace,
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedFilterIndex = i);
                    widget.onFilterIndexChanged?.call(i);
                    widget.onFilterChanged?.call(_filters[i]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: isTablet
                        ? const EdgeInsets.symmetric(vertical: 12)
                        : EdgeInsets.symmetric(vertical: 11.h),
                    decoration: BoxDecoration(
                      color: _selectedFilterIndex == i
                          ? AppColors.popDeep
                          : AppColors.surface,
                      borderRadius: AppBorderRadius.pill,
                      border: Border.all(
                        color: _selectedFilterIndex == i
                            ? AppColors.popDeep
                            : AppColors.line.withValues(alpha: 0.8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedFilterIndex == i
                              ? AppColors.popDeep.withValues(alpha: 0.18)
                              : AppColors.ink.withValues(alpha: 0.03),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _filters[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.chip.copyWith(
                        fontSize: isTablet ? 14 : 13.5.sp,
                        fontWeight: _selectedFilterIndex == i
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _selectedFilterIndex == i
                            ? Colors.white
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        isTablet ? const SizedBox(height: 16) : 15.verticalSpace,
      ],
    );
  }
}
