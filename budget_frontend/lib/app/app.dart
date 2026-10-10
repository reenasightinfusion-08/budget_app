import 'package:budget_frontend/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/theme/app_theme.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/auth/services/api_auth_service.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/setup/services/profile_service.dart';

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authService: ApiAuthService(apiClient)),
          ),
          BlocProvider<SetupBloc>(
            create: (context) => SetupBloc(profileService: ProfileService(apiClient)),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            color: AppColors.fill,
            title: 'Budget',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          ),
        ),
      );
}
