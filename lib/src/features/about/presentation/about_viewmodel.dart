import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mobileid/application/config_service.dart';
import 'package:mobileid/src/features/home/presentation/home_widget.dart';
import 'package:mobileid/src/features/onboarding/presentation/onboarding_widget.dart';
import 'package:pmvvm/pmvvm.dart';

@Injectable()
class AboutViewModel extends ViewModel {
  final IConfigService _config;

  AboutViewModel(this._config);

  Future reset() async {
    await _config.reset();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeWidget()));
  }

  void toOnboard() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const OnboardingWidget()));
  }
}
