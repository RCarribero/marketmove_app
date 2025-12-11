import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../pricing/services/trial_service.dart';

class PlanSelectionPage extends StatefulWidget {
  const PlanSelectionPage({super.key});

  @override
  State<PlanSelectionPage> createState() => _PlanSelectionPageState();
}

class _PlanSelectionPageState extends State<PlanSelectionPage> {
  bool _isLoading = false;

  Future<void> _startFreeTrial() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id;

      if (userId != null) {
        await TrialService.startTrial(odId: userId, trialDays: 30);

        if (mounted) {
          context.go('/user-dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar prueba: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToPricing() {
    context.go('/pricing');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [AppColors.primary.withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Bienvenido a MarketMove',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Elige como quieres comenzar',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Free Trial Card
                  _buildOptionCard(
                    icon: Icons.card_giftcard,
                    title: 'Prueba Gratuita',
                    subtitle: '1 mes gratis - Sin tarjeta',
                    description:
                        'Accede a todas las funciones durante 30 dias sin compromiso.',
                    buttonText: _isLoading ? 'Activando...' : 'Comenzar Gratis',
                    isPrimary: true,
                    onTap: _isLoading ? null : _startFreeTrial,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Divider with text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Premium Plans Card
                  _buildOptionCard(
                    icon: Icons.workspace_premium,
                    title: 'Ver Planes Premium',
                    subtitle: 'Desde \$9.99/mes',
                    description:
                        'Compara nuestros planes y elige el que mejor se adapte a tu negocio.',
                    buttonText: 'Ver Planes',
                    isPrimary: false,
                    onTap: _goToPricing,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required bool isPrimary,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'RECOMENDADO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Icon(
            icon,
            size: 40,
            color: isPrimary
                ? AppColors.primary
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isPrimary
                  ? AppColors.primary
                  : (isDark ? Colors.grey.shade400 : AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary
                    ? AppColors.primary
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                foregroundColor: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.textPrimary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isPrimary ? 4 : 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
