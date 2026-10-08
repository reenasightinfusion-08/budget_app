import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/features/setup/providers/setup_provider.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.select<SetupProvider, String>((provider) => provider.profile?.name ?? '');

    return Text('Hi, $name', style: AppTextStyle.title);
  }
}
