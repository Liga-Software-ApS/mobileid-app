import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class FirebaseService extends IFirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  void Function(RemoteMessage)? handlerCache;

  @override
  Future<bool> checkPermissions() async {
    var settings = await _firebaseMessaging.requestPermission();

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        return true;
      // case AuthorizationStatus.provisional:
      //   return true;
      default:
        return false;
    }
  }

  @override
  getInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    return initialMessage;
  }

  @override
  getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // String get domain => _domain;

  @override
  init() async {}

  @override
  registerMessageHandlers(void Function(RemoteMessage)? handler) {
    handlerCache = handler;

    FirebaseMessaging.onMessage.listen(handler);
    FirebaseMessaging.onMessageOpenedApp.listen(handler);

    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  }

  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    debugPrint("message received in bg");
  }
}

abstract class IFirebaseService {
  Future<bool> checkPermissions();
  Future<RemoteMessage?> getInitialMessage();
  Future<String?> getToken();
  Future init();
  registerMessageHandlers(void Function(RemoteMessage)? handler);
}

class SharedPreferencesProvider {
  static SharedPreferencesProvider? _instance;

  SharedPreferencesProvider._(SharedPreferences sharedPreferences);

  static Future<SharedPreferencesProvider> getInstance() async {
    if (_instance == null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      _instance = SharedPreferencesProvider._(sharedPreferences);
    }
    return _instance!;
  }
}
