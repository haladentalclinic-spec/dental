import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const Color primaryColor = Color(0xFF1E88E5);
  static ThemeData get light => ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: primaryColor);
  static ThemeData get dark => ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: primaryColor);
}

