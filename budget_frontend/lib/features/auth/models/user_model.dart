class UserModel {
  const UserModel({
    required this.email,
    this.name = '',
    this.photoUrl,
    this.monthlyBudget = 0,
    this.onboardingComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json['email'] as String,
        name: (json['name'] as String?) ?? '',
        photoUrl: json['photoUrl'] as String?,
        monthlyBudget: (json['monthlyBudget'] as num?)?.toInt() ?? 0,
        onboardingComplete: (json['onboardingComplete'] as bool?) ?? false,
      );

  final String email;
  final String name;
  final String? photoUrl;

  /// In paise, as stored by the backend.
  final int monthlyBudget;
  final bool onboardingComplete;

  String get displayName => name.isNotEmpty ? name : email.split('@').first;
}
