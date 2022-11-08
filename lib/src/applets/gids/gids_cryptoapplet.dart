// ignore_for_file: non_constant_identifier_names

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/src/applets/tlv/tlv.dart';
import 'package:quiver/iterables.dart';
import 'package:tuple/tuple.dart';

import '../apdu.dart';
import '../connections/connection_interface.dart';
import '../crypto_applet.dart';

Function eq = const ListEquality().equals;

class Command {
  static int GENERAL_AUTHENTICATE = 0x87;
}

class CtCrtAsymmetric {
  static int RSA_1024_PKCS = 0x46;
  static int RSA_2048_PKCS = 0x47;
  static int RSA_3072_PKCS = 0x48;
  static int RSA_4096_PKCS = 0x49;
}

class CtCrtSymmetric {
  static int AES_CBC_128 = 0x43;
  static int AES_CBC_192 = 0x44;
  static int AES_CBC_256 = 0x45;
}

class DstCrt {
  static int RSA_1024_PKCS = 0x56;
  static int RSA_2048_PKCS = 0x57;
  static int RSA_3072_PKCS = 0x58;
  static int RSA_4096_PKCS = 0x59;
}

class GidsCmapfile extends Gidsfile {
  List<GidsCmapRecord> records = [];

  GidsCmapfile(List<int> bytes) : super(bytes) {
    var recordLength = GidsCmapRecord.length();
    var recordsCount = (bytes.length / GidsCmapRecord.length()).floor();

    for (var i = 0; i < recordsCount; i++) {
      logDebug("Loading Cmap ${i + 1}/$recordsCount");

      // skip 2 byte for fileid, 1 for length
      var recordBytes =
          bytes.skip((i * recordLength)).take(recordLength).toList();
      var record = GidsCmapRecord(recordBytes);
      logDebug("Record: $record");
      records.add(record);
    }
  }
}

class GidsCmapRecord {
  static const int maxContainerNameLength = 39;

  late Uint8List szGuid;
  late int flags;
  late int reserved;
  late Uint8List sigKeySizeBits; // 2 byte
  late Uint8List keyExchangeKeySizeBits; //2 byte

  GidsCmapRecord(List<int> bytes) {
    szGuid = Uint8List.fromList(bytes
        .take(2 * (maxContainerNameLength + 1))
        .where((i) => i != 0x00)
        .toList());
    flags = bytes.skip(2 * (maxContainerNameLength + 1)).take(1).first;
    reserved = bytes.skip(2 * (maxContainerNameLength + 1) + 1).take(1).first;
    sigKeySizeBits = Uint8List.fromList(
        bytes.skip(2 * (maxContainerNameLength + 1) + 1 + 1).take(2).toList());
    keyExchangeKeySizeBits = Uint8List.fromList(bytes
        .skip(2 * (maxContainerNameLength + 1) + 1 + 1 + 2)
        .take(2)
        .toList());
  }

  @override
  String toString() {
    return "Guid:${String.fromCharCodes(szGuid)}\n"
        "Flags:${hex.encode([flags])}\n"
        "Reserved:${hex.encode([reserved])}\n"
        "sigKeySizeBits:${hex.encode(sigKeySizeBits)}\n"
        "keyExchangeKeySizeBits:${hex.encode(keyExchangeKeySizeBits)}\n";
  }

  static int length() => 2 * (maxContainerNameLength + 1) + 1 + 1 + 2 + 2;
}

class GidsConstants {
  static List<int> MasterFile_FileIdentifier = [0xa0, 0x00];
  static List<int> MasterFile_DataObject = [0xdf, 0x1f];

  static int GIDS_FIRST_KEY_IDENTIFIER = 0x81;
}

class GIDSCryptoApplet implements CryptoApplet {
  SmartCardConnection connection;

  GidsMasterfile? masterFile;

  GidsCmapfile? cmapFile;
  late List<int> pin;

  GIDSCryptoApplet(this.connection);

  @override
  Future<List<int>> authenticate(List<int> buffer) async {
    var command =
        Apdu().cla(0x00).ins(0x20).p1(0x00).p2(0x80).data(buffer).build();

    await connection.sendRaw(command);

    pin = buffer;

    return [];
  }

  @override
  Future<List<int>> decrypt(List<int> buffer) async {
    var chunks = partition(buffer, 256);

    List<int> plaintextBuffer = [];
    // send chunks
    bool initial = true;
    for (var chunk in chunks) {
      var data = chunk.take(chunk.length - 1).toList();
      var end = chunk.skip(chunk.length - 1).take(1).toList();

      if (data.length < 255) {
        debugPrint("last chunk");
        initial = false;
      }

      // decrypt
      var command = Apdu()
          .cla(initial ? 0x10 : 0x00)
          .ins(0x2a)
          .p1(0x80)
          .p2(0x86)
          .data(data)
          .build();

      await connection.sendRaw(command);

      // get plaintext
      var get =
          Apdu().cla(0x00).ins(0x2a).p1(0x80).p2(0x86).data(end).build(0x00);

      var plain = await connection.sendRaw(get);

      if (plain.length > 2) {
        plaintextBuffer.addAll(plain.take(plain.length - 2));
      }
    }

    // var getCiphertext =
    //     Apdu().cla(0x00).ins(0x2a).p1(0x80).p2(0x86).data([0xff]).build();

    // var ciphertext = await connection.sendRaw(getCiphertext);

    return plaintextBuffer;
  }

