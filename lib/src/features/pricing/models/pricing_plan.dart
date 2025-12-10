import 'package:flutter/material.dart';

/// Modelo de plan de precios para el CRM
class PricingPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double annualPrice;
  final String stripeUrl;
  final List<String> features;
  final List<String> limitations;
  final bool isPopular;
  final bool isEnterprise;
  final int maxContacts;
  final int maxUsers;
  final Color color;

  const PricingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.annualPrice,
    this.stripeUrl = '',
    required this.features,
    this.limitations = const [],
    this.isPopular = false,
    this.isEnterprise = false,
    this.maxContacts = 100,
    this.maxUsers = 1,
    this.color = Colors.blue,
  });

  double get monthlyFromAnnual => annualPrice / 12;

  int get savingsPercent {
    if (monthlyPrice == 0) return 0;
    final monthlyTotal = monthlyPrice * 12;
    return ((monthlyTotal - annualPrice) / monthlyTotal * 100).round();
  }

  double get annualSavings => (monthlyPrice * 12) - annualPrice;

  /// Planes predefinidos - UN SOLO PLAN con 3 opciones de pago
  static const _features = [
    'Contactos ilimitados',
    'Usuarios ilimitados',
    'Reportes avanzados',
    'Automatizaciones',
    'Integraciones premium',
    'Soporte prioritario',
    'API access',
    'Actualizaciones incluidas',
  ];

  static List<PricingPlan> getDefaultPlans() {
    return [
      PricingPlan(
        id: 'monthly',
        name: 'Mensual',
        description: '\$29/mes',
        monthlyPrice: 29,
        annualPrice: 29 * 12,
        stripeUrl: 'https://buy.stripe.com/test_3cI14m0RG23WfJ94nC5wI01',
        maxContacts: -1,
        maxUsers: -1,
        color: const Color(0xFF6366F1),
        features: _features,
      ),
      PricingPlan(
        id: 'annual',
        name: 'Anual',
        description: '\$299/año (ahorra \$49)',
        monthlyPrice: 299 / 12,
        annualPrice: 299,
        stripeUrl: 'https://buy.stripe.com/test_dRmfZgfMA5g8fJ9cU85wI02',
        maxContacts: -1,
        maxUsers: -1,
        isPopular: true,
        color: const Color(0xFF6366F1),
        features: _features,
      ),
      PricingPlan(
        id: 'lifetime',
        name: 'Pago Unico',
        description: '\$999 - Acceso de por vida',
        monthlyPrice: 999,
        annualPrice: 999,
        stripeUrl: 'https://buy.stripe.com/test_eVqfZgasgeQI9kL7zO5wI03',
        maxContacts: -1,
        maxUsers: -1,
        isEnterprise: true,
        color: const Color(0xFF8B5CF6),
        features: _features,
      ),
    ];
  }

  /// Obtener plan por ID
  static PricingPlan? getById(String id) {
    try {
      return getDefaultPlans().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Estado de subscripcion del usuario
enum SubscriptionStatus { trial, free, active, expired, cancelled }

class UserSubscription {
  final String odId;
  final String planId;
  final SubscriptionStatus status;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isAnnual;

  const UserSubscription({
    required this.odId,
    required this.planId,
    required this.status,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isAnnual = false,
  });

  bool get isTrialActive {
    if (status != SubscriptionStatus.trial) return false;
    if (trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  int get trialDaysRemaining {
    if (trialEndDate == null) return 0;
    final diff = trialEndDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  bool get hasActiveSubscription {
    return status == SubscriptionStatus.active || isTrialActive;
  }

  PricingPlan? get currentPlan => PricingPlan.getById(planId);

  /// Crear trial nuevo
  factory UserSubscription.startTrial({
    required String odId,
    String planId = 'pro',
    int trialDays = 14,
  }) {
    final now = DateTime.now();
    return UserSubscription(
      odId: odId,
      planId: planId,
      status: SubscriptionStatus.trial,
      trialStartDate: now,
      trialEndDate: now.add(Duration(days: trialDays)),
    );
  }

  /// Usuario sin subscripcion (free)
  factory UserSubscription.free(String odId) {
    return UserSubscription(
      odId: odId,
      planId: 'free',
      status: SubscriptionStatus.free,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': odId,
    'planId': planId,
    'status': status.name,
    'trialStartDate': trialStartDate?.toIso8601String(),
    'trialEndDate': trialEndDate?.toIso8601String(),
    'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
    'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
    'isAnnual': isAnnual,
  };

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      odId: json['userId'] as String,
      planId: json['planId'] as String,
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SubscriptionStatus.free,
      ),
      trialStartDate: json['trialStartDate'] != null
          ? DateTime.parse(json['trialStartDate'])
          : null,
      trialEndDate: json['trialEndDate'] != null
          ? DateTime.parse(json['trialEndDate'])
          : null,
      subscriptionStartDate: json['subscriptionStartDate'] != null
          ? DateTime.parse(json['subscriptionStartDate'])
          : null,
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.parse(json['subscriptionEndDate'])
          : null,
      isAnnual: json['isAnnual'] as bool? ?? false,
    );
  }
}
