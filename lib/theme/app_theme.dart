import 'package:flutter/material.dart';

class AppTheme {
  static const seedColor = Color(0xFF0F766E);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: 'PlusJakartaSans',
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
