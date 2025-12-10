import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pricing_plan.dart';

/// Servicio para gestionar trial y subscripciones localmente
class TrialService {
  static const String _subscriptionKey = 'user_subscription';
  static const String _trialDaysKey = 'trial_days_config';
  static const int defaultTrialDays = 30; // 1 mes de trial

  /// Obtener subscripcion guardada
  static Future<UserSubscription?> getSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_subscriptionKey);
    if (json == null) return null;
    try {
      return UserSubscription.fromJson(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  /// Guardar subscripcion
  static Future<void> saveSubscription(UserSubscription subscription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subscriptionKey, jsonEncode(subscription.toJson()));
  }

  /// Iniciar trial
  static Future<UserSubscription> startTrial({
    required String odId,
    String planId = 'pro',
    int? trialDays,
  }) async {
    final days = trialDays ?? await getTrialDaysConfig();
    final subscription = UserSubscription.startTrial(
      odId: odId,
      planId: planId,
      trialDays: days,
    );
    await saveSubscription(subscription);
    return subscription;
  }

  /// Verificar si trial esta activo
  static Future<bool> isTrialActive() async {
    final sub = await getSubscription();
    return sub?.isTrialActive ?? false;
  }

  /// Obtener dias restantes de trial
  static Future<int> getTrialDaysRemaining() async {
    final sub = await getSubscription();
    return sub?.trialDaysRemaining ?? 0;
  }

  /// Verificar si tiene subscripcion activa
  static Future<bool> hasActiveSubscription() async {
    final sub = await getSubscription();
    return sub?.hasActiveSubscription ?? false;
  }

  /// Configurar dias de trial
  static Future<void> setTrialDaysConfig(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_trialDaysKey, days);
  }

  /// Obtener configuracion de dias de trial
  static Future<int> getTrialDaysConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_trialDaysKey) ?? defaultTrialDays;
  }

  /// Activar subscripcion (simular compra)
  static Future<UserSubscription> activateSubscription({
    required String odId,
    required String planId,
    required bool isAnnual,
  }) async {
    final now = DateTime.now();
    final endDate = isAnnual
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));

    final subscription = UserSubscription(
      odId: odId,
      planId: planId,
      status: SubscriptionStatus.active,
      subscriptionStartDate: now,
      subscriptionEndDate: endDate,
      isAnnual: isAnnual,
    );
    await saveSubscription(subscription);
    return subscription;
  }

  /// Limpiar subscripcion (logout)
  static Future<void> clearSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_subscriptionKey);
  }

  /// Verificar si feature esta disponible segun plan
  static Future<bool> isFeatureAvailable(String feature) async {
    final sub = await getSubscription();
    if (sub == null) return false;

    final plan = sub.currentPlan;
    if (plan == null) return false;

    // Si trial expiro y no es active, solo features de free
    if (!sub.hasActiveSubscription && sub.planId != 'free') {
      final freePlan = PricingPlan.getById('free');
      return freePlan?.features.contains(feature) ?? false;
    }

    return plan.features.contains(feature);
  }
}
