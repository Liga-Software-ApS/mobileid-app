abstract class CryptoApplet {
  Future<List<int>> authenticate(List<int> buffer) async {
    throw UnimplementedError();
  }

  Future<List<int>> decrypt(List<int> buffer) async {
    throw UnimplementedError();
  }

  Future<List<int>> encrypt(List<int> buffer) async {
    throw UnimplementedError();
  }

  Future<bool> selectKey(List<int> keyRef, KeyUsage usage, int algo) {
    throw UnimplementedError();
  }

  Future<List<int>> sign(List<int> buffer) async {
    throw UnimplementedError();
  }

  Future<List<int>> verify(List<int> buffer) async {
    throw UnimplementedError();
  }
}

// ignore: constant_identifier_names
enum KeyUsage { Confidentiality, DigitalSignature, Authentication }
