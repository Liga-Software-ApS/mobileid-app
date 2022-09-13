import 'package:injectable/injectable.dart';
import 'package:mobileid/application/http_service.dart';
import 'package:mobileid_api/mobileid_api.dart';

@Injectable(as: IFetchService)
class FetchService implements IFetchService {
  final IHttpService _http;

  FetchService(this._http);

  @override
  Future<List<SignInNotification>?> fetchManual() async {
    var http = await _http.notifications;
    var list = await http.listNotifications();
    return list.data?.notifications?.toList();
  }
}

abstract class IFetchService {
  Future<List<SignInNotification>?> fetchManual();
}
