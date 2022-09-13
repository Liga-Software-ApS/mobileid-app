import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobileid_api/mobileid_api.dart';

import '../../../../application/cryptography_service.dart';
import '../../../../application/http_service.dart';
import '../../auth/application/registration_service.dart';

abstract class INotificationService {
  Future<void> confirm(String? id, Uint8List payload, String pin);

  Future<SignInNotification> get(String id);
  Future<void> reject(SignInNotification notification);
}

class NotificationDetails {}

@Injectable(as: INotificationService)
class NotificationService implements INotificationService {
  final IHttpService _http;
  final ICryptographyService _cryptography;

  NotificationService(this._http, this._cryptography);

  @override
  Future<void> confirm(String? id, Uint8List payload, String pin) async {
    await _confirm(id!, payload, pin);
  }

  @override
  Future<SignInNotification> get(String id) async {
    return await _fetch(id);
  }

  @override
  Future<void> reject(SignInNotification notification) {
    // TODO: implement reject
    throw UnimplementedError();
  }

  Future<void> _confirm(String id, Uint8List payload, String pin) async {
    var signedNonce = await _sign(payload, pin);

    var request = NotificationConfirmationRequest((builder) => builder
      ..id = id
      ..signedPayload = signedNonce);

    var http = await _http.notifications;
    await http.putNotificationResponse(
      notificationConfirmationRequest: request,
    );
  }

  Future<SignInNotification> _fetch(String id) async {
    var request = NotificationRetrievalRequest((builder) => builder..id = id);

    var http = await _http.notifications;
    var response =
        await http.getNotification(notificationRetrievalRequest: request);

    return response.data!;
  }

  Future<Uint8List> _sign(List<int> nonce, String pin) async {
    debugPrint("onPin");
    var applet = await _cryptography.getApplet();

    await applet.start();

    var pinResponse = await applet.loginWithCard(pin);

    if (!pinResponse.isCorrect) {
      throw CertificateCredentialsInvalidException("PIN incorrect");
    }

    var signature = await applet.signBytes(nonce as Uint8List, pin);

    await applet.end();

    return signature;
  }
}
