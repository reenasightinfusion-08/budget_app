import 'package:flutter/material.dart';

import 'package:budget_frontend/app/app_controllers.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: setupController,
        builder: (context, _) =>
            Text('Hi, ${setupController.profile?.name ?? ''}', style: AppTextStyle.title),
      );
}
