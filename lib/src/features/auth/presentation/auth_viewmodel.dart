import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/application/auth_service.dart';
import 'package:mobileid/src/features/auth/application/registration_service.dart';
import 'package:mobileid/src/features/home/presentation/home_widget.dart';
import 'package:pmvvm/pmvvm.dart';

import '../../../../toaster.dart';

@Injectable()
class AuthViewModel extends ViewModel {
  final IRegistrationService _registration;

  bool isSimple = false;

  AuthViewModel(this._registration);

  void cancel() {
    toHome();
  }

  void complete(String pin) async {
    logDebug("Pin confirmed for auth: $pin");
    await _onPin(pin);
  }

  Future<void> onPin(String? pin) async {
    if (pin == null) return;

    try {
      await _onPin(pin);
      return;
    } catch (e) {
      logDebug("Credentials incorrect");
    }
  }

  void toHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeWidget()));
  }

  Future<void> _onPin(String pin) async {
    debugPrint("onPin");
    // var applet = await _cryptography.getApplet();

    // await applet.start();

    try {
      var nonce = await _registration.startRegistration(pin);

      var idToken = await _registration.completeRegistration(nonce, pin);

      AuthTokenService().saveToken(idToken!);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeWidget()));
    } on CertificateCredentialsInvalidException {
      rethrow;
    } on Exception {
      Toaster.toastError(AppLocalizations.of(context)!.apiUnknown);
    }
  }
}
