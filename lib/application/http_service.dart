import 'dart:convert';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:built_collection/built_collection.dart';
// ignore: depend_on_referenced_packages
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:dio_logging_interceptor/dio_logging_interceptor.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/application/config_service.dart';
import 'package:mobileid_api/mobileid_api.dart';

import 'auth_service.dart';

@Injectable(as: IHttpService)
class HttpService extends IHttpService {
  // RegistrationApi? _registrations;

  String domain = "http://localhost";
  String? authToken;
  final IConfigService _config;

  HttpService(this._config);

  @override
  Future<NotificationApi> get notifications async =>
      (await getClient(domain, authToken)).getNotificationApi();

  // NotificationApi? _notifications;

  @override
  Future<RegistrationApi> get registrations async =>
      (await getClient(domain, authToken)).getRegistrationApi();

  Future<MobileidApi> getClient(String domain, String? authToken) async {
    var domain = await _config.getBackendURL();
    var authToken = await AuthTokenService().getToken();

    final dioOptions = BaseOptions(
        baseUrl: domain,
        connectTimeout: 10000,
        sendTimeout: 10000,
        receiveTimeout: 10000);

    final dio = Dio(dioOptions);

    dio.interceptors.add(
      DioLoggingInterceptor(
        level: Level.body,
        compact: false,
      ),
    );

    var serializers =
        (standardSerializers.toBuilder()..add(Uint8ListSerializer())).build();

    logDebug("Generating client for $domain with token $authToken");

    var client = MobileidApi(dio: dio, serializers: serializers);
    if (authToken != null) client.setBearerAuth("bearerAuth", authToken);

    return client;
  }

  @override
  void setDomain(String domain) {
    this.domain = "https://$domain";
  }

  @override
  void setToken(String authToken) {
    this.authToken = authToken;
  }
}

abstract class IHttpService {
  Future<NotificationApi> get notifications;
  Future<RegistrationApi> get registrations;

  void setDomain(String domain);
  void setToken(String authToken);
}

class Uint8ListSerializer implements PrimitiveSerializer<Uint8List> {
  @override
  Iterable<Type> get types => BuiltList.of([Uint8List]);

  @override
  String get wireName => 'Uint8List';

  @override
  Uint8List deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return base64.decode(serialized.toString());
  }

  @override
  Object serialize(Serializers serializers, Uint8List object,
      {FullType specifiedType = FullType.unspecified}) {
    return base64.encode(object);
  }
}
