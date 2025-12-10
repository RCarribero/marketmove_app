import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/pricing_plan.dart';

/// Servicio de suscripciones con Supabase
class SubscriptionService {
  static final _supabase = Supabase.instance.client;
  static String? _cachedDeviceId;

  /// Obtener ID unico del dispositivo
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    final deviceInfo = DeviceInfoPlugin();
    String deviceId;

    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      deviceId = '${webInfo.browserName}_${webInfo.userAgent.hashCode}';
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
    } else {
      deviceId = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// Obtener suscripcion del usuario actual
  static Future<UserSubscription?> getSubscription() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return UserSubscription(
        odId: response['user_id'],
        planId: response['plan_id'] ?? 'free',
        status: _parseStatus(response['status']),
        trialStartDate: response['trial_start'] != null
            ? DateTime.parse(response['trial_start'])
            : null,
        trialEndDate: response['trial_end'] != null
            ? DateTime.parse(response['trial_end'])
            : null,
        subscriptionStartDate: response['subscription_start'] != null
            ? DateTime.parse(response['subscription_start'])
            : null,
        subscriptionEndDate: response['subscription_end'] != null
            ? DateTime.parse(response['subscription_end'])
            : null,
        isAnnual: response['is_annual'] ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  /// Verificar si el dispositivo ya tuvo un trial
  static Future<bool> hasDeviceUsedTrial() async {
    final deviceId = await getDeviceId();

    try {
      final response = await _supabase
          .from('subscriptions')
          .select('id')
          .eq('device_id', deviceId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Iniciar trial para usuario nuevo
  static Future<UserSubscription?> startTrial({
    String planId = 'pro',
    int trialDays = 30,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // Verificar si el usuario ya tiene suscripcion
    final existing = await getSubscription();
    if (existing != null) {
      return existing; // Ya tiene suscripcion, retornarla
    }

    final deviceId = await getDeviceId();
    final now = DateTime.now();
    final trialEnd = now.add(Duration(days: trialDays));

    try {
      await _supabase.from('subscriptions').insert({
        'user_id': user.id,
        'device_id': deviceId,
        'plan_id': planId,
        'status': 'trial',
        'trial_start': now.toIso8601String(),
        'trial_end': trialEnd.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      return UserSubscription.startTrial(
        odId: user.id,
        planId: planId,
        trialDays: trialDays,
      );
    } catch (e) {
      // Si falla por conflicto, intentar obtener la suscripcion existente
      return await getSubscription();
    }
  }

  /// Activar suscripcion (despues de pago en Stripe)
  static Future<bool> activateSubscription({
    required String planId,
    required bool isAnnual,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final endDate = isAnnual
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));

    try {
      await _supabase.from('subscriptions').upsert({
        'user_id': user.id,
        'device_id': await getDeviceId(),
        'plan_id': planId,
        'status': 'active',
        'subscription_start': now.toIso8601String(),
        'subscription_end': endDate.toIso8601String(),
        'is_annual': isAnnual,
        'stripe_customer_id': stripeCustomerId,
        'stripe_subscription_id': stripeSubscriptionId,
        'updated_at': now.toIso8601String(),
      }, onConflict: 'user_id');

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si tiene suscripcion activa
  static Future<bool> hasActiveSubscription() async {
    final sub = await getSubscription();
    if (sub == null) return false;
    return sub.hasActiveSubscription;
  }

  /// Verificar si trial esta activo
  static Future<bool> isTrialActive() async {
    final sub = await getSubscription();
    if (sub == null) return false;
    return sub.isTrialActive;
  }

  /// Obtener dias restantes de trial
  static Future<int> getTrialDaysRemaining() async {
    final sub = await getSubscription();
    if (sub == null) return 0;
    return sub.trialDaysRemaining;
  }

  /// Verificar estado y actualizar si expiro
  static Future<void> checkAndUpdateStatus() async {
    final sub = await getSubscription();
    if (sub == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Si trial expiro, actualizar a expired
    if (sub.status == SubscriptionStatus.trial && !sub.isTrialActive) {
      await _supabase
          .from('subscriptions')
          .update({
            'status': 'expired',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);
    }

    // Si suscripcion expiro
    if (sub.status == SubscriptionStatus.active &&
        sub.subscriptionEndDate != null &&
        DateTime.now().isAfter(sub.subscriptionEndDate!)) {
      await _supabase
          .from('subscriptions')
          .update({
            'status': 'expired',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);
    }
  }

  static SubscriptionStatus _parseStatus(String? status) {
    switch (status) {
      case 'trial':
        return SubscriptionStatus.trial;
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.free;
    }
  }
}
