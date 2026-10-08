import 'package:flutter/foundation.dart';

import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/features/setup/models/profile_setup_model.dart';

class SetupProvider extends ChangeNotifier {
  static const int daysInMonth = 30;

  int budgetAmount = 0;
  bool useSampleData = false;
  ProfileSetupModel? profile;

  bool get isComplete => profile != null;

  String? get dailyAllowanceLabel => budgetAmount > 0
      ? '${AppFormatters.rupees((budgetAmount / daysInMonth).round())} a day'
      : null;

  void setBudget(int amount) {
    if (amount == budgetAmount) return;
    budgetAmount = amount;
    notifyListeners();
  }

  void toggleSampleData() {
    useSampleData = !useSampleData;
    notifyListeners();
  }

  /// Saves the answers from the setup screen so the home screen can greet the
  /// user and size their budget. Persisting to the backend comes later.
  void completeSetup({required String name}) {
    profile = ProfileSetupModel(
      name: name,
      monthlyBudget: budgetAmount,
      usesSampleData: useSampleData,
    );
    notifyListeners();
  }
}
