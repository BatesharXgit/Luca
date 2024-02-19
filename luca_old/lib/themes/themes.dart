import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: Color(0xFF131321),
    primary: Color(0xFFE6EDFF),
    secondary: Colors.grey,
    tertiary: Color(0xFF222431),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFE6EDFF)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF131321),
    selectedItemColor: Color(0xFFE1E9F0),
    unselectedItemColor: Colors.grey,
  ),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
      background: Color(0xFFE6EDFF),
      primary: Color(0xFF131321),
      secondary: Colors.grey,
      tertiary: Color(0xFFDCE2FA)),
  iconTheme: const IconThemeData(
    color: Color(0xFF131321),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFE1E9F0),
    selectedItemColor: Color(0xFF131321),
    unselectedItemColor: Colors.grey,
  ),
);
