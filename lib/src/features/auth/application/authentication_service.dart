


class AuthenticationService {

  // @override
  // Future<List<AuthNotification>> fetchManual() async {
  //   return _fetchNewNotification();
  // }

  // Future<List<AuthNotification>> _httpGetNewNotifications(
  //     String? authToken) async {
  //   var domain = await _config.getBackendURL();
  //   var uri = Uri.parse(domain + "/notifications/");
  //   debugPrint("Fetching notifications at ${uri.toString()}");



  //   try {
  //     debugPrint("awaiting");
  //     var result = await http.Client().get(
  //     uri,
  //     headers: {
  //       'Content-type': 'application/json',
  //       'Authorization': "Bearer ${authToken ?? ""}",
  //     },
  //   );
    
  //     debugPrint(result.statusCode.toString());

  //     switch (result.statusCode) {
  //       case 403:
  //         throw UnauthorizedException("");
  //       default:
  //     }
  //     final List<AuthNotification> list = jsonDecode(result.body);

  //     debugPrint(
  //         "${result.statusCode}: ${String.fromCharCodes(result.bodyBytes)} ");

  //     return list;
  //   } on SocketException catch (e) {
  //     // debugPrint(e.toString());
  //     throw UnreachableException(e.toString());
  //   }
  // }
}