import 'dart:math';

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

import 'package:budget_frontend/core/ads/ad_service.dart';

const _kAppOpenExemptRoutes = {
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
  AppRoutes.verifyEmail,
  AppRoutes.setup,
};

class _RouteNameObserver extends NavigatorObserver {
  _RouteNameObserver({required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onChanged(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onChanged(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    onChanged(newRoute?.settings.name);
  }
}

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> {
  String? _currentRoute;
  late final NavigatorObserver _routeObserver = _RouteNameObserver(
    onChanged: (name) => _currentRoute = name,
  );

  @override
  void initState() {
    super.initState();
    AdService.appOpenGuard = () => !_kAppOpenExemptRoutes.contains(_currentRoute);
  }

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<TransactionService>(
            create: (context) => TransactionService(widget.apiClient),
          ),
          RepositoryProvider<CategoryService>(
            create: (context) => CategoryService(widget.apiClient),
          ),
          RepositoryProvider<GoalService>(
            create: (context) => GoalService(widget.apiClient),
          ),
          RepositoryProvider<SmartAddService>(
            create: (context) => SmartAddService(widget.apiClient),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(authService: ApiAuthService(widget.apiClient)),
            ),
            BlocProvider<CategoryBloc>(
              create: (context) => CategoryBloc(
                categoryService: CategoryService(widget.apiClient),
              ),
            ),
            BlocProvider<GoalBloc>(
              create: (context) => GoalBloc(
                goalService: GoalService(widget.apiClient),
              ),
            ),
            BlocProvider<SetupBloc>(
              create: (context) => SetupBloc(profileService: ProfileService(widget.apiClient)),
            ),
            BlocProvider<WalletBloc>(
              create: (context) => WalletBloc(
                profileService: ProfileService(widget.apiClient),
                transactionService: TransactionService(widget.apiClient),
                categoryService: CategoryService(widget.apiClient),
              ),
            ),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            fontSizeResolver: (fontSize, instance) {
              final shortestSide = min(instance.screenWidth, instance.screenHeight);
              if (shortestSide >= 600) {
                return fontSize.toDouble();
              }
              return FontSizeResolvers.width(fontSize, instance);
            },
            builder: (context, child) {
              final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
              ScreenUtil.enableScale(
                enableWH: () => !isTablet,
                enableText: () => !isTablet,
              );
              return MaterialApp(
                title: 'Budgie',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                initialRoute: AppRoutes.splash,
                routes: AppRoutes.routes,
                navigatorObservers: [_routeObserver],
              );
            },
          ),
        ),
      );
}
