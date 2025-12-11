import 'package:flutter/material.dart';
import 'colors.dart';

class AuthTheme {
  static const logoSize = 80.0;
  static const cardPadding = EdgeInsets.all(32.0);

  static BoxDecoration get logoDecoration => BoxDecoration(
    color: AppColors.primary.withValues(alpha: 0.1),
    shape: BoxShape.circle,
  );

  static TextStyle get titleStyle => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get subtitleStyle =>
      const TextStyle(fontSize: 16, color: AppColors.textSecondary);

  static ButtonStyle get googleButtonStyle => OutlinedButton.styleFrom(
    backgroundColor: Colors.white,
    side: BorderSide(color: Colors.grey.shade300),
    padding: const EdgeInsets.symmetric(vertical: 12),
  );
}
