// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';

import './tlv/tlv.dart';

class Apdu {
  List<int> _data = [];
  late int _cla;
  late int _ins;
  late int _p1;
  late int _p2;
  int _length = 0;
  int get getCla => _cla;
  List<int> get getData => _data;
  int get getIns => _ins;
  int get getLength => _calcRealLength();

  int get getP1 => _p1;
  int get getP2 => _p2;

  Uint8List build([int? trail]) {
    List<int> data = [_cla, _ins, _p1, _p2, _calcRealLength()] + _data;

    if (trail != null) {
      data.add(trail);
    }
    return Uint8List.fromList(data);
  }

  Apdu cla(int cla) {
    _cla = cla;
    return this;
  }

  Apdu data(List<int> data) {
    _data = data;

    return this;
  }

  Apdu ins(int ins) {
    _ins = ins;
    return this;
  }

  Apdu length(int length) {
    _length = length;
    return this;
  }

  Apdu p1(int p1) {
    _p1 = p1;
    return this;
  }

  Apdu p2(int p2) {
    _p2 = p2;
    return this;
  }

  @override
  String toString() {
    return "${hex.encode([_cla, _ins, _p1, _p2])} ${hex.encode([
          getLength
        ])} ${hex.encode(_data)}";
  }

  int _calcRealLength() {
    debugPrint("Getting length  Fake: $_length Real ${_data.length}");
    if (_length != 0) {
      //overwrite length
      return _length;
    } else {
      return _data.length;
    }
  }
}

class ApduResponse {
  List<TLV> fromList(List<int> buffer, [bool postResponse = false]) {
    int r1;
    int r2;
    List<int> data;

    debugPrint("$postResponse");

    if (postResponse) {
      r1 = buffer.skip(buffer.length - 2).first;
      r2 = buffer.skip(buffer.length - 1).first;
      data = buffer.take(buffer.length - 2).toList();
    } else {
      r1 = buffer.first;
      r2 = buffer.skip(1).first;
      data = buffer.skip(2).take(buffer.length - 2).toList();
    }

    switch (r1) {
      case 0x90:
        return [TLV(0x00, 0x00, [])];
      case 0x61:
        var response = Parser().parse(data);
        return response;
      case 0x62:
      case 0x63:
        throw Exception("Processing warning $r2");
      case 0x64:
      case 0x65:
      case 0x66:
        throw Exception("Execution error");
      case 0x67:
      case 0x68:
      case 0x69:
      case 0x6a:
      case 0x6b:
      case 0x6c:
      case 0x6d:
      case 0x6e:
      case 0x6f:
        throw Exception("Checking error");
      default:
        throw Exception("Totally unexpected response");
    }
  }
}

class ApduResponseParser {
  // static void fromSelect(Uint8List buffer) {
  //   if (buffer[0] != 0x6f) throw Exception("FCI template not found");
  //   var fciTemplate = buffer[1];
  //   if (buffer[2] != 0x84) {
  //     throw Exception("Application AID tag not t found");
  //   }
  //   var aidLength = buffer[3];
  //   var aid = buffer.getRange(4, 4 + aidLength).toList();
  // }

  // static void parseApplicationTemplate(Uint8List buffer) {
  //   while (buffer.isNotEmpty) {
  //     var command = buffer.take(1).single;
  //     if (command != 0x61) {
  //       throw Exception("Application template not found");
  //     }
  //     var length1 = buffer.take(1).single;
  //     var aidTag = buffer.take(1).single;
  //     if (aidTag != 0x4f) throw Exception("AID tag not found");
  //     var length2 = buffer.take(1).single;
  //     var aid = buffer.take(length2).toList();
  //   }
  // }

  static void parseGpRegistryDataTlv(Uint8List buffer) {
    if (buffer.take(1).single != 0xe3) {
      throw Exception("Not GP Registry Data (TLV)");
    }

    var registry = Registry();

    while (buffer.isNotEmpty) {
      var command = buffer.take(1).single;

      switch (command) {
        case 0x4f:
          var aidLength = buffer.take(1).single;
          registry.AID = buffer.take(aidLength).toList();
          break;
        case 0x9f:
          if (buffer.take(1).single == 0x70) {
            throw Exception("Life Cycle state expected but not found");
          }

          registry.LifeCycleState = buffer.take(1).single;
          break;
        case 0xc5:
          var length = buffer.take(1).single;
          registry.Privileges = buffer.take(length).toList();
          break;
        default:
          throw Exception("Parsing this type is not implemented");
      }
    }
  }
}

