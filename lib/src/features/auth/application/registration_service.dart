import 'dart:convert';

// accept because of dependency confusion with git packages
// ignore: depend_on_referenced_packages
import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/application/cryptography_service.dart';
import 'package:mobileid/application/http_service.dart';
import 'package:mobileid_api/mobileid_api.dart';
import 'package:x509b/x509.dart';

import '../../../../application/config_service.dart';
import '../../../../application/firebase_service.dart';
import 'discovery_service.dart';

String? extractOtherUPN(GeneralName san) {
  var seq = ASN1Sequence.fromBytes(san.contents.encodedBytes);
  // var seq = san.contents as ASN1Sequence;

  if (seq.elements.length != 2) {
    logInfo("Not a sequence we expect");
    return null;
  }

  logInfo("iter");
  var seqiter = seq.elements.iterator;

  seqiter.moveNext();
  var oid = seqiter.current;

  logInfo(oid.valueBytes());
  if (!listEquals(oid.valueBytes(), [43, 6, 1, 4, 1, 130, 55, 20, 2, 3])) {
    logInfo("No UPN OID");
    return null;
  }

  seqiter.moveNext();
  var utf8str = ASN1UTF8String.fromBytes(seqiter.current.valueBytes());

  return utf8str.utf8StringValue;
}

String? extractSAN(X509Certificate cert) {
  var ext = cert.tbsCertificate.extensions;
  if (ext == null) {
    logInfo("Doesn't have extensions");
    return null;
  }

  var sanExt = ext.where((ext) => ext.extnId.toString() == "subjectAltName");
  if (sanExt.isEmpty) {
    logInfo("Doesn't have SAN extensions");
    return null;
  }

  Iterable<GeneralName> relevantSans = (sanExt.first.extnValue as GeneralNames)
      .names
      .map((san) => san) //0:other:upn, 1:rfc822:email
      .where((san) => san.choice == 0 || san.choice == 1);

  var identity = findIdentityInSan(relevantSans);

  return identity;
}

String? findIdentityInSan(Iterable<GeneralName> sans) {
  var identities = [];

  for (var san in sans) {
    switch (san.choice) {
      case 0: // get other
        try {
          var upn = extractOtherUPN(san);
          identities.add(upn);
        } on Exception {
          logInfo("Found other SAN, could no parse");
        }
        break;
      case 1:
        var value = san.toString();
        identities.add(value.split(":").last);
        break;
    }
  }

  logInfo("Found ${identities.length} identities on card, using first one");

  return identities.first;

  // throw CertificateIdentityParsingException("No valid SAN found");
}

class CertificateCredentialsInvalidException implements Exception {
  String cause;
  CertificateCredentialsInvalidException(this.cause);
}

class CertificateExpiredException implements Exception {
  String cause;
  CertificateExpiredException(this.cause);
}

class CertificateIdentityParsingException implements Exception {
  String cause;
  CertificateIdentityParsingException(this.cause);
}

class CertificateInvalidException implements Exception {
  String cause;
  CertificateInvalidException(this.cause);
}

class CertificateRetrievalException implements Exception {
  String cause;
  CertificateRetrievalException(this.cause);
}

abstract class IRegistrationService {
  Future<String?> completeRegistration(Uint8List nonce, String pin);
  Future<Uint8List> startRegistration(String pin);
}

@Injectable(as: IRegistrationService)
class RegistrationService extends IRegistrationService {
  final IConfigService _config;
  final IDiscoveryService _discoveryService;
  final FirebaseService _firebaseService;
  final ICryptographyService _cryptographyService;

  final IHttpService _http;

  RegistrationService(this._http, this._config, this._discoveryService,
      this._firebaseService, this._cryptographyService);

  @override
  Future<String?> completeRegistration(Uint8List nonce, String pin) async {
    logInfo("Completing registration for session: $nonce");

    // var decodedNonce = const Base64Decoder().convert(nonce);
    // var decodedNonceString = String.fromCharCodes(decodedNonce);

    var applet = await _cryptographyService.getApplet();

    try {
      var token = await _firebaseService.getToken();
      var signedNonce = await applet.signBytes(nonce, pin);

      var response = await _completeRegistration(nonce, signedNonce, token);

      logInfo(
          "Completed registration for session: $nonce and got token: $response");
      await _config.setOnboarded(true);

      return response;
    } catch (e) {
      debugPrint("Registration failed: ${e.toString()}");
      await applet.end("Registration confirmation failed", true);
      rethrow;
    } finally {
      await applet.end();
    }
  }

