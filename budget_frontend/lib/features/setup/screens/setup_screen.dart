import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/utils/app_validators.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/setup/providers/setup_provider.dart';
import 'package:budget_frontend/features/setup/widgets/setup_budget_card.dart';
import 'package:budget_frontend/features/setup/widgets/setup_quick_amounts.dart';
import 'package:budget_frontend/features/setup/widgets/setup_sample_toggle.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final budgetController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    budgetController.dispose();
    super.dispose();
  }

  void onBudgetChanged(String text) =>
      context.read<SetupProvider>().setBudget(AppFormatters.parseDigits(text));

  void selectAmount(int amount) {
    budgetController.text = AppFormatters.groupDigits(amount);
    context.read<SetupProvider>().setBudget(amount);
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    context.read<SetupProvider>().completeSetup(name: nameController.text.trim());
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) => SheetScaffold(
        title: 'Hi, I’m Budgie',
        subtitle: 'Two quick answers and I’ll start counting for you.',
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
                child: Text('What should I call you?', style: AppTextStyle.fieldLabel),
              ),
              AppTextField(
                controller: nameController,
                hint: 'Your first name',
                icon: Icons.person_outline_rounded,
                validator: AppValidators.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.givenName],
                maxLength: 24,
              ),
              18.verticalSpace,
              SetupBudgetCard(controller: budgetController, onChanged: onBudgetChanged),
              18.verticalSpace,
              SetupQuickAmounts(onSelected: selectAmount),
              18.verticalSpace,
              const SetupSampleToggle(),
              54.verticalSpace,
              AppButton(label: 'Start budgeting', onPressed: submit),
            ],
          ),
        ),
      );
}
