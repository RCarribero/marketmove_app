import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio de IA con Google Gemini y memoria de chat
class GeminiService {
  static const String _apiKey =
      'YOUR_GEMINI_API_KEY'; // Reemplazar con tu API key
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Historial de mensajes para mantener contexto
  final List<Map<String, String>> _history = [];

  /// Prompt del sistema para definir personalidad del asistente
  static const String _systemPrompt = '''
Eres un asistente de soporte amigable y profesional para MarketMove, una aplicacion de gestion de ventas y gastos para negocios.

Tu rol es:
- Responder preguntas sobre los planes de precios (Mensual 29 euros, Anual 299 euros, Pago Unico 999 euros)
- Explicar las funcionalidades de la app (ventas, gastos, productos, reportes, reportes avanzados)
- Ayudar con dudas sobre el trial de 30 dias
- Guiar sobre como usar la aplicacion
- Ser amable, conciso y util

Responde siempre en espanol y de forma breve (maximo 2-3 oraciones).
Si no sabes algo, sugiere contactar a soporte@marketmove.com
''';

  /// Enviar mensaje y obtener respuesta
  Future<String> sendMessage(String userMessage) async {
    // Agregar mensaje del usuario al historial
    _history.add({'role': 'user', 'content': userMessage});

    try {
      // Construir el contenido con historial
      final contents = <Map<String, dynamic>>[];

      // Agregar system prompt como primer mensaje
      contents.add({
        'role': 'user',
        'parts': [
          {'text': _systemPrompt},
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'Entendido. Soy el asistente de MarketMove. Como puedo ayudarte?',
          },
        ],
      });

      // Agregar historial de conversacion
      for (final msg in _history) {
        contents.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [
            {'text': msg['content']},
          ],
        });
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 256},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'Lo siento, no pude procesar tu mensaje.';

        // Agregar respuesta al historial
        _history.add({'role': 'assistant', 'content': text});

        return text;
      } else {
        return 'Error de conexion. Intenta de nuevo.';
      }
    } catch (e) {
      return 'Error: No se pudo conectar con el servicio. Intenta mas tarde.';
    }
  }

  /// Limpiar historial de chat
  void clearHistory() {
    _history.clear();
  }

  /// Obtener numero de mensajes en historial
  int get historyLength => _history.length;
}
