/// Recomendador de plan basado en respuestas del usuario
class PlanRecommender {
  /// Preguntas para el quiz de recomendacion
  static List<RecommenderQuestion> getQuestions() {
    return [
      RecommenderQuestion(
        id: 'usage_frequency',
        question: 'Con que frecuencia usaras el CRM?',
        options: [
          QuestionOption(
            value: 'occasional',
            label: 'Ocasionalmente',
            points: {'monthly': 3, 'annual': 1, 'lifetime': 0},
          ),
          QuestionOption(
            value: 'regular',
            label: 'Regularmente (varias veces por semana)',
            points: {'monthly': 1, 'annual': 3, 'lifetime': 1},
          ),
          QuestionOption(
            value: 'daily',
            label: 'A diario, es mi herramienta principal',
            points: {'monthly': 0, 'annual': 2, 'lifetime': 3},
          ),
        ],
      ),
      RecommenderQuestion(
        id: 'time_horizon',
        question: 'Por cuanto tiempo planeas usar el CRM?',
        options: [
          QuestionOption(
            value: 'short',
            label: 'Solo unos meses',
            points: {'monthly': 3, 'annual': 0, 'lifetime': 0},
          ),
          QuestionOption(
            value: 'year',
            label: 'Al menos un año',
            points: {'monthly': 0, 'annual': 3, 'lifetime': 1},
          ),
          QuestionOption(
            value: 'long',
            label: 'Varios años, es para mi negocio',
            points: {'monthly': 0, 'annual': 1, 'lifetime': 3},
          ),
        ],
      ),
      RecommenderQuestion(
        id: 'budget',
        question: 'Cual es tu preferencia de pago?',
        options: [
          QuestionOption(
            value: 'low_monthly',
            label: 'Prefiero pagar poco cada mes',
            points: {'monthly': 3, 'annual': 1, 'lifetime': 0},
          ),
          QuestionOption(
            value: 'save_annual',
            label: 'Puedo pagar anual para ahorrar',
            points: {'monthly': 0, 'annual': 3, 'lifetime': 1},
          ),
          QuestionOption(
            value: 'one_time',
            label: 'Prefiero un pago unico y olvidarme',
            points: {'monthly': 0, 'annual': 0, 'lifetime': 3},
          ),
        ],
      ),
      RecommenderQuestion(
        id: 'business_stage',
        question: 'En que etapa esta tu negocio?',
        options: [
          QuestionOption(
            value: 'starting',
            label: 'Estoy empezando',
            points: {'monthly': 3, 'annual': 1, 'lifetime': 0},
          ),
          QuestionOption(
            value: 'growing',
            label: 'En crecimiento',
            points: {'monthly': 1, 'annual': 3, 'lifetime': 2},
          ),
          QuestionOption(
            value: 'established',
            label: 'Negocio establecido',
            points: {'monthly': 0, 'annual': 2, 'lifetime': 3},
          ),
        ],
      ),
    ];
  }

  /// Calcular recomendacion basado en respuestas
  static RecommendationResult getRecommendation(Map<String, String> answers) {
    final scores = {'monthly': 0, 'annual': 0, 'lifetime': 0};
    final questions = getQuestions();

    for (final question in questions) {
      final answer = answers[question.id];
      if (answer == null) continue;

      final option = question.options.firstWhere(
        (o) => o.value == answer,
        orElse: () => question.options.first,
      );

      for (final entry in option.points.entries) {
        scores[entry.key] = (scores[entry.key] ?? 0) + entry.value;
      }
    }

    // Determinar plan recomendado
    String recommendedPlan = 'annual';
    int maxScore = 0;

    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        recommendedPlan = entry.key;
      }
    }

    return RecommendationResult(
      planId: recommendedPlan,
      scores: scores,
      reasons: _getReasons(recommendedPlan, answers),
    );
  }

  static List<String> _getReasons(String planId, Map<String, String> answers) {
    final reasons = <String>[];

    switch (planId) {
      case 'monthly':
        reasons.add('Flexibilidad para cancelar cuando quieras');
        if (answers['usage_frequency'] == 'occasional') {
          reasons.add('Ideal para uso ocasional');
        }
        if (answers['business_stage'] == 'starting') {
          reasons.add('Perfecto para probar sin compromiso');
        }
        reasons.add('Pago mensual de \$29');
        break;
      case 'annual':
        reasons.add('Mejor relacion calidad-precio');
        if (answers['time_horizon'] == 'year') {
          reasons.add('Ahorras \$49 al año');
        }
        if (answers['usage_frequency'] == 'regular') {
          reasons.add('Ideal para uso regular');
        }
        reasons.add('Equivale a \$24.92/mes');
        break;
      case 'lifetime':
        reasons.add('Pago unico, acceso de por vida');
        if (answers['time_horizon'] == 'long') {
          reasons.add('Se paga solo en menos de 3 años');
        }
        if (answers['business_stage'] == 'established') {
          reasons.add('Inversion inteligente para tu negocio');
        }
        reasons.add('Sin pagos recurrentes');
        break;
    }

    return reasons;
  }
}

class RecommenderQuestion {
  final String id;
  final String question;
  final List<QuestionOption> options;

  const RecommenderQuestion({
    required this.id,
    required this.question,
    required this.options,
  });
}

class QuestionOption {
  final String value;
  final String label;
  final Map<String, int> points;

  const QuestionOption({
    required this.value,
    required this.label,
    required this.points,
  });
}

class RecommendationResult {
  final String planId;
  final Map<String, int> scores;
  final List<String> reasons;

  const RecommendationResult({
    required this.planId,
    required this.scores,
    required this.reasons,
  });

  int get confidence {
    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    final totalScore = scores.values.reduce((a, b) => a + b);
    if (totalScore == 0) return 0;
    return ((maxScore / totalScore) * 100).round();
  }
}
