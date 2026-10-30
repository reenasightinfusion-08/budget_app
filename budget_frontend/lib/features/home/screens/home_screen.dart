import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_border_radius.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_icons.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/home_tab/screen/home_tab_screen.dart';
import 'package:budget_frontend/features/home/widgets/floating_bottom_nav_bar.dart';
import 'package:budget_frontend/features/home/widgets/spend_income_bottom_sheet.dart';
import 'package:budget_frontend/features/home/widgets/tab_page_transition.dart';
import 'package:budget_frontend/core/widgets/app_toast.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/categories/bloc/category_bloc.dart';
import 'package:budget_frontend/features/insights/screens/insights_screen.dart';
import 'package:budget_frontend/features/savings/bloc/goal_bloc.dart';
import 'package:budget_frontend/features/savings/screen/savings_screen.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';
import 'package:budget_frontend/features/wallet/screens/wallet_screen.dart';

import 'package:budget_frontend/features/home/widgets/home_tab_scope.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasCheckedToast = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authUser = context.read<AuthBloc>().state.user;
        if (authUser != null && authUser.monthlyBudget > 0) {
          context.read<WalletBloc>().add(WalletUserSynced(authUser));
        }
        context.read<WalletBloc>().add(const LoadWallet());
        context.read<CategoryBloc>().add(const LoadCategories());
        context.read<GoalBloc>().add(const LoadGoals());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasCheckedToast) {
      _hasCheckedToast = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final isLogin = args['fromLogin'] == true;
        final isSignup = args['fromSignup'] == true;

        if (isLogin || isSignup) {
          final rawName = args['username'] as String?;
          final authUser = context.read<AuthBloc>().state.user;
          final setupProfile = context.read<SetupBloc>().state.profile;
          final username = (rawName != null && rawName.isNotEmpty)
              ? rawName
              : UserModel.resolveName(
                  profileName: setupProfile?.name,
                  user: authUser,
                );

          final message = isLogin
              ? 'Welcome back! $username'
              : 'Welcome! $username';

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppToast.show(
                context,
                message: message,
                bottom: AppLayout.isTablet(context) ? 95 : 95.h,
              );
            }
          });
        }
      }
    }
  }

  void _onSelectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppLayout.isTablet(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.unauthenticated ||
          (previous.user?.monthlyBudget != current.user?.monthlyBudget &&
              current.user != null) ||
          (current.errorMessage != null &&
              previous.errorMessage != current.errorMessage),
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.read<WalletBloc>().add(const ResetWallet());
          context.read<GoalBloc>().add(const ResetGoals());
          if (ModalRoute.of(context)?.isCurrent == true) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          }
        } else if (state.user != null && state.user!.monthlyBudget > 0) {
          context.read<WalletBloc>().add(WalletUserSynced(state.user!));
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
        body: HomeTabScope(
          onSelectTab: _onSelectTab,
          child: Stack(
            children: [
              MediaQuery.removePadding(
                context: context,
                removeBottom: AppLayout.isIOS,
                child: TabPageTransition(
                  index: _selectedIndex,
                  children: [
                    HomeTabScreen(onSelectTab: _onSelectTab),
                    const InsightsScreen(),
                    const WalletScreen(),
                    const SavingsScreen(),
                  ],
                ),
              ),
              if (isTablet) ...[
                Positioned(
                  right: math.max(
                    28.0,
                    (MediaQuery.sizeOf(context).width - 480) / 2,
                  ),
                  bottom: 102,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.tile,
                      gradient: AppGradients.card,
                    ),
                    child: FloatingActionButton(
                      elevation: 0,
                      highlightElevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(),
                      onPressed: () => SpendIncomeBottomSheet.show(context),
                      child: const Icon(
                        AppIcons.add,
                        color: AppColors.fill,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Center(
                    child: SizedBox(
                      width: 480,
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
                ),
              ] else ...[
                Positioned(
                  right: 20.w,
                  bottom: AppLayout.fabBottom(context),
                  child: Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      borderRadius: AppBorderRadius.tile,
                      gradient: AppGradients.card,
                    ),
                    child: FloatingActionButton(
                      elevation: 0,
                      highlightElevation: 0,
                      focusElevation: 0,
                      hoverElevation: 0,
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(),
                      onPressed: () => SpendIncomeBottomSheet.show(context),
                      child: Icon(
                        AppIcons.add,
                        color: AppColors.fill,
                        size: 30.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 40.w,
                  right: 40.w,
                  bottom: AppLayout.navBarBottom(context),
                  child: FloatingBottomNavBar(
                    selectedIndex: _selectedIndex,
                    onTabSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
