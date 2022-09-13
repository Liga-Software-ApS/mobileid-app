import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';

import '../apdu.dart';
import '../applet.dart';
import '../connections/connection_interface.dart';
import '../crypto_applet.dart';
import 'gids_cryptoapplet.dart';

@Injectable(as: Applet)
class GidsApplet implements Applet {
  @override
  SmartCardConnection conn;

  var selectGIDSApplet = Apdu()
      .cla(0x00)
      .ins(0xa4)
      .p1(0x04) // byName
      .p2(0x00) // FirstOrOnly
      .data(Applets.GIDS_AID)
      .build(0x00);

  GidsApplet(this.conn);

  @override
  Future<String> decryptText(List<String> decryptInformation, String pinInHex,
      bool isRequestFromServer) async {
    throw UnimplementedError();

    // untested... currently not in use
    // try {
    //   await conn.sendRaw(selectGIDSApplet);
    //   GIDSCryptoApplet gids = GIDSCryptoApplet(conn);
    //   await gids.authenticate(pinInHex.codeUnits);

    //   List<int> plaintextBuffer = [];

    //   // selectKey
    //   await gids.selectKey(
    //       [0x81], KeyUsage.Confidentiality, CtCrtAsymmetric.RSA_2048_PKCS);

    //   for (var cipher in decryptInformation) {
    //     var cipherBytes = hex.decode(cipher);
    //     // debugPrint("${hex.encode(cipherBytes)}");

    //     var plain = await gids.decrypt(cipherBytes);
    //     plaintextBuffer.addAll(plain);
    //   }

    //   // var test = decryptInformation
    //   //     .map((e) => hex.decode(e))
    //   //     .expand((element) => element)
    //   //     .toList();

    //   // await gids.decrypt(test);

    //   debugPrint("$plaintextBuffer");

    //   var encodedPlaintext = String.fromCharCodes(
    //       plaintextBuffer.where((element) => element != 0x00));
    //   debugPrint("Encoded: $encodedPlaintext");

    //   var decodedPlaintext = base64.decode(encodedPlaintext);
    //   debugPrint("Decoded: $decodedPlaintext");
    //   return utf8.decode(decodedPlaintext);
    // } catch (e) {
    //   debugPrint(e.toString());
    // } finally {
    //   // await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
    // }
  }

  @override
  Future<String> encryptText(String textToEncrypt, String pinInHex) async {
    await conn.send(selectGIDSApplet);
    GIDSCryptoApplet gids = GIDSCryptoApplet(conn);
    await gids.authenticate(pinInHex.codeUnits);

    var result = await gids.encrypt(textToEncrypt.codeUnits);

    return String.fromCharCodes(result);
  }

  @override
  Future end([String? message, bool isError = false]) async {
    await conn.close(message, isError = isError);
  }

  @override
  Future<String> getCertificateFromCard(String pinInHex) async {
    await conn.sendRaw(selectGIDSApplet);
    GIDSCryptoApplet gids = GIDSCryptoApplet(conn);
    await gids.authenticate(pinInHex.codeUnits);

    Stopwatch stopwatch = Stopwatch()..start();
    var buffer = await gids.getCertificate();
    stopwatch.stop();
    logDebug('getCertificate() executed in ${stopwatch.elapsed}');

    var cert = _unzipBufferIfNecessary(buffer);

    return base64Encode(cert);
  }

  @override
  Future<AuthPinResponse> loginWithCard(String pinInput) async {
    await conn.sendRaw(selectGIDSApplet);
    GIDSCryptoApplet gids = GIDSCryptoApplet(conn);
    await gids.authenticate(pinInput.codeUnits);

    return AuthPinResponse(true, pinInput);
  }

  @override
  Future<Uint8List> signBytes(Uint8List bytes, String pinInHex) async {
    await conn.sendRaw(selectGIDSApplet);
    GIDSCryptoApplet gids = GIDSCryptoApplet(conn);
    await gids.authenticate(pinInHex.codeUnits);

    var id = [
      0x30,
      0x31,
      0x30,
      0x0d,
      0x06,
      0x09,
      0x60,
      0x86,
      0x48,
      0x01,
      0x65,
      0x03,
      0x04,
      0x02,
      0x01,
      0x05,
      0x00,
      0x04,
      0x20
    ];

    var hashBytes = sha256.convert(bytes).bytes;

    Stopwatch stopwatch = Stopwatch()..start();

    await gids
        .selectKey([0x81], KeyUsage.DigitalSignature, DstCrt.RSA_2048_PKCS);
    var signature = await gids.sign(id + hashBytes);
    stopwatch.stop;
    logDebug('signText() executed in ${stopwatch.elapsed}');

    return signature as Uint8List;
  }

  @override

  /// Signs a string by using SHA256-RSA
  Future<String> signText(String textToSign, String pinInHex) async {
    throw Exception("please use signBytes");
  }

  @override
  Future start() async {
    await end();
    await conn.open();
  }

  List<int> _unzipBufferIfNecessary(List<int> buffer) {
    if (buffer[0] == 0x01 && buffer[1] == 0x00) {
      // decrypt
      int size = buffer[2] + buffer[3] * 0x100;
      logDebug(
          "Old size is ${buffer.length - 4} and new size is $size: ${hex.encode(buffer)}");
      var buf = buffer.skip(4).take(buffer.length - 4).toList();
      return ZLibCodec(gzip: false).decode(buf);
    } else {
      logDebug("No need for zlib inflation");
      return buffer;
    }
  }
}
