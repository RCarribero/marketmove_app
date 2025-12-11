import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

/// Servicio para manejar el tutorial interactivo con coach marks
class InteractiveTutorialService {
  static const String _keyTutorialShown = 'interactive_tutorial_shown_v1';

  /// Verifica si el tutorial ya fue mostrado
  static Future<bool> hasShownTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTutorialShown) ?? false;
  }

  /// Marca el tutorial como mostrado
  static Future<void> markTutorialAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialShown, true);
  }

  /// Resetea el tutorial para mostrarlo de nuevo
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTutorialShown);
  }

  /// Crea y muestra el tutorial
  static void showTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) {
    if (targets.isEmpty) return;

    TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.primary,
      textSkip: "OMITIR",
      paddingFocus: 10,
      opacityShadow: 0.85,
      hideSkip: false,
      onFinish: () {
        markTutorialAsShown();
        onFinish?.call();
      },
      onSkip: () {
        markTutorialAsShown();
        onSkip?.call();
        return true;
      },
    ).show(context: context);
  }

  /// Crea un target con estilo consistente
  static TargetFocus createTarget({
    required GlobalKey key,
    required String title,
    required String description,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double radius = 8,
  }) {
    return TargetFocus(
      identify: key.toString(),
      keyTarget: key,
      alignSkip: Alignment.topRight,
      enableOverlayTab: true,
      shape: shape,
      radius: radius,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Toca para continuar',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
