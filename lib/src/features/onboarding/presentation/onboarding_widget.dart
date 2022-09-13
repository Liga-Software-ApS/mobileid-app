import 'package:flutter/material.dart';
import 'package:mobileid/src/features/onboarding/presentation/onboarding_notification_view.dart';
import 'package:pmvvm/pmvvm.dart';

import '../../../../injection.dart';

import 'onboarding_viewmodel.dart';
import 'onboarding_welcome_view.dart';

class OnboardingWidget extends StatelessWidget {
  const OnboardingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MVVM<OnboardingViewModel>(
      view: () => const _OnboardingView(),
      viewModel: getIt<OnboardingViewModel>(),
    );
  }
}

class _OnboardingView extends StatelessView<OnboardingViewModel> {
  const _OnboardingView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    return Scaffold(
        body: PageView(
          controller: viewModel.pageController,
          children: const [WelcomeView(), NotificationView()],
        ));
  }
}
