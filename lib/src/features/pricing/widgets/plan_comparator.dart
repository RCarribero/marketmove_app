import 'package:flutter/material.dart';
import '../models/pricing_plan.dart';
import '../l10n/pricing_strings.dart';
import '../../../shared/theme/colors.dart';

/// Widget comparador de planes
class PlanComparator extends StatelessWidget {
  final bool isDark;
  final String? currentPlanId;
  final Function(String planId)? onSelectPlan;

  const PlanComparator({
    super.key,
    required this.isDark,
    this.currentPlanId,
    this.onSelectPlan,
  });

  @override
  Widget build(BuildContext context) {
    final plans = PricingPlan.getDefaultPlans();
    final allFeatures = _getAllFeatures(plans);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
          ),
          columns: [
            DataColumn(
              label: Text(
                PricingStrings.get('features'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            ...plans.map(
              (p) => DataColumn(
                label: _PlanHeader(
                  plan: p,
                  isCurrentPlan: p.id == currentPlanId,
                  isDark: isDark,
                  onSelect: () => onSelectPlan?.call(p.id),
                ),
              ),
            ),
          ],
          rows: allFeatures
              .map(
                (feature) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        feature,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ...plans.map(
                      (p) => DataCell(
                        _FeatureCell(
                          included: p.features.contains(feature),
                          planColor: p.color,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  List<String> _getAllFeatures(List<PricingPlan> plans) {
    final features = <String>{};
    for (final plan in plans) {
      features.addAll(plan.features);
    }
    return features.toList();
  }
}

class _PlanHeader extends StatelessWidget {
  final PricingPlan plan;
  final bool isCurrentPlan;
  final bool isDark;
  final VoidCallback? onSelect;

  const _PlanHeader({
    required this.plan,
    required this.isCurrentPlan,
    required this.isDark,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (plan.isPopular)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: plan.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              PricingStrings.get('mostPopular'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Text(
          plan.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: plan.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          plan.monthlyPrice == 0
              ? 'Gratis'
              : PricingStrings.formatPrice(plan.monthlyPrice),
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        if (isCurrentPlan) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              PricingStrings.get('currentPlan'),
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onSelect,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: plan.color.withAlpha(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              PricingStrings.get('selectPlan'),
              style: TextStyle(
                color: plan.color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeatureCell extends StatelessWidget {
  final bool included;
  final Color planColor;

  const _FeatureCell({required this.included, required this.planColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: included ? planColor.withAlpha(20) : Colors.grey.withAlpha(20),
          shape: BoxShape.circle,
        ),
        child: Icon(
          included ? Icons.check : Icons.close,
          size: 16,
          color: included ? planColor : Colors.grey,
        ),
      ),
    );
  }
}

/// Version compacta del comparador (solo precios)
class PlanCompactComparator extends StatelessWidget {
  final bool isAnnual;
  final bool isDark;
  final String? selectedPlanId;
  final Function(String planId) onSelect;

  const PlanCompactComparator({
    super.key,
    required this.isAnnual,
    required this.isDark,
    this.selectedPlanId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final plans = PricingPlan.getDefaultPlans();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: plans.map((plan) {
        final isSelected = plan.id == selectedPlanId;
        final price = isAnnual ? plan.monthlyFromAnnual : plan.monthlyPrice;

        return GestureDetector(
          onTap: () => onSelect(plan.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? plan.color.withAlpha(20)
                  : (isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? plan.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? plan.color
                        : (isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price == 0 ? 'Gratis' : PricingStrings.formatPrice(price),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
