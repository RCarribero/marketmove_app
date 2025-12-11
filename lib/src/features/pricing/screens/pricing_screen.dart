import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pricing_plan.dart';
import '../services/trial_service.dart';
import '../services/pricing_auth_service.dart';
import '../services/plan_recommender.dart';
import '../services/subscription_service.dart';
import '../widgets/pricing_card.dart';
import '../widgets/trial_timer.dart';
import '../widgets/plan_comparator.dart';
import '../widgets/local_chat.dart';
import '../widgets/terms_modal.dart';
import '../widgets/testimonials.dart';
import '../l10n/pricing_strings.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/providers/auth_provider.dart';

/// Pantalla principal de pricing con todas las features
class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen>
    with SingleTickerProviderStateMixin {
  bool _isAnnual = true;
  bool _isLoading = true;
  bool _showChat = false;
  bool _showComparator = false;
  String? _currentPlanId;
  int _trialDays = 0;

  // Recommender state
  bool _showRecommender = false;
  int _currentQuestion = 0;
  final Map<String, String> _answers = {};
  RecommendationResult? _recommendation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Detectar idioma del sistema
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = View.of(context).platformDispatcher.locale.toString();
      PricingStrings.detectSystemLocale(locale);
      _checkAuthAndLoad();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoad() async {
    // Cargar estado de trial si esta autenticado
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user != null) {
      // Usuario autenticado - cargar su suscripcion
      _currentPlanId = authProvider.currentPlanId;
      _trialDays = authProvider.trialDaysRemaining;
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _fadeController.forward();
    }
  }

  Future<void> _handleSelectPlan(PricingPlan plan) async {
    final authProvider = context.read<AuthProvider>();

    // Si no esta logueado, mostrar dialogo de login
    if (authProvider.user == null) {
      final loggedIn = await _showLoginDialog();
      if (!loggedIn) return;
    }

    // Mostrar modal de terminos
    final accepted = await TermsModal.show(context);
    if (accepted != true) return;

    // Abrir Stripe para pagar
    if (plan.stripeUrl.isNotEmpty) {
      // Agregar email del usuario para pre-llenar en Stripe
      final userEmail = authProvider.user?.email ?? '';
      final stripeUrlWithEmail =
          '${plan.stripeUrl}?prefilled_email=${Uri.encodeComponent(userEmail)}';

      final uri = Uri.parse(stripeUrlWithEmail);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Mostrar dialogo de espera con polling
        if (mounted) {
          final success = await _showPaymentWaitingDialog();

          if (success && mounted) {
            // Recargar auth provider
            await authProvider.loadSession();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Suscripcion activada con exito!'),
                backgroundColor: Colors.green,
              ),
            );

            // Ir a home
            context.go('/home');
          }
        }
      }
    }
  }

  /// Dialogo que hace polling esperando confirmacion de Stripe
  Future<bool> _showPaymentWaitingDialog() async {
    bool isWaiting = true;
    bool paymentConfirmed = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Iniciar polling
          if (isWaiting && !paymentConfirmed) {
            Future.delayed(const Duration(seconds: 3), () async {
              if (!isWaiting) return;

              // Verificar si la suscripcion se activo
              final sub = await SubscriptionService.getSubscription();
              if (sub != null && sub.status == SubscriptionStatus.active) {
                paymentConfirmed = true;
                Navigator.pop(ctx, true);
              } else if (isWaiting) {
                // Continuar polling
                setDialogState(() {});
              }
            });
          }

          return AlertDialog(
            title: const Text('Esperando Pago'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Completa el pago en Stripe.\nEsta ventana se cerrara automaticamente.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Verificando pago...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  isWaiting = false;
                  Navigator.pop(ctx, false);
                },
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      ),
    );

    return result == true;
  }

  Future<bool> _showLoginDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final authProvider = context.read<AuthProvider>();
    bool isLoading = false;
    String? errorMessage;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Iniciar Sesion'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Inicia sesion para continuar con tu compra',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contrasena',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pop(ctx, false);
                      context.push('/register');
                    },
              child: const Text('Crear Cuenta'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      try {
                        await authProvider.signIn(
                          emailController.text.trim(),
                          passwordController.text,
                        );
                        if (authProvider.user != null) {
                          Navigator.pop(ctx, true);
                        } else {
                          setDialogState(() {
                            errorMessage = 'Credenciales incorrectas';
                            isLoading = false;
                          });
                        }
                      } catch (e) {
                        setDialogState(() {
                          errorMessage = 'Error al iniciar sesion';
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );

    return result == true;
  }

  void _openStripeCheckout(String planId) async {
    // URLs de Stripe (reemplazar con tus URLs reales)
    final urls = {
      'free': null,
      'pro_monthly': 'https://buy.stripe.com/test_3cI14m0RG23WfJ94nC5wI01',
      'pro_annual': 'https://buy.stripe.com/test_dRmfZgfMA5g8fJ9cU85wI02',
      'enterprise_monthly':
          'https://buy.stripe.com/test_eVqfZgasgeQI9kL7zO5wI03',
      'enterprise_annual':
          'https://buy.stripe.com/test_eVqfZgasgeQI9kL7zO5wI03',
    };

    final key = '${planId}_${_isAnnual ? 'annual' : 'monthly'}';
    final url = urls[key];

    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : const Color(0xFFF8FAFC),
      floatingActionButton: !kIsWeb && !isDesktop ? _buildFAB(isDark) : null,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(isDark, isDesktop),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Trial banner si aplica
                      if (_trialDays > 0)
                        TrialTimer(onUpgrade: () => setState(() {})),

                      _buildHeroSection(isDark, isDesktop),
                      const SizedBox(height: 32),

                      // Recommender button
                      _buildRecommenderButton(isDark),
                      const SizedBox(height: 48),

                      // Plans grid (sin toggle, los 3 planes directos)
                      _buildPlansGrid(isDark, isDesktop, isTablet),
                      const SizedBox(height: 48),

                      // Comparator toggle
                      _buildComparatorToggle(isDark),
                      if (_showComparator) ...[
                        const SizedBox(height: 24),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 80 : 20,
                          ),
                          child: PlanComparator(
                            isDark: isDark,
                            currentPlanId: _currentPlanId,
                            onSelectPlan: (id) {
                              final plan = PricingPlan.getById(id);
                              if (plan != null) _handleSelectPlan(plan);
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 60),

                      // Testimonials
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 80 : 20,
                        ),
                        child: Testimonials(isDark: isDark),
                      ),
                      const SizedBox(height: 60),

                      // Footer
                      _buildFooter(isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chat widget
          if (_showChat)
            Positioned(right: 20, bottom: 80, child: LocalChat(isDark: isDark)),

          // Recommender overlay
          if (_showRecommender) _buildRecommenderOverlay(isDark, isDesktop),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.hub,
                      color: Colors.white,
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 12),
                    Text(
                      'MarketMove',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language selector - solo icono en movil
                  PopupMenuButton<String>(
                    onSelected: (locale) {
                      setState(() {
                        PricingStrings.setLocale(locale);
                      });
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'es', child: Text('Espanol')),
                      const PopupMenuItem(value: 'en', child: Text('English')),
                      const PopupMenuItem(
                        value: 'pt',
                        child: Text('Portugues'),
                      ),
                    ],
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 18),
                          if (!isMobile) ...[
                            const SizedBox(width: 4),
                            Text(PricingStrings.currentLocale.toUpperCase()),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Actions - Login or User info
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.user != null) {
                        // Usuario autenticado - solo boton dashboard
                        return isMobile
                            ? IconButton(
                                onPressed: () => context.go(
                                  auth.isAdmin ? '/home' : '/user-dashboard',
                                ),
                                icon: const Icon(Icons.dashboard),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              )
                            : FilledButton.icon(
                                onPressed: () => context.go(
                                  auth.isAdmin ? '/home' : '/user-dashboard',
                                ),
                                icon: const Icon(Icons.dashboard, size: 18),
                                label: const Text('Ir al Dashboard'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                      }
                      // Usuario no autenticado - mostrar boton login
                      return isMobile
                          ? IconButton(
                              onPressed: () => context.push('/login'),
                              icon: const Icon(Icons.login),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: () => context.push('/login'),
                              icon: const Icon(Icons.login, size: 18),
                              label: Text(PricingStrings.get('login')),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '30 ${PricingStrings.get('trialDays')}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            PricingStrings.get('title'),
            style: TextStyle(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            PricingStrings.get('subtitle'),
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withAlpha(220),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommenderButton(bool isDark) {
    return TextButton.icon(
      onPressed: () => setState(() {
        _showRecommender = true;
        _currentQuestion = 0;
        _answers.clear();
        _recommendation = null;
      }),
      icon: const Icon(Icons.psychology),
      label: const Text('No sabes cual elegir? Te ayudamos'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildBillingToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BillingOption(
            label: PricingStrings.get('monthly'),
            isSelected: !_isAnnual,
            onTap: () => setState(() => _isAnnual = false),
          ),
          _BillingOption(
            label: PricingStrings.get('annual'),
            isSelected: _isAnnual,
            onTap: () => setState(() => _isAnnual = true),
            badge: '${PricingStrings.get('save')} 17%',
          ),
        ],
      ),
    );
  }

  Widget _buildPlansGrid(bool isDark, bool isDesktop, bool isTablet) {
    final plans = PricingPlan.getDefaultPlans();
    final horizontalPadding = isDesktop ? 80.0 : 20.0;

    if (!isDesktop && !isTablet) {
      // Mobile: vertical list
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: plans
              .map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: PricingCard(
                    plan: plan,
                    isAnnual: _isAnnual,
                    isDark: isDark,
                    isCurrentPlan: plan.id == _currentPlanId,
                    onSelect: () => _handleSelectPlan(plan),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }

    // Tablet/Desktop: horizontal row
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: plans
            .map(
              (plan) => PricingCard(
                plan: plan,
                isAnnual: _isAnnual,
                isDark: isDark,
                isCurrentPlan: plan.id == _currentPlanId,
                onSelect: () => _handleSelectPlan(plan),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildComparatorToggle(bool isDark) {
    return TextButton.icon(
      onPressed: () => setState(() => _showComparator = !_showComparator),
      icon: Icon(_showComparator ? Icons.expand_less : Icons.expand_more),
      label: Text(PricingStrings.get('compare')),
      style: TextButton.styleFrom(
        foregroundColor: isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Icon(Icons.verified_user, size: 40, color: AppColors.success),
        const SizedBox(height: 12),
        Text(
          '30 dias gratis. Sin tarjeta. Cancela cuando quieras.',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                await TermsModal.show(context);
              },
              child: Text(PricingStrings.get('termsTitle')),
            ),
            const Text(' | '),
            TextButton(
              onPressed: () async {
                await TermsModal.show(context);
              },
              child: Text(PricingStrings.get('privacyTitle')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFAB(bool isDark) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'chat',
              mini: true,
              backgroundColor: AppColors.primary,
              onPressed: () => setState(() => _showChat = !_showChat),
              child: Icon(_showChat ? Icons.close : Icons.chat),
            ),
            const SizedBox(height: 8),
            if (auth.user != null)
              // Usuario autenticado - mostrar boton dashboard
              FloatingActionButton.extended(
                heroTag: 'dashboard',
                backgroundColor: AppColors.primary,
                onPressed: () =>
                    context.go(auth.isAdmin ? '/home' : '/user-dashboard'),
                icon: const Icon(Icons.dashboard),
                label: const Text('Dashboard'),
              )
            else
              // Usuario no autenticado - mostrar boton login
              FloatingActionButton.extended(
                heroTag: 'login',
                backgroundColor: AppColors.primary,
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login),
                label: Text(PricingStrings.get('login')),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecommenderOverlay(bool isDark, bool isDesktop) {
    final questions = PlanRecommender.getQuestions();

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: isDesktop ? 500 : MediaQuery.of(context).size.width - 40,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: _recommendation != null
              ? _buildRecommendationResult(isDark)
              : _buildQuestionCard(questions[_currentQuestion], isDark),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(RecommenderQuestion question, bool isDark) {
    final questions = PlanRecommender.getQuestions();
    final progress = (_currentQuestion + 1) / questions.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_currentQuestion + 1}/${questions.length}',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Question
        Text(
          question.question,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Options
        ...question.options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _answers[question.id] = option.value;
                  if (_currentQuestion < questions.length - 1) {
                    setState(() => _currentQuestion++);
                  } else {
                    setState(() {
                      _recommendation = PlanRecommender.getRecommendation(
                        _answers,
                      );
                    });
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(option.label),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _showRecommender = false),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Widget _buildRecommendationResult(bool isDark) {
    final plan = PricingPlan.getById(_recommendation!.planId);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Te recomendamos',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          plan?.name ?? 'Pro',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: plan?.color ?? AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Confianza: ${_recommendation!.confidence}%',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        // Reasons
        ...?_recommendation?.reasons.map(
          (reason) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _showRecommender = false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ver todos los planes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  setState(() => _showRecommender = false);
                  if (plan != null) _handleSelectPlan(plan);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: plan?.color ?? AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(PricingStrings.get('selectPlan')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BillingOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _BillingOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
