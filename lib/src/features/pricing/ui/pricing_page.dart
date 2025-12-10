import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/theme/colors.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  String _selectedPlan = 'annual';

  final Map<String, PricingOption> _options = {
    'monthly': PricingOption(
      id: 'monthly',
      name: 'Mensual',
      price: 29.99,
      period: '/mes',
      description: 'Facturado mensualmente',
      savings: null,
    ),
    'annual': PricingOption(
      id: 'annual',
      name: 'Anual',
      price: 299.99,
      period: '/año',
      description: 'Facturado anualmente',
      savings: 'Ahorra \$59.89',
    ),
    'lifetime': PricingOption(
      id: 'lifetime',
      name: 'De por vida',
      price: 999,
      period: '',
      description: 'Pago unico, acceso ilimitado',
      savings: 'Mejor valor',
    ),
  };

  final List<String> _features = [
    'Contactos ilimitados',
    'Usuarios ilimitados',
    'Reportes avanzados',
    'Automatizaciones',
    'Integraciones premium',
    'Soporte prioritario',
    'API access',
    'Actualizaciones incluidas',
  ];

  Future<void> _launchLogin() async {
    final uri = Uri.parse('https://midominio.com/crm');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.hub,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'MiCRM',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: _launchLogin,
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Login'),
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
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 20,
                vertical: 40,
              ),
              child: Column(
                children: [
                  Text(
                    'Plan CRM Pro',
                    style: TextStyle(
                      fontSize: isDesktop ? 42 : 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Todo lo que necesitas para gestionar tu negocio',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Pricing Options
                  _buildPricingOptions(isDesktop, isDark),
                  const SizedBox(height: 48),

                  // Features
                  _buildFeaturesSection(isDesktop, isDark),
                  const SizedBox(height: 48),

                  // CTA Button
                  SizedBox(
                    width: isDesktop ? 400 : double.infinity,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Comenzar con ${_options[_selectedPlan]!.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '14 dias de prueba gratis. Sin compromiso.',
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
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOptions(bool isDesktop, bool isDark) {
    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _options.entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _PricingOptionCard(
                  option: e.value,
                  isSelected: _selectedPlan == e.key,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedPlan = e.key),
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: _options.entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PricingOptionCard(
                option: e.value,
                isSelected: _selectedPlan == e.key,
                isDark: isDark,
                onTap: () => setState(() => _selectedPlan = e.key),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFeaturesSection(bool isDesktop, bool isDark) {
    return Container(
      width: isDesktop ? 600 : double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incluye todo:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: _features
                .map(
                  (f) => SizedBox(
                    width: isDesktop ? 250 : double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          f,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class PricingOption {
  final String id;
  final String name;
  final double price;
  final String period;
  final String description;
  final String? savings;

  const PricingOption({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    this.savings,
  });
}

class _PricingOptionCard extends StatefulWidget {
  final PricingOption option;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _PricingOptionCard({
    required this.option,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_PricingOptionCard> createState() => _PricingOptionCardState();
}

class _PricingOptionCardState extends State<_PricingOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primary
                  : (widget.isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey.shade200),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered || widget.isSelected
                    ? AppColors.primary.withAlpha(30)
                    : Colors.black.withAlpha(widget.isDark ? 20 : 8),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (widget.option.savings != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.option.savings!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                widget.option.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${widget.option.price.toStringAsFixed(widget.option.price % 1 == 0 ? 0 : 2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: widget.isSelected
                          ? AppColors.primary
                          : (widget.isDark
                                ? Colors.white
                                : AppColors.textPrimary),
                    ),
                  ),
                  if (widget.option.period.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        widget.option.period,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.option.description,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: widget.isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
