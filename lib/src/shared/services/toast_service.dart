import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import '../theme/colors.dart';

enum ToastType { success, error, info, warning }

class ToastService {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = isDark
            ? AppColors.success.withValues(alpha: 0.9)
            : AppColors.success;
        iconColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case ToastType.error:
        backgroundColor = isDark
            ? AppColors.error.withValues(alpha: 0.9)
            : AppColors.error;
        iconColor = Colors.white;
        icon = Icons.error_outline;
        break;
      case ToastType.warning:
        backgroundColor = isDark
            ? AppColors.warning.withValues(alpha: 0.9)
            : AppColors.warning;
        iconColor = Colors.white;
        icon = Icons.warning_amber_outlined;
        break;
      case ToastType.info:
        backgroundColor = isDark
            ? AppColors.info.withValues(alpha: 0.9)
            : AppColors.info;
        iconColor = Colors.white;
        icon = Icons.info_outline;
        break;
    }

    Flushbar(
      title: title,
      message: message,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: backgroundColor,
      icon: Icon(icon, color: iconColor, size: 28),
      leftBarIndicatorColor: iconColor,
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ).show(context);
  }

  static void success(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.success);
  }

  static void error(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.error);
  }

  static void info(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.info);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    show(context, message: message, title: title, type: ToastType.warning);
  }
}
