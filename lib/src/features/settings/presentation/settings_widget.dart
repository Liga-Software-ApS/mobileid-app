import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobileid/src/features/settings/presentation/settings_viewmodel.dart';
import 'package:pmvvm/pmvvm.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../../injection.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MVVM<SettingsViewModel>(
      view: () => const _SettingsView(),
      viewModel: getIt<SettingsViewModel>(),
    );
  }
}

class _SettingsView extends StatelessView<SettingsViewModel> {
  /// Set [reactive] to [false] if you don't want the view to listen to the ViewModel.
  /// It's [true] by default.
  const _SettingsView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    // ignore: unused_local_variable
    var t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MobileID'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text("Reset user"),
                onPressed: (ctx) async => await viewModel.reset(),
              ),
              // SettingsTile.switchTile(
              //   onToggle: (value) {},
              //   initialValue: true,
              //   leading: Icon(Icons.format_paint),
              //   title: Text('Enable custom theme'),
              // ),
            ],
          ),
          SettingsSection(
            title: const Text('Developer'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.developer_board),
                title: const Text("Onboard"),
                onPressed: (ctx) => viewModel.toOnboard(),
              ),
              // SettingsTile.switchTile(
              //   onToggle: (value) {},
              //   initialValue: true,
              //   leading: Icon(Icons.format_paint),
              //   title: Text('Enable custom theme'),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
