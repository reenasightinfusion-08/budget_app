import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/home/screens/home_tab_screen.dart';
import 'package:budget_frontend/features/home/widgets/floating_bottom_nav_bar.dart';
import 'package:budget_frontend/features/home/widgets/tab_page_transition.dart';
import 'package:budget_frontend/features/insights/screens/insights_screen.dart';
import 'package:budget_frontend/features/wallet/screens/wallet_screen.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.unauthenticated ||
          (current.errorMessage != null && previous.errorMessage != current.errorMessage),
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.signup,
            (route) => false,
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<AuthBloc>().add(const AuthErrorCleared());
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            TabPageTransition(
              index: _selectedIndex,
              children: [
                const HomeTabScreen(),
                const InsightsScreen(),
                const WalletScreen(),
                _buildPlaceholderTab(
                  'Savings',
                  'Track your savings goals and piggy bank.',
                  AppIcons.savings,
                ),
              ],
            ),
            Positioned(
              left: 40.w,
              right: 40.w,
              bottom: 16.h,
              child: SafeArea(
                top: false,
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
          ],
        ),
      ),
    );
  }
}
