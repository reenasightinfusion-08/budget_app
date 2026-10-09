import 'package:flutter_test/flutter_test.dart';

import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/auth/models/user_model.dart';
import 'package:budget_frontend/features/setup/bloc/setup_bloc.dart';
import 'package:budget_frontend/features/setup/services/profile_service.dart';

class FakeProfileService extends ProfileService {
  FakeProfileService() : super(ApiClient());

  int? savedPaise;

  @override
  Future<UserModel> saveSetup({required String name, required int monthlyBudgetPaise}) async {
    savedPaise = monthlyBudgetPaise;
    return UserModel(
      email: 'a@b.com',
      name: name,
      monthlyBudget: monthlyBudgetPaise,
      onboardingComplete: true,
    );
  }
}

void main() {
  late SetupBloc setupBloc;
  late FakeProfileService profileService;

  setUp(() {
    profileService = FakeProfileService();
    setupBloc = SetupBloc(profileService: profileService);
  });

  tearDown(() {
    setupBloc.close();
  });

  test('initial state is incomplete with zero budget', () {
    expect(setupBloc.state.budgetAmount, 0);
    expect(setupBloc.state.isComplete, false);
    expect(setupBloc.state.dailyAllowanceLabel, isNull);
  });

  test('updating budget amount calculates daily allowance label', () async {
    final expectation = expectLater(
      setupBloc.stream,
      emits(
        predicate<SetupState>((state) =>
            state.budgetAmount == 30000 &&
            state.dailyAllowanceLabel != null &&
            state.dailyAllowanceLabel!.contains('1,000')),
      ),
    );

    setupBloc.add(const SetupBudgetAmountChanged(30000));
    await expectation;
  });

  test('submitting setup completes profile', () async {
    setupBloc.add(const SetupBudgetAmountChanged(15000));

    final expectation = expectLater(
      setupBloc.stream,
      emitsThrough(
        predicate<SetupState>((state) =>
            state.isComplete &&
            state.profile?.name == 'Alex' &&
            state.profile?.monthlyBudget == 15000 &&
            state.savedUser?.onboardingComplete == true),
      ),
    );

    setupBloc.add(const SetupCompletedSubmitted(name: 'Alex'));
    await expectation;
    expect(profileService.savedPaise, 1500000);
  });
}
