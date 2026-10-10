import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

/// Shows a failed Google sign-in right under the Google button.
class AuthGoogleErrorText extends StatelessWidget {
  const AuthGoogleErrorText({super.key, this.screen});

  final AuthScreen? screen;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) =>
            previous.googleErrorMessage != current.googleErrorMessage ||
            previous.googleErrorSource != current.googleErrorSource,
        builder: (context, state) {
          final message = state.googleErrorMessage;
          final isMatch = screen == null || state.googleErrorSource == screen;
          if (message == null || !isMatch) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Text(message, textAlign: TextAlign.center, style: AppTextStyle.error),
          );
        },
      );
}
