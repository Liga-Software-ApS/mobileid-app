import 'package:flutter/material.dart';
import 'package:pmvvm/pmvvm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mobileid/src/widgets/shell.dart';
import 'onboarding_viewmodel.dart';

class NotificationView extends StatelessView<OnboardingViewModel> {
  const NotificationView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    var t = AppLocalizations.of(context)!;

    return scaffoldFixedBody(
      children: <Widget>[
        Text(
          t.onboardingNotificationTitle,
          style: Theme.of(context).textTheme.headline1,
        ),
        Text(
          t.onboardingNotificationDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 64),
        if (!viewModel.hasPermissionsError)
          ElevatedButton(
            onPressed: () async => {
              FocusScope.of(context).unfocus(),
              await viewModel.allowNotification()
            },
            child: Text(
              t.onboardingNotificationButtonAllow,
            ),
          )
        else
          ElevatedButton(
            onPressed: () async => {
              FocusScope.of(context).unfocus(),
              viewModel.skipNotification()
            },
            child: Text(t.notificationsPermissionSkip),
          ),
        const SizedBox(height: 16),
        TextButton(
            onPressed: () async => {await viewModel.rejectNotification()},
            child: Text(t.onboardingNotificationButtonReject)),
      ],
    );
  }
}
