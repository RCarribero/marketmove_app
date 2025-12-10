import 'package:flutter/material.dart';
import '../models/pricing_plan.dart';
import '../l10n/pricing_strings.dart';
import '../../../shared/theme/colors.dart';

/// Widget de tarjeta de plan con hover effects y animaciones
class PricingCard extends StatefulWidget {
  final PricingPlan plan;
  final bool isAnnual;
  final bool isDark;
  final bool isCurrentPlan;
  final VoidCallback onSelect;

  const PricingCard({
    super.key,
    required this.plan,
    required this.isAnnual,
    required this.isDark,
    this.isCurrentPlan = false,
    required this.onSelect,
  });

  @override
  State<PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<PricingCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 16.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    setState(() => _isHovered = hovering);
    hovering ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.isAnnual
        ? widget.plan.monthlyFromAnnual
        : widget.plan.monthlyPrice;
    final isFree = widget.plan.monthlyPrice == 0;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkCardBackground : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.plan.isPopular
                  ? widget.plan.color
                  : widget.isCurrentPlan
                  ? AppColors.success
                  : (widget.isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey.shade200),
              width: widget.plan.isPopular || widget.isCurrentPlan ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.plan.color.withAlpha(40)
                    : Colors.black.withAlpha(widget.isDark ? 30 : 15),
                blurRadius: _isHovered ? 30 : 15,
                offset: Offset(0, _elevationAnimation.value),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge header
              if (widget.plan.isPopular || widget.isCurrentPlan)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.isCurrentPlan
                        ? AppColors.success
                        : widget.plan.color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Text(
                    widget.isCurrentPlan
                        ? PricingStrings.get('currentPlan').toUpperCase()
                        : PricingStrings.get('mostPopular').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan name & description
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.plan.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getPlanIcon(),
                            color: widget.plan.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.plan.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: widget.isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              widget.plan.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Price - mostrar precio directo segun el plan
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getPriceDisplay(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: widget.plan.color,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            _getPricePeriod(),
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

                    // Savings badge
                    if (widget.isAnnual && widget.plan.savingsPercent > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${PricingStrings.get('save')} ${widget.plan.savingsPercent}% (${PricingStrings.formatPrice(widget.plan.annualSavings)}${PricingStrings.get('perYear')})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.isCurrentPlan
                            ? null
                            : widget.onSelect,
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.plan.isPopular
                              ? widget.plan.color
                              : (widget.isDark
                                    ? AppColors.darkSurfaceVariant
                                    : Colors.grey.shade100),
                          foregroundColor: widget.plan.isPopular
                              ? Colors.white
                              : (widget.isDark
                                    ? Colors.white
                                    : AppColors.textPrimary),
                          disabledBackgroundColor: AppColors.success.withAlpha(
                            30,
                          ),
                          disabledForegroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.isCurrentPlan
                              ? PricingStrings.get('currentPlan')
                              : isFree
                              ? PricingStrings.get('startTrial')
                              : PricingStrings.get('selectPlan'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Features
                    ...widget.plan.features.map(
                      (f) => _FeatureRow(
                        text: f,
                        included: true,
                        color: widget.plan.color,
                        isDark: widget.isDark,
                      ),
                    ),

                    // Limitations
                    if (widget.plan.limitations.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...widget.plan.limitations.map(
                        (l) => _FeatureRow(
                          text: l,
                          included: false,
                          color: widget.plan.color,
                          isDark: widget.isDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlanIcon() {
    switch (widget.plan.id) {
      case 'monthly':
        return Icons.calendar_today;
      case 'annual':
        return Icons.star;
      case 'lifetime':
        return Icons.diamond;
      default:
        return Icons.check_circle;
    }
  }

  String _getPriceDisplay() {
    switch (widget.plan.id) {
      case 'monthly':
        return '\$29';
      case 'annual':
        return '\$299';
      case 'lifetime':
        return '\$999';
      default:
        return '\$${widget.plan.monthlyPrice.toInt()}';
    }
  }

  String _getPricePeriod() {
    switch (widget.plan.id) {
      case 'monthly':
        return '/mes';
      case 'annual':
        return '/año';
      case 'lifetime':
        return '';
      default:
        return '';
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final bool included;
  final Color color;
  final bool isDark;

  const _FeatureRow({
    required this.text,
    required this.included,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: included ? color.withAlpha(20) : Colors.grey.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check : Icons.close,
              size: 14,
              color: included ? color : Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: included
                    ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary)
                    : (isDark ? AppColors.darkTextHint : Colors.grey),
                decoration: included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
