import 'package:flutter/material.dart';
import 'package:mobileid/src/widgets/shell.dart';
import 'package:pmvvm/pmvvm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'onboarding_viewmodel.dart';

class WelcomeView extends StatelessView<OnboardingViewModel> {
  /// Set [reactive] to [false] if you don't want the view to listen to the ViewModel.
  /// It's [true] by default.
  const WelcomeView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    var t = AppLocalizations.of(context)!;

    return scaffoldFixedBody(
      shrinkWrap: true,
      children: [
        Text(
          t.onboardingWelcomeTitle,
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox(height: 16),
        Text(
          t.onboardingWelcomeDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 64),
        ElevatedButton(
                // color: LigaColors.Secondary,
                onPressed: () async =>
                    {FocusScope.of(context).unfocus(), await viewModel.ready()},
                // shape: Theme.of(context).buttonTheme.shape,
                child: Text(
                  t.onboardingWelcomeButton,
                ),
              ),
      ],
    // )
    );
  }
}
