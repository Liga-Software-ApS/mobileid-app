import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pmvvm/pmvvm.dart';

import '../../../../injection.dart';
import '../../settings/presentation/settings_widget.dart';
import 'home_viewmodel.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MVVM<HomeViewModel>(
      view: () => const _HomeView(),
      viewModel: getIt<HomeViewModel>(),
    );
  }
}

class _HomeView extends StatelessView<HomeViewModel> {
  /// Set [reactive] to [false] if you don't want the view to listen to the ViewModel.
  /// It's [true] by default.
  const _HomeView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    var t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        leading: GestureDetector(
          onTap: () {
            _toSettings(context);
          },
          child: const Icon(
            Icons.settings, // add custom icons also
          ),
        ),
      ),
      body: RefreshIndicator(
          displacement: 250,
          backgroundColor: Theme.of(context).backgroundColor,
          color: Theme.of(context).iconTheme.color,
          strokeWidth: 3,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: () async {
            // await Future.delayed(Duration(milliseconds: 1500));
            await viewModel.refresh();
            // setState(() {
            //   itemCount = itemCount + 1;
            // });
          },
          child: ListView(shrinkWrap: false, children: [
            Center(
                heightFactor: 4.5,
                widthFactor: 5,
                child: _home(context, viewModel))
          ])),
    );
  }

  Widget _home(BuildContext context, HomeViewModel viewModel) {
    var t = AppLocalizations.of(context)!;

    return Column(children: <Widget>[
      const Icon(Icons.vpn_key, size: 64.0),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.fromLTRB(48.0, 0, 48.0, 0),
        child: Text(
          t.homeDescription,
          style: Theme.of(context).textTheme.bodyText1,
          // overflow: TextOverflow.visible,
          // textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
      ),
      // const _ToOnboardingView(),
      const SizedBox(height: 20),
      // ElevatedButton(
      //     onPressed: () async => {await viewModel.auth()},
      //     child: const Text("Auth")),
      // ElevatedButton(
      //     onPressed: () async => {await viewModel.toNotification("id")},
      //     child: const Text("Notifications")),
      // ElevatedButton(
      //     onPressed: () async => {await viewModel.toOnboarding()},
      //     child: const Text("Onboarding")),
      // ElevatedButton(
      //     onPressed: () async => {await viewModel.auth()},
      //     child: const Text("Stop"))
    ]);
  }

  _toSettings(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsWidget()));
  }
}
