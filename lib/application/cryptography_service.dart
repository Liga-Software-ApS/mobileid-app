import 'package:injectable/injectable.dart';

import '../src/applets/applet.dart';

abstract class ICryptographyService {
  // String get domain;
  // String get url;

  // setDomain(String domain);
  // String getBackendURL();
  Future<Applet> getApplet();
}

@Injectable(as: ICryptographyService)
class CryptographyService extends ICryptographyService {
  final Applet _applet;

  CryptographyService(this._applet);

  @override
  Future<Applet> getApplet() async {
    return _applet;
  }
}
