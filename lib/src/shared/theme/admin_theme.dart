import 'package:flutter/material.dart';
import 'colors.dart';

class AdminTheme {
  static final headerStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static final cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
