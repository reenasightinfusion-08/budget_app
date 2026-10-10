import 'package:flutter/material.dart';

import 'package:budget_frontend/core/widgets/app_button.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppButton(label: label, onPressed: onPressed);
}
