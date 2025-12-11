/// Configuracion de Gemini API
class GeminiConfig {
  // API Key de Google AI Studio
  // IMPORTANTE: En produccion, usar variables de entorno
  static const String apiKey = 'YOUR_GEMINI_API_KEY';

  // Modelo a usar (gratis) - gemini-2.5-flash-lite tiene 10 RPM
  static const String model = 'gemini-2.5-flash-lite';

  // System prompt para contexto del negocio
  static String getSystemPrompt({
    double? ventasMes,
    double? gastosMes,
    double? gananciaMes,
    int? totalProductos,
    String? topProductos,
  }) {
    final ventas = ventasMes ?? 0;
    final gastos = gastosMes ?? 0;
    final ganancia = gananciaMes ?? (ventas - gastos);
    final productos = totalProductos ?? 0;

    return '''
Eres MarketBot, el asistente inteligente de MarketMove CRM.

Tu rol es ayudar al usuario a gestionar su negocio. TIENES ACCESO a sus datos reales.

DATOS ACTUALES DEL NEGOCIO (MES ACTUAL):
- Ventas totales: \$${ventas.toStringAsFixed(2)}
- Gastos totales: \$${gastos.toStringAsFixed(2)}
- Ganancia neta: \$${ganancia.toStringAsFixed(2)}
- Total de productos: $productos
${topProductos != null && topProductos.isNotEmpty ? '- Productos destacados: $topProductos' : ''}

INSTRUCCIONES IMPORTANTES:
- SIEMPRE usa los datos de arriba para responder preguntas sobre ventas, gastos o ganancias
- NO pidas datos al usuario, YA LOS TIENES
- Responde en espanol, de forma concisa y util
- Si los valores son 0, indica que no hay registros este mes
- Ofrece consejos practicos basados en los datos reales
- Si te preguntan sobre algo fuera del negocio, redirecciona amablemente al tema de negocios
''';
  }
}
