import '../connections/connection_interface.dart';

abstract class SmartCardInterface {
  Future<void> selectInterface(String reader) async {}
  Future<List<String>> listInterfaces();
  Future<SmartCardConnection> connect() async {
    throw Exception("should not happen");
  }

  Future<void> disconnect() async {}
}
