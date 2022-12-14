import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mobileid/application/config_service.dart';
import 'package:mobileid/src/features/about/presentation/about_widget.dart';
import 'package:mobileid/src/features/home/presentation/home_widget.dart';
import 'package:mobileid/src/features/onboarding/presentation/onboarding_widget.dart';
import 'package:pmvvm/pmvvm.dart';

@Injectable()
class SettingsViewModel extends ViewModel {
  final IConfigService _config;

  SettingsViewModel(this._config);

  Future reset() async {
    await _config.reset();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeWidget()));
  }

  void toAbout() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AboutWidget()));
  }

  void toOnboard() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const OnboardingWidget()));
  }
}
