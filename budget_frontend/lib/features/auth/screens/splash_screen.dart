import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/widgets/app_loader.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthStarted());
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current.status == AuthStatus.authenticated ||
            current.status == AuthStatus.unauthenticated,
        listener: (context, state) {
          final nextRoute =
              state.status == AuthStatus.authenticated ? AppRoutes.afterAuth(state.user) : AppRoutes.login;
          Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (route) => false);
        },
        child: const Scaffold(body: Center(child: AppLoader())),
      );
}
