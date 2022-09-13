import 'package:flutter/material.dart';

import 'colors/colors.dart';

ThemeData getThemeData(
    {required Color backgroundColor,
    required Color elevatedBackgroundColor,
    required Color defaultTextColor,
    required Color elevatedTextColor,
    required ColorScheme colorScheme}) {
  var iconThemeData = IconThemeData(
    color: colorScheme.primary,
  );

  var buttonBorderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0),
  );

  return ThemeData(
    primarySwatch: LigaColors.PRIMARY_THEME_COLOR,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Arial',
    scaffoldBackgroundColor: backgroundColor,
    backgroundColor: backgroundColor,
    iconTheme: iconThemeData,
    colorScheme: colorScheme,
    appBarTheme: const AppBarTheme(
      // backgroundColor: backgroundColor,
      shadowColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontSize: 15,
          // color: color,
          fontWeight: FontWeight.w800),
      // iconTheme: iconThemeData
    ),
    buttonTheme: ButtonThemeData(
      shape: buttonBorderShape,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        // backgroundColor: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        // primary: defaultTextColor,
        // textStyle: const TextStyle(fontSize: 20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        // primary: elevatedBackgroundColor,
        // onPrimary: elevatedTextColor,
        minimumSize: const Size(160, 40),
        shape: buttonBorderShape,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        // textStyle: const TextStyle(fontSize: 20),
      ),
    ),
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        fontSize: 15,
        // color: defaultTextColor,
      ),
      bodyText2: TextStyle(
        fontSize: 12,
        // color: defaultTextColor,
      ),
      button: TextStyle(
        fontSize: 15,
        // color: defaultTextColor,
      ),
      headline1: TextStyle(
        fontSize: 30,
        // color: accentTextColor,
        fontWeight: FontWeight.w800,
        fontFamily: 'Roboto',
      ),
      headline2: TextStyle(
        fontSize: 25,
        // color: accentTextColor,
        fontWeight: FontWeight.w800,
        fontFamily: 'Roboto',
      ),
      headline3: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          // color: accentTextColor,
          fontFamily: 'Roboto'),
      headline4: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        // color: accentTextColor,
        fontFamily: 'Roboto',
      ),
      headline5: TextStyle(
        // color: accentTextColor,
        fontSize: 10,
        fontStyle: FontStyle.italic,
        fontFamily: 'Roboto',
      ),
      headline6: TextStyle(
        // color: accentTextColor,
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
    ),
  );
}

// // main page
//             TextTheme. TextStyleconst TextStyle(
//               fontSize: 12.0,
//               color: Colors.white,
//               fontWeight: FontWeight.w400,
//               fontFamily: "Roboto",
//             ),