class Applets {
  static Uint8List CRYPTOVISION_AID = Uint8List.fromList(
      [0xA0, 0x00, 0x00, 0x00, 0x63, 0x50, 0x4B, 0x43, 0x53, 0x2D, 0x31, 0x35]);
  static Uint8List GIDS_AID = Uint8List.fromList(
      [0xA0, 0x00, 0x00, 0x03, 0x97, 0x42, 0x54, 0x46, 0x59, 0x02, 0x01]);
}

class Error {
//   '64' '00' No specific diagnosis
// '67' '00' Wrong length in Lc
// '68' '81' Logical channel not supported or is not active
// '69' '82' Security status not satisfied
// '69' '85' Conditions of use not satisfied
// '6A' '86' Incorrect P1 P2
// '6D' '00' Invalid instruction
// '6E' '00' Invalid class
// Table 11-10: General Error Conditions
}

// class GetStatusCommandBuilder {
//   Apdu apdu =
//       Apdu().cla(0x84).ins(0x2f); // we assume GlobalPlatform on Channel 2

//   GetStatusCommandBuilder();

//   Uint8List build() {
//     return apdu.build();
//   }

//   GetStatusCommandBuilder data() {
//     apdu.data([0x4f, 0x00, 0x70, 0x36, 0x45, 0x81, 0x88, 0x94, 0xEF, 0xB9]);
//     return this;
//   }

//   GetStatusCommandBuilder filter(
//       GetStatusStructure structure, GetStatusOccurence occurence) {
//     apdu.p2(2 * structure.index + occurence.index);
//     return this;
//   }

//   GetStatusCommandBuilder select(GetStatusP1 p1) {
//     switch (p1) {
//       case GetStatusP1.ISD:
//         apdu.p1(0x80);
//         break;
//       case GetStatusP1.AppsAndISD:
//         apdu.p1(0x40);
//         break;
//       case GetStatusP1.ELF:
//         apdu.p1(0x20);
//         break;
//       case GetStatusP1.ELFandEM:
//         apdu.p1(0x10);
//         break;
//       default:
//     }

//     return this;
//   }
// }

// enum GetStatusOccurence { FirstOrAll, Next }

// enum GetStatusStructure { Old, Default }

// enum GetStatusP1 { ISD, AppsAndISD, ELF, ELFandEM }

class GetStatusCommandBuilderP2 {}

enum Instruction {
  select // 0xa4
}

class Registry {
  late List<int> AID;
  late int LifeCycleState;
  late List<int> Privileges;
  late List<int> ImplicitSelectionParamter;
  late List<int> AppLoadFileAID;
  late List<int> ExecLoadFileVersionsNumber;
  late List<List<int>> ExecutableModuleAIDs;
  late List<int> AssociatedSecurityDomainAID;
}

class ResponseParser {
  static void parse(Uint8List buffer) {
    inspect(buffer);

    while (buffer.isNotEmpty) {
      var tag = buffer.take(1).single;
      var length = buffer.take(1).single;

      switch (tag) {
        case 0x64:
          logDebug("No specific diagnosis");
          break;
        case 0x67:
          logDebug("Wrong length in Lc");
          break;
        case 0x68:
          logDebug("Logical channel not supported or is not active");
          break;
        case 0x69:
          if (length == 0x82) {
            logDebug("Security status not satisfied");
          } else if (length == 0x85) {
            logDebug("Conditions of use not satisfied");
          }
          break;
        case 0x6a:
          logDebug("Incorrect P1 P2");
          break;
        case 0x6d:
          logDebug("Invalid instruction");
          break;
        case 0x6e:
          logDebug("Invalid class");
          break;
        default:
          logDebug(buffer.length);
          buffer.take(buffer.lengthInBytes);
      }
    }
  }
}

class Tags {
  static int FCI = 0x6f;
  static int APPLICATION_TEMPLATE = 0x61;
  static int SECURITY_DOMAIN_MANAGEMENT = 0x73;
}
