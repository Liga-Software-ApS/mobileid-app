import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobileid/src/widgets/confirm_widget.dart';
import 'package:mobileid/src/widgets/shell.dart';
import 'package:mobileid/style/themes.dart';
import 'package:pmvvm/pmvvm.dart';

import '../../../../injection.dart';
import 'notification_viewmodel.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationWidgetProps props;

  NotificationWidget({Key? key, required String id})
      : props = NotificationWidgetProps(id: id),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
        value: props,
        child: MVVM<NotificationViewModel>(
          view: () => const _NotificationView(),
          viewModel: getIt<NotificationViewModel>(),
        ));
  }
}

class NotificationWidgetProps {
  final String id;

  NotificationWidgetProps({required this.id});
}

class _NotificationView extends StatelessView<NotificationViewModel> {
  const _NotificationView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    // ignore: unused_local_variable
    var t = AppLocalizations.of(context)!;

    return Theme(
        data: elevatedTheme,
        child: Scaffold(
            body: scaffoldFixedBody(shrinkWrap: true, children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: viewModel.hasError
                ? _errorView(context, viewModel)
                : _defaultView(context, viewModel),
          ),
        ])));
  }

  Widget _defaultView(BuildContext context, NotificationViewModel viewModel) {
    var t = AppLocalizations.of(context)!;

    return ConfirmWidget(
      iconData: Icons.assignment_ind,
      title: t.notificationTitle,
      description: t.confirmSignIn(viewModel.subject, "the site"),
      onCompleted: viewModel.complete,
      onCanceled: viewModel.cancel,
    );
  }

  Widget _errorMessage(BuildContext context, NotificationViewModel viewModel) {
    var t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(48.0, 0, 48.0, 0),
      child: Text(
        t.notificationErrorDescription,
        style: Theme.of(context).textTheme.bodyText2,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _errorView(BuildContext context, NotificationViewModel viewModel) {
    // ignore: unused_local_variable
    var t = AppLocalizations.of(context)!;

    return Column(children: <Widget>[
      const Icon(Icons.error_outline, size: 64.0),
      const SizedBox(height: 20),
      _errorMessage(context, viewModel),
      const SizedBox(height: 40),
      ElevatedButton(
          onPressed: () async => {await viewModel.refresh()},
          child: const Text("Retry")),
      const SizedBox(height: 20),
      TextButton(
          onPressed: () async => {await viewModel.cancel()},
          child: const Text("Cancel")),
    ]);
  }
}
