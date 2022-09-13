import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:pmvvm/pmvvm.dart';

import 'injection.dart';
import 'src/features/home/presentation/home_widget.dart';
import 'style/themes.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MVVM<ApplicationViewModel>(
      view: () => const _Application(),
      viewModel: getIt<ApplicationViewModel>(),
    );
  }
}

@Injectable()
class ApplicationViewModel extends ViewModel {
  ApplicationViewModel();
}

class _Application extends StatelessView<ApplicationViewModel> {
  /// Set [reactive] to [false] if you don't want the view to listen to the ViewModel.
  /// It's [true] by default.
  const _Application({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(context, viewModel) {
    return MaterialApp(
      title: 'Mobile ID',
      debugShowCheckedModeBanner: false,
      theme: defaultTheme,
      home: const HomeWidget(),
      routes: const {
        // '/onboarding': (_) => OnboardingWidget(),
        // '/home': (_) => HomePageActivity(),
        // '/notification': (_) => NotificationWidget(),
        // '/setup': (_) => SetupPage(),
        // '/profile': (_) => CardProfilePage(),
      },
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
