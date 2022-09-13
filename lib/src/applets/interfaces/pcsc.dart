import 'package:flutter/foundation.dart';
import 'package:flutter_pcsc/flutter_pcsc.dart';

import '../connections/connection_interface.dart';
import '../connections/pcsc.dart';
import 'interface_interface.dart';

class PcScInterface implements SmartCardInterface {
  late int ctx;
  late CardStruct card;

  /// Private constructor
  PcScInterface._create();

  @override
  Future<SmartCardConnection> connect() async {
    return PcScConnection(card);
  }

  @override
  Future<void> disconnect() async {
    await Pcsc.cardDisconnect(card.hCard, PcscDisposition.resetCard);
    await _clean();
  }

  @override
  Future<List<String>> listInterfaces() async {
    return await Pcsc.listReaders(ctx);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> selectInterface(String reader) async {
    debugPrint("selecting interface");
    card =
        await Pcsc.cardConnect(ctx, reader, PcscShare.shared, PcscProtocol.any);
    debugPrint("card set and connected: $card");
  }

  Future<bool> _clean() async {
    await Pcsc.releaseContext(ctx);

    return true;
  }

  Future<bool> _init() async {
    ctx = await Pcsc.establishContext(PcscSCope.user);

    return true;
  }

  /// Public factory
  static Future<PcScInterface> create() async {
    // Call the private constructor
    var component = PcScInterface._create();

    // Do initialization that requires async
    await component._init();

    // Return the fully initialized object
    return component;
  }
}
