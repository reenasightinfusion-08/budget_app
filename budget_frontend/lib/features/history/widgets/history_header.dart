import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';

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
  bool _ownsController = false;
  late int _selectedFilterIndex;

  static const List<String> _filters = ['All', 'Money out', 'Money in'];

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.selectedFilterIndex;
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
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
            return AppTextField(
              fillColor: AppColors.surface,
              controller: _controller,
              hint: widget.hint,
              icon: AppIcons.search,
              borderRadius: AppBorderRadius.pill,
              textInputAction: TextInputAction.search,
              validator: (_) => null,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        AppIcons.close,
                        size: isTablet ? 18 : 18.sp,
                        color: AppColors.muted,
                      ),
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged?.call('');
                        widget.onClear?.call();
                      },
                    )
                  : null,
            );
          },
        ),
        isTablet ? const SizedBox(height: 16) : 15.verticalSpace,
        Row(
          children: [
            for (int i = 0; i < _filters.length; i++) ...[
              if (i > 0) isTablet ? const SizedBox(width: 10) : 10.horizontalSpace,
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
