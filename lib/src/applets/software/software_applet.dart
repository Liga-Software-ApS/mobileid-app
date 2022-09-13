import 'dart:convert';

// import 'package:asn1lib/asn1lib.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobileid/src/applets/connections/connection_interface.dart';

import '../applet.dart';

// @Injectable(as: Applet)
class SoftwareApplet implements Applet {
  @override
  late SmartCardConnection conn;

  SoftwareApplet();

  @override
  Future<String> decryptText(List<String> decryptInformation, String pinInHex,
      bool isRequestFromServer) {
    throw UnimplementedError();
  }

  @override
  Future<String> encryptText(String textToEncrypt, String pinInHex) {
    throw UnimplementedError();
  }

  @override
  Future end([String? message, bool isError = false]) async {}

  @override
  Future<String> getCertificateFromCard(String pinInHex) async {
    debugPrint("software: getCertificateFromCard");
    var certString = await rootBundle.loadString('assets/simon.crt');

    return certString;
  }

  @override
  Future<AuthPinResponse> loginWithCard(String pinInput) async {
    if (pinInput != "123456") {
      return AuthPinResponse(false, pinInput);
    }

    return AuthPinResponse(true, "123456");
  }

  @override
  Future<Uint8List> signBytes(Uint8List bytes, String pinInHex) async {
    var byteData = await rootBundle.load('assets/simon-key.der');
    var key = CryptoUtils.rsaPrivateKeyFromDERBytesPkcs1(
        byteData.buffer.asUint8List());
    var signature = CryptoUtils.rsaSign(key, Uint8List.fromList(bytes));

    return signature;
  }

  @override
  Future<String> signText(String textToSign, String pinInHex) async {
    return const Base64Encoder()
        .convert(await signBytes(textToSign.codeUnits as Uint8List, pinInHex));
  }

  @override
  Future start() async {}
}
