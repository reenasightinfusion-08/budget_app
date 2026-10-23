import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:budget_frontend/core/constants/app_gradients.dart';
import 'package:budget_frontend/core/constants/app_layout.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthStarted());
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = AppLayout.isTablet(context);

    // Keep 100% original scaling on mobile, disable non-proportional inflation on tablet
    ScreenUtil.enableScale(
      enableWH: () => !isTablet,
      enableText: () => !isTablet,
    );

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.authenticated ||
          current.status == AuthStatus.unauthenticated,
      listener: (context, state) async {
        await Future.delayed(const Duration(seconds: 3));
        if (!context.mounted) return;
        final nextRoute =
            state.status == AuthStatus.authenticated ? AppRoutes.afterAuth(state.user) : AppRoutes.login;
        Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (route) => false);
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppGradients.card,
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mascot with concentric white rings centered behind it
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: isTablet ? 320 : 330.r,
                        height: isTablet ? 320 : 330.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.2,
                          ),
                        ),
                      ),
                      Container(
                        width: isTablet ? 170 : 175.r,
                        height: isTablet ? 170 : 175.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                            width: 1.2,
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        'assest/cartoon.svg',
                        width: isTablet ? 140 : 140.w,
                        height: isTablet ? 140 : 140.w,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 24 : 20.h),
                  Text(
                    'Budgie',
                    style: isTablet
                        ? AppTextStyle.splashTitle.copyWith(fontSize: 36)
                        : AppTextStyle.splashTitle,
                  ),
                  SizedBox(height: isTablet ? 10 : 8.h),
                  Text(
                    'A calmer way to watch your money.',
                    textAlign: TextAlign.center,
                    style: (isTablet
                            ? AppTextStyle.subtitle.copyWith(fontSize: 16)
                            : AppTextStyle.subtitle)
                        .copyWith(
                      color: AppColors.onAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
