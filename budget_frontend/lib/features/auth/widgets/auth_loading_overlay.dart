import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/widgets/app_loading_overlay.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

/// Centred loader shown while an auth request is running. Place it last inside a [Stack].
class AuthLoadingOverlay extends StatelessWidget {
  const AuthLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) => previous.isLoading != current.isLoading,
        builder: (context, state) => AppLoadingOverlay(isLoading: state.isLoading),
      );
}
