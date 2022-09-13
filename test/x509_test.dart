// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/src/features/auth/application/registration_service.dart';
import 'package:x509b/x509.dart';

void main() {
  test('Counter value should be incremented', () async {
    var pem = await File('test/efs.cer').readAsString();
    var iter = parsePem(pem);

    X509Certificate? cert = iter.first;

    var list = cert!.tbsCertificate.extensions;

    var sanExt =
        list!.where((ext) => ext.extnId.toString() == "subjectAltName");
    if (sanExt.isEmpty) {
      logInfo("Doesn't have SAN extensions");
      return null;
    }

    var names = sanExt.first.extnValue as GeneralNames;

    for (var name in names.names) {
      var p = name.contents;
      var seq = name.contents as ASN1Sequence;

      var oid = seq.elements?.first;
    }
  });

  group('subjectAlternateName', () {
    test('upnsan', () {
      var pem = File('test/efs.cer').readAsStringSync();
      var cert = parsePem(pem).single as X509Certificate;

      var list = cert.tbsCertificate.extensions;

      var sanExt =
          list!.where((ext) => ext.extnId.toString() == "subjectAltName");
      if (sanExt.isEmpty) {
        logInfo("Doesn't have SAN extensions");
        return null;
      }
      Iterable<GeneralName> relevantSans =
          (sanExt.first.extnValue as GeneralNames).names.where((san) =>
              san.choice == 0 || san.choice == 1); //0:other:upn, 1:rfc822:email

      var identity = findIdentityInSan(relevantSans);

      expect(identity, "sb@sb.local");
    });
  });
}
