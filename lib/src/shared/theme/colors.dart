import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const primary = Color(0xFF3F51B5);
  static const primaryLight = Color(0xFF7986CB);
  static const primaryDark = Color(0xFF303F9F);

  // Secondary Palette
  static const secondary = Color(0xFF03A9F4);
  static const secondaryLight = Color(0xFF4FC3F7);
  static const secondaryDark = Color(0xFF0288D1);

  // Accent Colors
  static const accent = Color(0xFF03A9F4);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFD32F2F);
  static const info = Color(0xFF2196F3);

  // Light Theme Colors
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFF0F0F0);
  static const cardBackground = Colors.white;

  // Dark Theme Colors
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkSurfaceVariant = Color(0xFF2C2C2C);
  static const darkCardBackground = Color(0xFF252525);

  // Text Colors - Light
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF616161);
  static const textHint = Color(0xFF9E9E9E);
  static const textInverse = Colors.white;

  // Text Colors - Dark
  static const darkTextPrimary = Color(0xFFE0E0E0);
  static const darkTextSecondary = Color(0xFFB0B0B0);
  static const darkTextHint = Color(0xFF757575);

  // Chart Colors
  static const chartColors = [
    Color(0xFF3F51B5),
    Color(0xFF03A9F4),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
  ];

  // Gradient Presets
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF81C784)],
  );

  static const errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFE57373)],
  );
}
