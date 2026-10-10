import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';

class AuthErrorText extends StatelessWidget {
  const AuthErrorText({super.key, this.screen});

  final AuthScreen? screen;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isMatch = screen == null || state.errorSource == screen;
          final error = isMatch ? (state.errorMessage ?? '') : '';

          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: 18.h),
            child: Text(error, style: AppTextStyle.error),
          );
        },
      );
}
