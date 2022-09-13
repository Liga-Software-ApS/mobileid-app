


import 'package:flutter/material.dart';

import 'colors/colors.dart';
import 'common.dart';


var defaultThemeTextColor = Colors.black;

var defaultColorSchema = ColorScheme(
        brightness: Brightness.light,
        primary: LigaColors.Primary,
        onPrimary: Colors.white,
        secondary: LigaColors.Primary,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: Colors.white,
        onBackground: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black);

var defaultTheme = getThemeData(
  colorScheme: defaultColorSchema,
  backgroundColor: Colors.white,
  elevatedBackgroundColor: LigaColors.Primary,
  defaultTextColor: Colors.black,
  elevatedTextColor: Colors.white,
);


var elevatedColorSchema = ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.white,
        onPrimary: LigaColors.Primary,
        secondary: Colors.white,
        onSecondary: LigaColors.Primary,
        error: Colors.red,
        onError: Colors.white,
        background: LigaColors.Primary,
        onBackground: Colors.white,
        surface: LigaColors.Primary,
        onSurface: Colors.white);

var elevatedTheme = getThemeData(
  colorScheme: elevatedColorSchema,
  backgroundColor: LigaColors.Primary,
  elevatedBackgroundColor: Colors.white,
  defaultTextColor: Colors.white,
  elevatedTextColor: LigaColors.Primary,
);