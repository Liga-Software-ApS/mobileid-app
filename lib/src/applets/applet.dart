import 'dart:typed_data';

import 'package:mobileid/src/applets/connections/connection_interface.dart';

abstract class Applet {
  late SmartCardConnection conn;

  Future<String> decryptText(List<String> decryptInformation, String pinInHex,
      bool isRequestFromServer);

  Future<String> encryptText(String textToEncrypt, String pinInHex);

  Future end([String? message, bool isError = false]);

  Future<String> getCertificateFromCard(String pinInHex);
  Future<AuthPinResponse> loginWithCard(String pinInput);

  Future<Uint8List> signBytes(Uint8List bytes, String pinInHex);

  Future<String> signText(String textToSign, String pinInHex);

  Future start();
}

class AuthPinResponse {
  bool isCorrect;
  String pinInHex;

  AuthPinResponse(this.isCorrect, this.pinInHex);
}
