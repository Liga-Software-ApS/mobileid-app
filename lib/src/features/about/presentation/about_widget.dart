import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobileid/style/themes.dart';
import 'package:pmvvm/pmvvm.dart';

import '../../../../injection.dart';
import 'about_viewmodel.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MVVM<AboutViewModel>(
      view: () => const _AboutView(),
      viewModel: getIt<AboutViewModel>(),
    );
  }
}

class _AboutView extends StatelessView<AboutViewModel> {
  /// Set [reactive] to [false] if you don't want the view to listen to the ViewModel.
  /// It's [true] by default.
  const _AboutView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    // ignore: unused_local_variable
    var t = AppLocalizations.of(context)!;

    return Theme(
        data: elevatedTheme,
        child: Scaffold(
            appBar: AppBar(
              title: Text(t.appTitle),
            ),
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Center(

                        // width: double.infinity,
                        // height: double.infinity,
                        // color: Colors.red,
                        // margin: const EdgeInsets.only(left: 20, right: 20),
                        child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                          const Image(
                            image: AssetImage('assets/logos/liga.png'),
                            width: 120,
                          ),
                          TextButton(
                            onPressed: () => {},
                            child: Text(t.aboutLiga),
                          ),
                          const SizedBox(height: 20),
                          const Image(
                            image: AssetImage('assets/logos/alexandra.png'),
                            width: 200,
                          ),
                          TextButton(
                            onPressed: () => {},
                            child: Text(t.aboutAlx),
                          ),
                          const SizedBox(height: 20),
                          const Image(
                            image: AssetImage('assets/logos/cyberhub.png'),
                            width: 200,
                          ),
                          TextButton(
                            onPressed: () => {},
                            child: Text(t.aboutHub),
                          ),
                        ]))))));
  }
}
