import '../tlv/tlv.dart';

abstract class SmartCardConnection {
  Future close([String? message, bool isError = false]) async {
    throw UnimplementedError();
  }

  Future open() async {
    throw UnimplementedError();
  }

  Future<List<TLV>> send(List<int> buffer, [bool codeAtEnd = false]) async {
    return [TLV(0x00, 0x00, [])];
  }

  Future<List<int>> sendRaw(List<int> buffer) async {
    return [];
  }

  Future setStatus(String? statusMessage);
}