  @override
  Future<List<int>> encrypt(List<int> buffer) async {
    var command =
        Apdu().cla(0x00).ins(0x2a).p1(0x86).p2(0x80).data(buffer).build();

    await connection.send(command);

    var getCiphertext =
        Apdu().cla(0x00).ins(0x2a).p1(0x86).p2(0x80).data([0xff]).build();

    var ciphertext = await connection.sendRaw(getCiphertext);

    return ciphertext;
  }

  Future<List<int>> getCertificate([int keyRef = 0x81]) async {
    // await verify(pin);

    // var mf = await getMasterFile();
    // var records = GIDSCryptoApplet.getMasterFileRecords(mf);

    var cmapRecords = await getCmapFile();

    // check if the first key we find is sign or kex
    var sigOnly =
        (eq(cmapRecords.records.first.keyExchangeKeySizeBits, [0x00, 0x00])
            as bool);

    var containernum = keyRef - GidsConstants.GIDS_FIRST_KEY_IDENTIFIER;

    var filename = "";
    if (sigOnly) {
      filename = "ksc${hex.encode([containernum])}";
    } else {
      filename = "kxc${hex.encode([containernum])}";
    }

    var keyRecord = (await getMasterFile()).getSpecificRecord(
        "mscp\x00\x00\x00\x00".codeUnits, filename.codeUnits);

    if (keyRecord == null) {
      throw Exception("Certificate for keyRef $keyRef not found");
    }

    try {
      List<int> certBuffer = [];

      var res = await getDataObject(keyRecord);
      var shortenedRespose = res?.toList().take(res.length).toList();

      certBuffer.addAll(shortenedRespose!);

      var last = [0x60, 0x00];
      while (!eq(last, [0x90, 0x00])) {
        List<int> data = last[1] == 0x00 ? [] : [last[1]];

        var command2 =
            Apdu().cla(0x00).ins(0xc0).p1(0x00).p2(0x00).data(data).build();

        var certRes = await connection.sendRaw(command2);
        var certPart = certRes.take(certRes.length - 2);

        last = certRes.skip(certRes.length - 2).take(2).toList();
        certBuffer.addAll(certPart);
      }
      return certBuffer.toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    throw Exception("getIdentifierByName");
  }

  Future<GidsCmapfile> getCmapFile() async {
    var file = await getFile("mscp", "cmapfile");

    cmapFile = GidsCmapfile(file.bytes);

    return cmapFile!;
  }

  Future<Uint8List?> getDataObject(GidsMfRecord keyRecord) async {
    logDebug("get data object");
    var p = keyRecord.fileIdentifier.skip(2).take(2).toList();
    var data = keyRecord.dataObjectIdentifier.skip(2).take(2).toList();
    var command = Apdu()
        .cla(0x00)
        .ins(0xcb)
        .p1(p[0])
        .p2(p[1])
        .data([0x5c, 0x02] + data)
        .build();

    List<int> initResponse = await connection.sendRaw(command);

    var clean = initResponse.skip(2).take(initResponse.length - 4).toList();
    var tlvs = Parser().parseLength(clean);

    var value = clean.skip(tlvs.item1).take(tlvs.item2).toList();

    logDebug("File ${hex.encode(data)}");
    return Uint8List.fromList(value);
  }

  // Future<GidsCmapfile> getCmapFile() async {
  //   var file = await getFile("mscp", "cmapfile");

  //   cmapFile = file as GidsCmapfile;

  //   return cmapFile!;
  // }

  Future<Gidsfile> getFile(String folder, String file) async {
    var folder2 = folder.codeUnits.padRight(0x00, 9);
    var file2 = file.codeUnits.padRight(0x00, 9);
    var keyRecord = (await getMasterFile()).getSpecificRecord(folder2, file2);

    if (keyRecord == null) throw Exception("File not found");

    var res = await getDataObject(keyRecord);

    if (res == null) throw Exception("Error reading data object");

    return Gidsfile(res);
  }

  Future<GidsMasterfile> getMasterFile() async {
    if (masterFile != null) {
      return masterFile!;
    }

    var command = Apdu()
        .cla(0x00)
        .ins(0xcb)
        .p1(GidsConstants.MasterFile_FileIdentifier[0])
        .p2(GidsConstants.MasterFile_FileIdentifier[1])
        .data([0x5c, 0x02] + GidsConstants.MasterFile_DataObject)
        .build();

    var bytes = await connection.sendRaw(command);
    var mf = GidsMasterfile(bytes);
    masterFile = mf;

    return masterFile!;
  }

  @override
  Future<bool> selectKey(List<int> key, KeyUsage usage, int algo) async {
    var usageCode = 0x00;
    var keyType = 0x00;
    switch (usage) {
      case KeyUsage.DigitalSignature:
        usageCode = 0xb6;
        keyType = 0x84;
        break;
      case KeyUsage.Confidentiality:
        usageCode = 0xb8;
        keyType = 0x84;
        break;
      case KeyUsage.Authentication:
        usageCode = 0xa4;
        break;
      default:
    }

    var command = Apdu()
        .cla(0x00)
        .ins(0x22)
        .p1(0x41)
        .p2(usageCode)
        // .data([0x84, 0x01] + key + [0x80, 0x01, 0x42, 0x95, 0x01, 0x40])
        .data([keyType, 0x01] + key + [0x80, 0x01, algo])
        .build();

    await connection.sendRaw(command);

    // TODO: response
    return true;
  }

  @override
  Future<List<int>> sign(List<int> buffer) async {
    var command =
        Apdu().cla(0x00).ins(0x2a).p1(0x9e).p2(0x9a).data(buffer).build();

    var ciphertext = await connection.sendRaw(command);

    return ciphertext.sublist(0, ciphertext.length - 2);
  }

  @override
  Future<List<int>> verify(List<int> buffer) async {
    var chunks = partition(buffer, 255);

    List<int> plaintextBuffer = [];
    // send chunks
    bool initial = true;
    for (var chunk in chunks) {
      var command = Apdu()
          .cla(initial ? 0x10 : 0x00)
          .ins(0x2a)
          .p1(0x80)
          .p2(0x86)
          .data(chunk)
          .build();

      var response = await connection.sendRaw(command);

      if (response.length > 2) {
        plaintextBuffer.addAll(response.take(response.length - 2));
      }
      initial = false;
    }

    return plaintextBuffer;
  }

  static Future<Tuple2<int, int>> getIdentifierByName(
      List<int> buffer, String name) async {
    throw Exception("getIdentifierByName");
  }
}

class Gidsfile {
  late Uint8List bytes;

