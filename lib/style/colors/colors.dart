// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class LigaColors {
  static MaterialColor PRIMARY_THEME_COLOR = const MaterialColor(
    0Xff00626e,
    <int, Color>{
      50: Color.fromRGBO(0, 98, 110, 1),
      100: Color.fromRGBO(0, 98, 110, 1),
      200: Color.fromRGBO(0, 98, 110, 1),
      300: Color.fromRGBO(0, 98, 110, 1),
      400: Color.fromRGBO(0, 98, 110, 1),
      500: Color.fromRGBO(0, 98, 110, 1),
      600: Color.fromRGBO(0, 98, 110, 1),
      700: Color.fromRGBO(0, 98, 110, 1),
      800: Color.fromRGBO(0, 98, 110, 1),
      900: Color.fromRGBO(0, 98, 110, 1),
    },
  );

  static Color Primary = const Color.fromRGBO(0, 98, 110, 1);
  static Color Secondary = const Color.fromRGBO(133, 135, 150, 1);
  static Color Information = const Color.fromRGBO(54, 185, 204, 1);
  static Color Success = const Color.fromRGBO(133, 135, 150, 1);
  static Color Blue = const Color.fromRGBO(78, 115, 223, 1);
  static Color Danger = const Color.fromRGBO(231, 74, 59, 1);
}

extension HexColor on MaterialColor {
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
