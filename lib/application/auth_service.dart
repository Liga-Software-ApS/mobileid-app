import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenService {
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: "authToken");
  }

  void saveToken(String token) async {
    await storage.write(key: "authToken", value: token);
  }
}
