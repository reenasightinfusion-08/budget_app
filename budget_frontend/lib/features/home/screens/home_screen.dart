import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/home/screens/home_tab_screen.dart';
import 'package:budget_frontend/features/home/widgets/floating_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _buildPlaceholderTab(String title, String subtitle, IconData icon) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              12.verticalSpace,
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: AppColors.fill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.accent, size: 24.sp),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyle.title,
                    ),
                  ),
                ],
              ),
              8.verticalSpace,
              Text(
                subtitle,
                style: AppTextStyle.body,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeTabScreen(),
          _buildPlaceholderTab(
            'Analytics',
            'Track your spending and income trends over time.',
            AppIcons.analytics,
          ),
          _buildPlaceholderTab(
            'Wallet & Accounts',
            'Manage your connected bank accounts and cards.',
            AppIcons.wallet,
          ),
          _buildPlaceholderTab(
            'Profile & Settings',
            'Manage your account preferences and security.',
            AppIcons.person,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(45.w, 0, 45.w, 16.h),
          child: FloatingBottomNavBar(
            selectedIndex: _selectedIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