  // Future refreshToken(NotificationToken notificationToken) async {}

  Uint8List int32bytes(int value) =>
      Uint8List(4)..buffer.asInt32List()[0] = value;

  @override
  Future<Uint8List> startRegistration(String pin) async {
    debugPrint("Registering...");
    var applet = await _cryptographyService.getApplet();

    await applet.start();

    var pinResponse = await applet.loginWithCard(pin);

    if (!pinResponse.isCorrect) {
      throw CertificateCredentialsInvalidException("PIN incorrect");
    }

    String? encodedCert;
    X509Certificate? cert;
    try {
      await applet.conn
          .setStatus("Reading certificate"); // TODO: use l10n string

      var certPemContent = await applet.getCertificateFromCard("");
      logInfo("got certBytes $certPemContent");

      var d =
          "-----BEGIN CERTIFICATE-----\n$certPemContent\n-----END CERTIFICATE-----\n";

      // logInfo("got cert: $certPemContent");

      var iter = parsePem(d);

      var certBytes = base64.decode(certPemContent);
      logInfo("got certBytes $certBytes");
      var certB64String = base64.encode(certBytes);
      // logInfo("got cert2");
      // var encodedCert =Base64Encoder().convert());
      //  logInfo("got cert 4");
      logInfo("got encodedCert $certB64String");
      encodedCert = certB64String;
      cert = iter.first;

      var notAfter = cert?.tbsCertificate.validity?.notAfter;
      var notBefore = cert?.tbsCertificate.validity?.notBefore;

      var now = DateTime.now();

      if (notAfter == null || notBefore == null) {
        logDebug("No validity period");
        throw CertificateInvalidException("No validity period");
      }

      if (now.isAfter(notAfter) || now.isBefore(notBefore)) {
        logDebug("Validity not valid");
        throw CertificateInvalidException("Validity not valid");
      }

      // certData = X509Utils.x509CertificateFromPem(d);
    } on Exception catch (e) {
      logError("Couldn't read cert: ${e.toString()}");
      throw CertificateInvalidException("No certficate");
    }

    String? subject;
    try {
      subject = extractSAN(cert!);
      logInfo("SAN: $subject");
    } catch (e) {
      logError("Couldn't read subject: ${e.toString()}");
      throw CertificateInvalidException("Cert has no SAN");
    }

    await applet.conn.setStatus("Found $subject");

    var domain = await _discoveryService.getDomain(subject!);
    _config.setDomain(domain);
    debugPrint("Config Domain: $domain");
    _http.setDomain(domain);

    var timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    await applet.conn.setStatus("Securely registering you");

    var tagToSign = Uint8List.fromList(timestamp.toString().codeUnits);
    logInfo("Signing bytes: $tagToSign");
    var signature = await applet.signBytes(tagToSign, pin);

    try {
      var nonce = await _startRegistration(encodedCert, timestamp, signature);
      logInfo("Registration started for session: $nonce");
      return nonce;
    } catch (e) {
      logError(e.toString());
      await applet.end("Registration failed", true);
      rethrow;
    }
  }

  Future<String?> _completeRegistration(
      Uint8List nonce, Uint8List signedNonce, String? token) async {
    var request = CompleteRegistrationRequest((builder) => builder
      ..firebaseToken = token
      ..challenge = nonce
      ..signedNonce = signedNonce);

    var http = await _http.registrations;
    var response =
        await http.completeRegister(completeRegistrationRequest: request);

    return response.data!.idToken;
  }

  Future<Uint8List> _startRegistration(
      String certPem, int timestamp, Uint8List signature) async {
    var startRegistrationRequest = StartRegistrationRequest((builder) => builder
      ..certificate = base64.decode(certPem)
      ..signature = signature
      ..timestamp = timestamp);

    var http = await _http.registrations;
    logDebug("StartRegistrationRequest");
    var response = await http.startRegister(
        startRegistrationRequest: startRegistrationRequest);
    logDebug(
        "StartRegistrationRequest came back with status ${response.statusCode}");

    return response.data!.challenge;
  }
}
