import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SetupBloc, SetupState>(
        builder: (context, state) =>
            Text('Hi, ${state.profile?.name ?? ''}', style: AppTextStyle.title),
      );
}
