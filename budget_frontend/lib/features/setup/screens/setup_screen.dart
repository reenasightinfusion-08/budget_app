import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:budget_frontend/app/app_routes.dart';
import 'package:budget_frontend/core/constants/app_text_style.dart';
import 'package:budget_frontend/core/utils/app_formatters.dart';
import 'package:budget_frontend/core/utils/app_validators.dart';
import 'package:budget_frontend/core/widgets/app_button.dart';
import 'package:budget_frontend/core/widgets/app_text_field.dart';
import 'package:budget_frontend/core/widgets/sheet_scaffold.dart';
import 'package:budget_frontend/features/auth/bloc/auth_bloc.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/setup/widgets/setup_budget_card.dart';
import 'package:budget_frontend/features/setup/widgets/setup_quick_amounts.dart';

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

  void onBudgetChanged(String text) {
    final amount = AppFormatters.parseDigits(text);
    context.read<SetupBloc>().add(SetupBudgetAmountChanged(amount));
  }

  void selectAmount(int amount) {
    budgetController.text = AppFormatters.groupDigits(amount);
    context.read<SetupBloc>().add(SetupBudgetAmountChanged(amount));
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    context.read<SetupBloc>().add(SetupCompletedSubmitted(name: nameController.text.trim()));
  }

  @override
  Widget build(BuildContext context) => BlocListener<SetupBloc, SetupState>(
        listenWhen: (previous, current) =>
            previous.savedUser != current.savedUser && current.savedUser != null,
        listener: (context, state) {
          context.read<AuthBloc>().add(AuthUserUpdated(state.savedUser!));
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        },
        child: SheetScaffold(
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
              BlocBuilder<SetupBloc, SetupState>(
                builder: (context, state) => ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 36.h),
                  child: Padding(
                    padding: EdgeInsets.only(top: 18.h),
                    child: Text(state.errorMessage ?? '', style: AppTextStyle.error),
                  ),
                ),
              ),
              BlocBuilder<SetupBloc, SetupState>(
                builder: (context, state) => AppButton(
                  label: 'Start budgeting',
                  onPressed: submit,
                  isLoading: state.isSaving,
                ),
              ),
            ],
          ),
        ),
        ),
      );
}
