class UserModel {
  const UserModel({
    required this.email,
    this.name = '',
    this.photoUrl,
    this.monthlyBudget = 0,
    this.onboardingComplete = false,
    this.hasExampleData = false,
    this.categoryLimits = const {},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawLimits = json['categoryLimits'];
    final Map<String, int> limits = {};
    if (rawLimits is Map) {
      rawLimits.forEach((key, val) {
        if (val is num) limits[key.toString()] = val.toInt();
      });
    }

    return UserModel(
      email: json['email'] as String,
      name: (json['name'] as String?) ?? '',
      photoUrl: json['photoUrl'] as String?,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toInt() ?? 0,
      onboardingComplete: (json['onboardingComplete'] as bool?) ?? false,
      hasExampleData: (json['hasExampleData'] as bool?) ?? false,
      categoryLimits: limits,
    );
  }

  final String email;
  final String name;
  final String? photoUrl;

  /// In paise, as stored by the backend.
  final int monthlyBudget;
  final bool onboardingComplete;
  final bool hasExampleData;
  final Map<String, int> categoryLimits;

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  UserModel copyWith({
    String? email,
    String? name,
    String? photoUrl,
    int? monthlyBudget,
    bool? onboardingComplete,
    bool? hasExampleData,
    Map<String, int>? categoryLimits,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      hasExampleData: hasExampleData ?? this.hasExampleData,
      categoryLimits: categoryLimits ?? this.categoryLimits,
    );
  }
}
