import 'package:flutter/material.dart';

/// Shared visual defaults for the app. Keep screen-specific styling in screens.
abstract final class AppTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF356859),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
}
