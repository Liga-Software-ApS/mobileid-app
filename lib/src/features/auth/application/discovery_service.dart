import 'package:basic_utils/basic_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';

@Injectable(as: IDiscoveryService)
class DiscoveryService implements IDiscoveryService {
  @override
  Future<String> getDomain(String email) async {
    var domain = email.split("@")[1];

    var record = "_mobileid._tcp.$domain";

    var records = await DnsUtils.lookupRecord(record, RRecordType.SRV);

    if (records != null) {
      logInfo(records);
      var mobileIdDomain = records.map((e) => e.data.split(" ")).map((e) {
        var domain = e[3];
        var port = e[2];

        return "${domain.substring(0, domain.length - 1)}:$port/mobileid";
      }).first;

      return mobileIdDomain;
    }

    throw Exception("No config found");
  }
}

abstract class IDiscoveryService {
  Future<String> getDomain(String email);
}
