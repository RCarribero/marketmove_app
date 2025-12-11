import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/tutorial_service.dart';

/// Modelo para cada paso del tutorial
class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    this.color = AppColors.primary,
  });
}

/// Widget de tutorial onboarding con carousel de pasos
class OnboardingTutorial extends StatefulWidget {
  final VoidCallback onComplete;
  final List<TutorialStep>? customSteps;

  const OnboardingTutorial({
    super.key,
    required this.onComplete,
    this.customSteps,
  });

  /// Pasos predefinidos del tutorial
  static List<TutorialStep> get defaultSteps => [
    const TutorialStep(
      title: 'Bienvenido a MarketMove',
      description:
          'Tu CRM inteligente para gestionar ventas, gastos y hacer crecer tu negocio.',
      icon: Icons.hub,
      color: AppColors.primary,
    ),
    const TutorialStep(
      title: 'Tu Dashboard',
      description:
          'Ve tus KPIs y metricas mas importantes de un vistazo. Ingresos, gastos y ganancias siempre a la mano.',
      icon: Icons.dashboard_rounded,
      color: Color(0xFF6366F1),
    ),
    const TutorialStep(
      title: 'Gestiona tus Ventas',
      description:
          'Registra todas tus ventas facilmente. Desliza para eliminar, toca para editar.',
      icon: Icons.point_of_sale_rounded,
      color: Color(0xFF10B981),
    ),
    const TutorialStep(
      title: 'Controla tus Gastos',
      description:
          'Mantente al tanto de todos tus gastos. Categoriza y analiza donde va tu dinero.',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFFF59E0B),
    ),
    const TutorialStep(
      title: 'Reportes con IA',
      description:
          'Obtiene insights inteligentes y recomendaciones personalizadas para tu negocio.',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF8B5CF6),
    ),
    const TutorialStep(
      title: 'Listo para empezar!',
      description:
          'Explora el menu lateral para navegar entre secciones. Estamos aqui para ayudarte a crecer.',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFFEC4899),
    ),
  ];

  /// Muestra el tutorial si el usuario no lo ha visto
  static Future<void> showIfNeeded(
    BuildContext context, {
    VoidCallback? onComplete,
  }) async {
    final hasSeen = await TutorialService.hasSeenTutorial();
    if (!hasSeen && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (ctx) => OnboardingTutorial(
          onComplete: () {
            Navigator.of(ctx).pop();
            onComplete?.call();
          },
        ),
      );
    }
  }

  /// Muestra el tutorial forzadamente (desde perfil)
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onComplete,
  }) async {
    await TutorialService.resetTutorial();
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (ctx) => OnboardingTutorial(
          onComplete: () {
            Navigator.of(ctx).pop();
            onComplete?.call();
          },
        ),
      );
    }
  }

  @override
  State<OnboardingTutorial> createState() => _OnboardingTutorialState();
}

class _OnboardingTutorialState extends State<OnboardingTutorial>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  int _currentPage = 0;

  List<TutorialStep> get steps =>
      widget.customSteps ?? OnboardingTutorial.defaultSteps;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _completeTutorial() async {
    await TutorialService.markTutorialAsSeen();
    await _fadeController.reverse();
    widget.onComplete();
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return FadeTransition(
      opacity: _fadeController,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _scaleController,
                  curve: Curves.easeOutBack,
                ),
                child: Container(
                  width: isDesktop ? 500 : size.width - 48,
                  constraints: const BoxConstraints(maxHeight: 520),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF1E1E2E), const Color(0xFF2D2D3F)]
                          : [Colors.white, const Color(0xFFF8FAFC)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: steps[_currentPage].color.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header con boton skip
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_currentPage + 1} / ${steps.length}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: _skipTutorial,
                              child: Text(
                                'Omitir',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PageView con los pasos
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (page) {
                            setState(() => _currentPage = page);
                          },
                          itemCount: steps.length,
                          itemBuilder: (context, index) {
                            return _buildStepContent(steps[index], isDark);
                          },
                        ),
                      ),

                      // Indicadores de pagina (dots)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            steps.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? steps[_currentPage].color
                                    : (isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Botones de navegacion
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Row(
                          children: [
                            if (_currentPage > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _previousPage,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Anterior',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            if (_currentPage > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: _currentPage == 0 ? 1 : 1,
                              child: FilledButton(
                                onPressed: _nextPage,
                                style: FilledButton.styleFrom(
                                  backgroundColor: steps[_currentPage].color,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _currentPage == steps.length - 1
                                      ? 'Comenzar'
                                      : 'Siguiente',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(TutorialStep step, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono animado
          TweenAnimationBuilder<double>(
            key: ValueKey(step.title),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    step.color.withValues(alpha: 0.2),
                    step.color.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.color.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: step.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(step.icon, size: 56, color: step.color),
            ),
          ),
          const SizedBox(height: 32),

          // Titulo
          TweenAnimationBuilder<double>(
            key: ValueKey('title_${step.title}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              step.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Descripcion
          TweenAnimationBuilder<double>(
            key: ValueKey('desc_${step.title}'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              step.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.grey.shade300 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
