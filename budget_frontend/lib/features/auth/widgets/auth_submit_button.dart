import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) =>
            AppButton(label: label, onPressed: onPressed, isLoading: state.isLoading),
      );
}
