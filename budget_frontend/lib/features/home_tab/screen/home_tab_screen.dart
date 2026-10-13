import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/features/home_tab/widget/available_to_spend_card.dart';
import 'package:budget_frontend/features/home_tab/widget/home_header.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, AppLayout.navBarClearance.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            15.verticalSpace,
            const AvailableToSpendCard(),
          ],
        ),
      ),
    );
  }
}
