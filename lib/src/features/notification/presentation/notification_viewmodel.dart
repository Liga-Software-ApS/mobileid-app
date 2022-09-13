import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mobileid/toaster.dart';
import 'package:mobileid_api/mobileid_api.dart' as api;

import 'package:pmvvm/pmvvm.dart';

import '../../home/presentation/home_widget.dart';
import '../application/notification_service.dart';
import 'notification_widget.dart';

@Injectable()
class NotificationViewModel extends ViewModel {
  late NotificationWidgetProps props;

  final INotificationService _notification;

  NotificationViewModel(this._notification);

  @override
  Future<void> init() async {
    props = context.fetch<NotificationWidgetProps>();

    refresh();
  }

  Future<void> cancel() async {
    Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeWidget()));
  }

  Future<void> complete(String pin) async {
    try {
      _notification.confirm(_not!.id, _not!.payload, pin);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeWidget()));
    } catch (e) {
      Toaster.toastError(e.toString());
    }
  }

  Future<void> refresh() async {
    try {
      var not = await _notification.get(props.id);
      _not = not;
      hasError = false;
      notifyListeners();
    } catch (e) {
      Toaster.toastError(e.toString());
      hasError = true;
    }
  }

  bool hasError = true;

  api.SignInNotification? _not;

  String get subject => _not?.subject ?? "unknown";
  // String get origin => _not?.origin ?? "unknown";

  final pinController = TextEditingController();
  bool isComplex = false;

  bool get readyToSubmit => pinController.text.length == 4;


}
