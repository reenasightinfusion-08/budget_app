import 'package:flutter/material.dart';

import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

/// Legacy placeholder: Google auth errors are now displayed via toasts.
class AuthGoogleErrorText extends StatelessWidget {
  const AuthGoogleErrorText({super.key, this.screen});

  final AuthScreen? screen;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
