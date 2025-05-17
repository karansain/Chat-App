import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
    brightness: Brightness.light,
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.transparent, // Transparent background
      // textStyle: TextStyle(color: Colors.black), // Customize text color if needed
      elevation: 0, // Optional: Remove shadow
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.black,
      // secondary: Color(0xff1A1A1A),
      secondary: Color.fromARGB(255, 34, 36, 49),
      tertiary: Colors.white,
      tertiaryContainer: Color(0xff9813F1),
      primaryContainer: Color(0xff4C0A79),
      secondaryContainer: Color(0xff9813F1),

    ));

ThemeData lightMode = ThemeData(
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.transparent, // Transparent background
      // textStyle: TextStyle(color: Colors.black), // Customize text color if needed
      elevation: 0, // Optional: Remove shadow
    ),
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
          primary: Color(0xffB4C5DB),
          secondary: Color(0xff728495),
          tertiary: Color(0xff263A47),
          tertiaryContainer: Color(0xff263A47),
          primaryContainer: Color(0xff263A47),
          secondaryContainer: Color(0xff728495),
    ));