import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Roles de usuario
enum UserRole { guest, trial, free, premium, admin }

/// Servicio de autenticacion simulado para pricing
class PricingAuthService {
  static const String _userKey = 'pricing_user';
  static const String _tokenKey = 'pricing_token';
  static const String _tokenExpiryKey = 'pricing_token_expiry';

  /// Usuario simulado
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Verificar si esta logueado
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    if (user == null) return false;

    // Verificar token no expirado
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getString(_tokenExpiryKey);
    if (expiry != null) {
      final expiryDate = DateTime.tryParse(expiry);
      if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
        await logout();
        return false;
      }
    }
    return true;
  }

  /// Obtener rol del usuario
  static Future<UserRole> getUserRole() async {
    final user = await getCurrentUser();
    if (user == null) return UserRole.guest;

    final roleStr = user['role'] as String? ?? 'free';
    return UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.free,
    );
  }

  /// Login simulado
  static Future<bool> login({
    required String email,
    required String password,
    UserRole role = UserRole.trial,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Simular usuario
    final user = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'role': role.name,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Token expira en 7 dias
    final tokenExpiry = DateTime.now().add(const Duration(days: 7));

    await prefs.setString(_userKey, jsonEncode(user));
    await prefs.setString(_tokenKey, 'simulated_token_${user['id']}');
    await prefs.setString(_tokenExpiryKey, tokenExpiry.toIso8601String());

    return true;
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  /// Actualizar rol
  static Future<void> updateRole(UserRole newRole) async {
    final user = await getCurrentUser();
    if (user == null) return;

    user['role'] = newRole.name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  /// Obtener token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Verificar si es premium
  static Future<bool> isPremium() async {
    final role = await getUserRole();
    return role == UserRole.premium || role == UserRole.admin;
  }

  /// Verificar si es trial
  static Future<bool> isTrial() async {
    final role = await getUserRole();
    return role == UserRole.trial;
  }
}
