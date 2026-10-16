import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:budget_frontend/app/app.dart';
import 'package:budget_frontend/core/network/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(BudgetApp(apiClient: ApiClient()));
}
