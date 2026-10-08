import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/setup/providers/setup_provider.dart';
import 'package:budget_frontend/features/setup/widgets/setup_switch.dart';

class SetupSampleToggle extends StatelessWidget {
  const SetupSampleToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isOn = context.select<SetupProvider, bool>((provider) => provider.useSampleData);

    return Material(
      color: AppColors.fill,
      borderRadius: AppBorderRadius.tile,
      child: InkWell(
        onTap: () => context.read<SetupProvider>().toggleSampleData(),
        borderRadius: AppBorderRadius.tile,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fill with sample entries', style: AppTextStyle.toggleTitle),
                    1.verticalSpace,
                    Text(
                      'See Budgie with real-looking data. Clear it anytime.',
                      style: AppTextStyle.toggleSubtitle,
                    ),
                  ],
                ),
              ),
              12.horizontalSpace,
              SetupSwitch(isOn: isOn),
            ],
          ),
        ),
      ),
    );
  }
}
