import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobileid/src/widgets/confirm_widget.dart';
import 'package:mobileid/src/widgets/shell.dart';
import 'package:pmvvm/pmvvm.dart';

import '../../../../injection.dart';
import '../../../../style/themes.dart';
import 'auth_viewmodel.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MVVM<AuthViewModel>(
      view: () => const _AuthView(),
      viewModel: getIt<AuthViewModel>(),
    );
  }
}

class _AuthView extends StatelessView<AuthViewModel> {
  const _AuthView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    return Theme(
        data: elevatedTheme,
        child: Scaffold(
            body: scaffoldFixedBody(children: <Widget>[
          _defaultView(context, viewModel),
        ])));
  }

  Widget _defaultView(BuildContext context, AuthViewModel viewModel) {
    var t = AppLocalizations.of(context)!;

    return ConfirmWidget(
      iconData: Icons.assignment,
      title: t.authTitle,
      description: t.authDescription,
      onCompleted: viewModel.complete,
      onCanceled: viewModel.cancel,
    );
  }

  // Widget _errorView(BuildContext context, AuthViewModel viewModel) {
  //   return Column(children: <Widget>[
  //     const Icon(Icons.error_outline, size: 64.0),
  //     const SizedBox(height: 20),
  //     // _errorMessage(context, viewModel),
  //     const SizedBox(height: 40),
  //     ElevatedButton(onPressed: () async => {}, child: const Text("Retry")),
  //     const SizedBox(height: 20),
  //     TextButton(onPressed: () async => {}, child: const Text("Cancel")),
  //   ]);
  // }
}
