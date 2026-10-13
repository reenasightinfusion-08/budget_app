import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/features/profile/widgets/data_card.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const DataCard(count: '12', name: "Entries"),
        10.horizontalSpace,
        const DataCard(count: '18', name: "Goals"),
        10.horizontalSpace,
        const DataCard(count: '6', name: "Months"),
      ],
    );
  }
}
