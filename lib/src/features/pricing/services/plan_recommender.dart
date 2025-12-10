/// Recomendador de plan basado en respuestas del usuario (IA simulada)
class PlanRecommender {
  /// Preguntas para el quiz de recomendacion
  static List<RecommenderQuestion> getQuestions() {
    return [
      RecommenderQuestion(
        id: 'team_size',
        question: 'Cuantas personas usaran el CRM?',
        options: [
          QuestionOption(
            value: '1',
            label: 'Solo yo',
            points: {'free': 3, 'pro': 1, 'enterprise': 0},
          ),
          QuestionOption(
            value: '2-5',
            label: '2-5 personas',
            points: {'free': 0, 'pro': 3, 'enterprise': 1},
          ),
          QuestionOption(
            value: '5+',
            label: 'Mas de 5',
            points: {'free': 0, 'pro': 1, 'enterprise': 3},
          ),
        ],
      ),
      RecommenderQuestion(
        id: 'contacts',
        question: 'Cuantos contactos gestionas aproximadamente?',
        options: [
          QuestionOption(
            value: '<100',
            label: 'Menos de 100',
            points: {'free': 3, 'pro': 1, 'enterprise': 0},
          ),
          QuestionOption(
            value: '100-1000',
            label: '100 - 1,000',
            points: {'free': 1, 'pro': 3, 'enterprise': 1},
          ),
          QuestionOption(
            value: '1000+',
            label: 'Mas de 1,000',
            points: {'free': 0, 'pro': 2, 'enterprise': 3},
          ),
        ],
      ),
      RecommenderQuestion(
        id: 'automation',
        question: 'Necesitas automatizaciones?',
        options: [
          QuestionOption(
            value: 'no',
            label: 'No las necesito',
            points: {'free': 3, 'pro': 1, 'enterprise': 0},
          ),
          QuestionOption(
            value: 'basic',
            label: 'Basicas',
            points: {'free': 0, 'pro': 3, 'enterprise': 1},
          ),
          QuestionOption(
            value: 'advanced',
            label: 'Avanzadas',
            points: {'free': 0, 'pro': 1, 'enterprise': 3},
          ),
        ],
      ),
      RecommenderQuestion(
        id: 'support',
        question: 'Que nivel de soporte necesitas?',
        options: [
          QuestionOption(
            value: 'email',
            label: 'Email es suficiente',
            points: {'free': 3, 'pro': 1, 'enterprise': 0},
          ),
          QuestionOption(
            value: 'priority',
            label: 'Soporte prioritario',
            points: {'free': 0, 'pro': 3, 'enterprise': 1},
          ),
          QuestionOption(
            value: 'dedicated',
            label: 'Manager dedicado',
            points: {'free': 0, 'pro': 0, 'enterprise': 3},
          ),
        ],
      ),
    ];
  }

  /// Calcular recomendacion basado en respuestas
  static RecommendationResult getRecommendation(Map<String, String> answers) {
    final scores = {'free': 0, 'pro': 0, 'enterprise': 0};
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
    String recommendedPlan = 'pro';
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
      case 'free':
        reasons.add('Perfecto para comenzar sin costo');
        if (answers['team_size'] == '1') {
          reasons.add('Ideal para uso individual');
        }
        if (answers['contacts'] == '<100') {
          reasons.add('100 contactos son suficientes para ti');
        }
        break;
      case 'pro':
        reasons.add('Mejor relacion calidad-precio');
        if (answers['team_size'] == '2-5') {
          reasons.add('Incluye 5 usuarios para tu equipo');
        }
        if (answers['automation'] == 'basic') {
          reasons.add('Automatizaciones incluidas');
        }
        reasons.add('Soporte prioritario incluido');
        break;
      case 'enterprise':
        reasons.add('Sin limites para escalar');
        if (answers['team_size'] == '5+') {
          reasons.add('Usuarios ilimitados para equipos grandes');
        }
        if (answers['contacts'] == '1000+') {
          reasons.add('Contactos ilimitados');
        }
        reasons.add('Manager de cuenta dedicado');
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
