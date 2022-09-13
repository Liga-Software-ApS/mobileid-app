import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pcsc/flutter_pcsc.dart';
import 'package:loggy/loggy.dart';

import '../apdu.dart';
import '../tlv/tlv.dart';
import 'connection_interface.dart';

class PcScConnection implements SmartCardConnection {
  CardStruct card;

  PcScConnection(this.card);

  @override
  Future close([String? message, bool isError = false]) {
    throw UnimplementedError();
  }

  @override
  Future open() {
    throw UnimplementedError();
  }

  @override
  Future<List<TLV>> send(List<int> buffer, [bool codeAtEnd = false]) async {
    if (kDebugMode) logDebug(">> ${hex.encode(buffer)}");
    var response = await Pcsc.transmit(card, buffer);
    if (kDebugMode) logDebug("<< ${hex.encode(response)}");

    return ApduResponse().fromList(response, codeAtEnd);
  }

  @override
  Future<List<int>> sendRaw(List<int> buffer) async {
    debugPrint(">> ${hex.encode(buffer)}");
    var response = await Pcsc.transmit(card, buffer);
    debugPrint("<< ${hex.encode(response)}");

    return response;
  }

  @override
  Future setStatus(String? statusMessage) {
    throw UnimplementedError();
  }
}
