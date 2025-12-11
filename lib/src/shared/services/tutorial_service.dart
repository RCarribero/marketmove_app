import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el estado del tutorial onboarding
class TutorialService {
  static const _keyTutorialSeen = 'onboarding_tutorial_seen';
  static const _keyTutorialVersion = 'onboarding_tutorial_version';

  /// Version actual del tutorial (incrementar si se agregan nuevos pasos)
  static const int currentVersion = 1;

  /// Verifica si el usuario ya vio el tutorial (de la version actual)
  static Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_keyTutorialSeen) ?? false;
    final version = prefs.getInt(_keyTutorialVersion) ?? 0;

    // Si la version cambio, mostrar tutorial de nuevo
    if (version < currentVersion) {
      return false;
    }

    return seen;
  }

  /// Marca el tutorial como visto
  static Future<void> markTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialSeen, true);
    await prefs.setInt(_keyTutorialVersion, currentVersion);
  }

  /// Resetea el tutorial para mostrarlo de nuevo
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTutorialSeen);
  }
}
