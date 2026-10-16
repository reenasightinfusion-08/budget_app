import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/theme/app_theme.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/auth/services/api_auth_service.dart';
import 'package:budget_frontend/features/categories/bloc/category_bloc.dart';
import 'package:budget_frontend/features/categories/services/category_service.dart';
import 'package:budget_frontend/features/history/services/transaction_service.dart';
import 'package:budget_frontend/features/savings/bloc/goal_bloc.dart';
import 'package:budget_frontend/features/savings/services/goal_service.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/setup/services/profile_service.dart';
import 'package:budget_frontend/features/smart_add/services/smart_add_service.dart';
import 'package:budget_frontend/features/wallet/bloc/wallet_bloc.dart';

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<TransactionService>(
            create: (context) => TransactionService(apiClient),
          ),
          RepositoryProvider<CategoryService>(
            create: (context) => CategoryService(apiClient),
          ),
          RepositoryProvider<GoalService>(
            create: (context) => GoalService(apiClient),
          ),
          RepositoryProvider<SmartAddService>(
            create: (context) => SmartAddService(apiClient),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(authService: ApiAuthService(apiClient)),
            ),
            BlocProvider<CategoryBloc>(
              create: (context) => CategoryBloc(
                categoryService: CategoryService(apiClient),
              )..add(const LoadCategories()),
            ),
            BlocProvider<GoalBloc>(
              create: (context) => GoalBloc(
                goalService: GoalService(apiClient),
              )..add(const LoadGoals()),
            ),
            BlocProvider<SetupBloc>(
              create: (context) => SetupBloc(profileService: ProfileService(apiClient)),
            ),
            BlocProvider<WalletBloc>(
              create: (context) => WalletBloc(
                profileService: ProfileService(apiClient),
                transactionService: TransactionService(apiClient),
                categoryService: CategoryService(apiClient),
              ),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp(
              title: 'Budget',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              initialRoute: AppRoutes.splash,
              routes: AppRoutes.routes,
            ),
          ),
        ),
      );
}
