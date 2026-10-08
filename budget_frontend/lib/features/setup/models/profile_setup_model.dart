class ProfileSetupModel {
  const ProfileSetupModel({
    required this.name,
    required this.monthlyBudget,
    required this.usesSampleData,
  });

  final String name;
  final int monthlyBudget;
  final bool usesSampleData;
}
