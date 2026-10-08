import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/theme/app_theme.dart';
import 'package:budget_frontend/features/auth/providers/auth_provider.dart';
import 'package:budget_frontend/features/auth/services/mock_auth_service.dart';
import 'package:budget_frontend/features/setup/providers/setup_provider.dart';

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(authService: MockAuthService())),
          ChangeNotifierProvider(create: (_) => SetupProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            title: 'Budget',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            initialRoute: AppRoutes.login,
            routes: AppRoutes.routes,
          ),
        ),
      );
}
