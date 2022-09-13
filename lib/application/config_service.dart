import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  static SharedPreferencesProvider? _instance;
  final SharedPreferences _sharedPreferences;

  static Future<SharedPreferencesProvider> getInstance() async {
    if (_instance == null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      _instance = SharedPreferencesProvider._(sharedPreferences);
    }
    return _instance!;
  }

  SharedPreferencesProvider._(SharedPreferences sharedPreferences)
      : _sharedPreferences = sharedPreferences;
}

abstract class IConfigService {
  // String get domain;
  // String get url;

  setDomain(String domain);
  Future<String> getBackendURL();

  setOnboarded(bool value);
  Future<bool> isOnboarded();

  Future<bool> reset();
}

@Injectable(as: IConfigService)
class ConfigService extends IConfigService {
  // String get domain => _domain;

  @override
  Future<bool> setDomain(String domain) async {
    var prefs = await SharedPreferencesProvider.getInstance();
    return await prefs._sharedPreferences.setString('domain', domain);
  }

  @override
  Future<String> getBackendURL() async {
    var prefs = await SharedPreferencesProvider.getInstance();
    return "https://${prefs._sharedPreferences.getString('domain')}";
  }

  // Onboarding

  static const String onboardingKey = "onboarding";

  @override
  Future<bool> isOnboarded() async {
    var prefs = await SharedPreferencesProvider.getInstance();
    return prefs._sharedPreferences.getBool(onboardingKey) ?? false;
  }

  @override
  Future<bool> setOnboarded(bool value) async {
    var prefs = await SharedPreferencesProvider.getInstance();
    return await prefs._sharedPreferences.setBool(onboardingKey, value);
  }

  @override
  Future<bool> reset() async {
    await setOnboarded(false);

    return true;
  }
}