  Gidsfile(List<int> bytes) {
    this.bytes = Uint8List.fromList(bytes);
  }
}

class GidsMasterfile {
  late Uint8List bytes;

  List<GidsMfRecord> records = [];

  GidsMasterfile(List<int> bytes) {
    this.bytes = Uint8List.fromList(bytes);
  }

  List<GidsMfRecord> getRecords() {
    if (records.isNotEmpty) {
      return records;
    }

    int recordCount = (bytes.length / GidsMfRecord.desiredLength).floor();
    debugPrint("masterfile has $recordCount records");
    records.clear();

    for (var i = 0; i < recordCount; i++) {
      var record = GidsMfRecord(bytes
          .skip(1 + 4 + i * GidsMfRecord.desiredLength)
          .take(GidsMfRecord.desiredLength)
          .toList());
      debugPrint("Record $i: $record");
      records.add(record);
    }

    return records;
  }

  GidsMfRecord? getSpecificRecord(List<int> directory, List<int> filename) {
    logDebug(
        "Looking in MasterFile for ${String.fromCharCodes(filename)} in ${String.fromCharCodes(directory)}");

    if (records.isEmpty) {
      getRecords();
    }

    // ensure padding for comparison
    var d = directory.padRight(0x00, 9);
    var f = filename.padRight(0x00, 9);

    var record =
        records.where((r) => eq(r.directory, d) && eq(r.filename, f)).toList();
    if (record.isEmpty) {
      return null;
    } else {
      return record[0];
    }
  }
}

class GidsMfRecord {
  static int desiredLength = 10 + 10 + 4 + 4;
  late List<int> directory;
  late List<int> filename;
  late List<int> dataObjectIdentifier;
  late List<int> fileIdentifier;

  GidsMfRecord(List<int> buffer) {
    if (buffer.length != desiredLength) {
      Exception("Length invalid");
    }

    directory = buffer.take(9).toList();
    filename = buffer.skip(9).take(9).toList();
    dataObjectIdentifier =
        buffer.skip(10 + 10).take(4).toList().reversed.toList();
    fileIdentifier =
        buffer.skip(10 + 10 + 4).take(4).toList().reversed.toList();
  }

  @override
  String toString() {
    return "Directory:${String.fromCharCodes(directory)}\nFile:${hex.encode(filename)}\nOID:${hex.encode(dataObjectIdentifier)}\nFID:${hex.encode(fileIdentifier)} ";
  }
}

extension PadRight on List<int> {
  List<int> padRight(int pad, int maxLength) {
    var currentLength = length;
    var paddingSize = maxLength - currentLength;
    var newList = List<int>.empty(growable: true);
    newList.addAll(this);
    newList.addAll(List<int>.filled(paddingSize, pad));

    return newList;
  }
}
