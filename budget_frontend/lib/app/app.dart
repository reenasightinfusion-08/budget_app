import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/theme/app_theme.dart';

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          title: 'Budget',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: AppRoutes.login,
          routes: AppRoutes.routes,
        ),
      );
}
