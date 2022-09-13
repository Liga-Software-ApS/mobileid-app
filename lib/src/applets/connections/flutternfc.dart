import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:injectable/injectable.dart';

import '../apdu.dart';
import '../tlv/tlv.dart';
import 'connection_interface.dart';

@Injectable(as: SmartCardConnection)
class NfcConnection implements SmartCardConnection {
  NfcConnection();

  @override
  Future close([String? message, bool isError = false]) async {
    if (isError) {
      await FlutterNfcKit.finish(iosErrorMessage: message);
      return;
    }

    await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
  }

  @override
  Future open() async {
    try {
      // await FlutterNfcKit.poll(readIso14443A: false, readIso14443B: false, readIso15693: false, readIso18092: false);
      await FlutterNfcKit.poll();
    } catch (e) {
      await close();
      debugPrint(e.toString());
    }
  }

  @override
  Future<List<TLV>> send(List<int> buffer, [bool codeAtEnd = false]) async {
    debugPrint(">> ${hex.encode(buffer)}");
    var response = await FlutterNfcKit.transceive(buffer);
    debugPrint("<< ${hex.encode(response)}");

    return ApduResponse().fromList(response, codeAtEnd);
  }

  @override
  Future<List<int>> sendRaw(List<int> buffer) async {
    debugPrint(">> ${hex.encode(buffer)}");
    var response = await FlutterNfcKit.transceive(buffer);
    debugPrint("<< ${hex.encode(response)}");

    return response;
  }

  @override
  Future setStatus(String? statusMessage, [bool isError = false]) async {
    if (statusMessage == null) return;
    await FlutterNfcKit.setIosAlertMessage(statusMessage);
  }
}
