class UserModel {
  const UserModel({required this.email});

  final String email;

  String get displayName => email.split('@').first;
}
