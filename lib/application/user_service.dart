import 'package:injectable/injectable.dart';

abstract class IUserService {
  // String get domain;
  // String get url;

  // setDomain(String domain);
  // String getBackendURL();
  Future<bool> isRegistered();
}

@Injectable(as: IUserService)
class UserService extends IUserService {
  @override
  Future<bool> isRegistered() async {
    return false;
  }
}
