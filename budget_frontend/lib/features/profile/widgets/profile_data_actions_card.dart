import 'package:flutter/material.dart';

import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/widgets/app_card.dart';
import 'package:budget_frontend/features/profile/widgets/data_raw.dart';

class ProfileDataActionsCard extends StatelessWidget {
  const ProfileDataActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppBorderRadius.card,
      padding: EdgeInsets.zero,
      isGradient: false,
      child: Column(
        children: [
          DataRaw(
            icon: AppIcons.database,
            title: 'Load example data',
            subtitle: 'Replace your entries with sample ones',
            onTap: () {},
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.line,
            indent: 16,
          ),
          DataRaw(
            icon: AppIcons.delete,
            title: 'Clear all entries',
            subtitle: 'Removes entries and goals from this device',
            iconColor: AppColors.error,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
