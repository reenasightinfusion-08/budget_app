import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/features/auth/providers/auth_provider.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((provider) => provider.isLoading);

    return AppButton(label: label, onPressed: onPressed, isLoading: isLoading);
  }
}
