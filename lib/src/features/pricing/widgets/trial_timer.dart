import 'dart:async';
import 'package:flutter/material.dart';
import '../services/trial_service.dart';
import '../l10n/pricing_strings.dart';
import '../../../shared/theme/colors.dart';

/// Widget de countdown para trial
class TrialTimer extends StatefulWidget {
  final VoidCallback? onExpired;
  final VoidCallback? onUpgrade;

  const TrialTimer({super.key, this.onExpired, this.onUpgrade});

  @override
  State<TrialTimer> createState() => _TrialTimerState();
}

class _TrialTimerState extends State<TrialTimer> {
  int _daysRemaining = 0;
  bool _isLoading = true;
  bool _isExpired = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTrialStatus();
    _timer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _loadTrialStatus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTrialStatus() async {
    final days = await TrialService.getTrialDaysRemaining();
    final isActive = await TrialService.isTrialActive();

    if (mounted) {
      setState(() {
        _daysRemaining = days;
        _isExpired = !isActive && days == 0;
        _isLoading = false;
      });

      if (_isExpired) {
        widget.onExpired?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_isExpired) {
      return _buildExpiredBanner(isDark);
    }

    if (_daysRemaining <= 0) {
      return const SizedBox.shrink();
    }

    return _buildTrialBanner(isDark);
  }

  Widget _buildTrialBanner(bool isDark) {
    final isUrgent = _daysRemaining <= 3;
    final color = isUrgent ? AppColors.warning : AppColors.primary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(20), color.withAlpha(10)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUrgent ? Icons.timer : Icons.access_time,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_daysRemaining ${PricingStrings.get('trialRemaining')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUrgent
                      ? 'Tu prueba termina pronto'
                      : 'Disfruta todas las funciones Pro',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: widget.onUpgrade,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(PricingStrings.get('upgrade')),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            PricingStrings.get('trialExpired'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Actualiza tu plan para continuar usando todas las funciones',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: widget.onUpgrade,
            icon: const Icon(Icons.upgrade),
            label: Text(PricingStrings.get('upgrade')),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget compacto para mostrar estado de trial en AppBar
class TrialBadge extends StatefulWidget {
  final VoidCallback? onTap;

  const TrialBadge({super.key, this.onTap});

  @override
  State<TrialBadge> createState() => _TrialBadgeState();
}

class _TrialBadgeState extends State<TrialBadge> {
  int _days = 0;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final days = await TrialService.getTrialDaysRemaining();
    final isActive = await TrialService.isTrialActive();
    if (mounted) {
      setState(() {
        _days = days;
        _show = isActive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();

    final isUrgent = _days <= 3;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isUrgent ? AppColors.warning : AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              '$_days dias',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
