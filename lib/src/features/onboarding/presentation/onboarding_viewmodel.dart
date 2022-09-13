import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/src/features/onboarding/application/onboarding_service.dart';
import 'package:mobileid/toaster.dart';
import 'package:pmvvm/pmvvm.dart';

import '../../auth/presentation/auth_widget.dart';

@Injectable()
class OnboardingViewModel extends ViewModel {
  final pageController = PageController(initialPage: 0);

  final IOnboardingService _service;

  bool hasPermissionsError = false;

  OnboardingViewModel(this._service);

  AppLocalizations get _t => AppLocalizations.of(context)!;

  Future allowNotification() async {
    logDebug("Allowing notifications");
    var success = await _service.checkPermissions();

    if (success) {
      _redirectToAuth();
    } else {
      hasPermissionsError = false;

      // ignore: use_build_context_synchronously
      Toaster.toastInfo(context, _t.notificationsPermissionRejected);
    }
  }

  // Optional
  @override
  Future<void> init() async {}

  // Optional
  @override
  void onBuild() {
    // A callback when the `build` method of the view is called.
  }

  Future ready() async {
    pageController.nextPage(
        duration: const Duration(milliseconds: 150), curve: Curves.ease);
  }

  Future rejectNotification() async {
    _redirectToAuth();
  }

  void skipNotification() {
    _redirectToAuth();
  }

  void _redirectToAuth() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const AuthWidget()));
    pageController.jumpTo(0);
  }
}
