import 'package:flutter/material.dart';

import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

/// Legacy placeholder: error messages are now displayed via toasts.
class AuthErrorText extends StatelessWidget {
  const AuthErrorText({super.key, this.screen});

  final AuthScreen? screen;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
