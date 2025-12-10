import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class ExpandableFab extends StatelessWidget {
  const ExpandableFab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
      foregroundColor: Colors.white,
      activeBackgroundColor: AppColors.error,
      activeForegroundColor: Colors.white,
      buttonSize: const Size(56, 56),
      childrenButtonSize: const Size(56, 56),
      spacing: 12,
      spaceBetweenChildren: 12,
      elevation: 8,
      animationCurve: Curves.easeOutCubic,
      animationDuration: const Duration(milliseconds: 300),
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      tooltip: 'Acciones rapidas',
      heroTag: 'expandable-fab',
      children: [
        SpeedDialChild(
          child: const Icon(Icons.point_of_sale, color: Colors.white),
          backgroundColor: AppColors.success,
          label: 'Nueva Venta',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () => context.push('/ventas'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.money_off, color: Colors.white),
          backgroundColor: AppColors.error,
          label: 'Nuevo Gasto',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () => context.push('/gastos'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.inventory_2, color: Colors.white),
          backgroundColor: AppColors.secondary,
          label: 'Nuevo Producto',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () => context.push('/productos'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.bar_chart, color: Colors.white),
          backgroundColor: AppColors.warning,
          label: 'Ver Resumen',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () => context.push('/resumen'),
        ),
      ],
    );
  }
}
