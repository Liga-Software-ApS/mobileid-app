import 'package:mobileid/src/features/home/domain/auth_notification.dart';

abstract class INotificationRepository {
  Future addNotification(AuthNotification noti);

  Future<AuthNotification> getNext();
}

class NotificationRepository implements INotificationRepository {
  @override
  Future addNotification(noti) {
    throw UnimplementedError();
  }

  @override
  Future<AuthNotification> getNext() async {
    throw UnimplementedError();
  }
}
