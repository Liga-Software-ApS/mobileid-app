import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/application/config_service.dart';
import 'package:mobileid/application/firebase_service.dart';
import 'package:mobileid/application/user_service.dart';
import 'package:mobileid/src/features/home/application/fetch_service.dart';
import 'package:mobileid/src/features/home/domain/auth_notification.dart';
import 'package:mobileid/src/features/onboarding/presentation/onboarding_widget.dart';
import 'package:pmvvm/pmvvm.dart';

import '../../../../toaster.dart';
import '../../auth/presentation/auth_widget.dart';
import '../../notification/presentation/notification_widget.dart';

@Injectable()
class HomeViewModel extends ViewModel {
  final IUserService _user;
  final IFetchService _fetch;
  final IConfigService _config;
  final FirebaseService _firebase;

  HomeViewModel(this._user, this._fetch, this._config, this._firebase);

  Future<List<AuthNotification>> get notifications async => await refresh();

  Future<bool> get requiresOnboarding async => await _user.isRegistered();

  auth() {
    _redirectToAuth();
  }

  // Optional
  @override
  Future<void> init() async {
    var isOnboarded = await _config.isOnboarded();
    if (!isOnboarded) _redirectToOnboarding();

    _firebase.checkPermissions();
    _firebase.registerMessageHandlers(_handleMessage);
  }

  Future ready() async {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const NotificationWidget()),
    // );
  }

  Future refresh() async {
    debugPrint("refreshing");

    var isOnboarded = await _config.isOnboarded();
    if (!isOnboarded) {
      _redirectToOnboarding();
      return;
    }

    // ignore: use_build_context_synchronously
    var t = AppLocalizations.of(context)!;
    try {
      var notifications = await _fetch.fetchManual();
      if (notifications == null) Toaster.toastError(t.apiUnknown);

      debugPrint("refreshed");

      if (notifications!.isEmpty) _showEmptyToast();

      if (notifications.length == 1) {
        _redirectToNotification(notifications.first.id!);
      } else {
        // TODO: figure out what to do with multiple notifications
      }
    } finally {}
  }

  toNotification(String id) {
    _redirectToNotification(id);
  }

  toOnboarding() {
    _redirectToOnboarding();
  }

  void _handleMessage(RemoteMessage message) {
    logDebug("Handling remote message");

    var type = message.data['type'];

    if (type != "auth") return;

    var id = message.data['id'];

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => NotificationWidget(id: id)));
  }

  _redirectToAuth() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const AuthWidget()));
  }

  _redirectToNotification(String id) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => NotificationWidget(id: id)));
  }

  _redirectToOnboarding() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const OnboardingWidget()));
  }

  void _showEmptyToast() {
    var t = AppLocalizations.of(context)!;

    Toaster.toastInfo(context, t.notificationsEmptyToast);
  }
}
