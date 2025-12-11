import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/gemini_config.dart';

/// Modelo de mensaje de chat
class ChatMessage {
  final String id;
  final String conversationId;
  final String role; // 'user' o 'model'
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      role: json['role'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'role': role,
      'content': content,
    };
  }

  Content toGeminiContent() {
    return Content(role, [TextPart(content)]);
  }
}

/// Servicio para chat con Gemini IA
class GeminiChatService {
  static GeminiChatService? _instance;
  late GenerativeModel _model;
  late ChatSession _chatSession;
  String? _currentConversationId;
  final List<ChatMessage> _messages = [];

  final _supabase = Supabase.instance.client;

  GeminiChatService._();

  static GeminiChatService get instance {
    _instance ??= GeminiChatService._();
    return _instance!;
  }

  /// Inicializa el servicio con contexto del negocio
  Future<void> initialize({
    double? ventasMes,
    double? gastosMes,
    double? gananciaMes,
    int? totalProductos,
    String? topProductos,
  }) async {
    final systemPrompt = GeminiConfig.getSystemPrompt(
      ventasMes: ventasMes,
      gastosMes: gastosMes,
      gananciaMes: gananciaMes,
      totalProductos: totalProductos,
      topProductos: topProductos,
    );

    _model = GenerativeModel(
      model: GeminiConfig.model,
      apiKey: GeminiConfig.apiKey,
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
      ),
    );
  }

  /// Inicia una nueva conversacion
  Future<void> startNewConversation() async {
    _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages.clear();

    // Cargar historial de Gemini con los mensajes previos
    _chatSession = _model.startChat(history: []);
  }

  /// Carga una conversacion existente
  Future<void> loadConversation(String conversationId) async {
    _currentConversationId = conversationId;
    _messages.clear();

    try {
      // Cargar mensajes de Supabase
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at');

      for (final json in response) {
        _messages.add(ChatMessage.fromJson(json));
      }

      // Iniciar sesion de chat con historial
      final history = _messages.map((m) => m.toGeminiContent()).toList();
      _chatSession = _model.startChat(history: history);
    } catch (e) {
      // Si falla, iniciar sin historial
      _chatSession = _model.startChat(history: []);
    }
  }

  /// Envia un mensaje y obtiene respuesta
  Future<String> sendMessage(String message) async {
    if (_currentConversationId == null) {
      await startNewConversation();
    }

    final userId = _supabase.auth.currentUser?.id;

    // Guardar mensaje del usuario
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _currentConversationId!,
      role: 'user',
      content: message,
      createdAt: DateTime.now(),
    );
    _messages.add(userMessage);

    // Guardar en Supabase si hay usuario
    if (userId != null) {
      try {
        await _supabase.from('chat_messages').insert({
          'user_id': userId,
          ...userMessage.toJson(),
        });
      } catch (e) {
        // Ignorar error de persistencia
      }
    }

    try {
      // Enviar a Gemini
      final response = await _chatSession.sendMessage(Content.text(message));
      final responseText = response.text ?? 'No pude generar una respuesta.';

      // Guardar respuesta del modelo
      final modelMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: _currentConversationId!,
        role: 'model',
        content: responseText,
        createdAt: DateTime.now(),
      );
      _messages.add(modelMessage);

      // Guardar en Supabase si hay usuario
      if (userId != null) {
        try {
          await _supabase.from('chat_messages').insert({
            'user_id': userId,
            ...modelMessage.toJson(),
          });
        } catch (e) {
          // Ignorar error de persistencia
        }
      }

      return responseText;
    } catch (e) {
      return 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.';
    }
  }

  /// Obtiene los mensajes de la conversacion actual
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Obtiene el ID de la conversacion actual
  String? get currentConversationId => _currentConversationId;

  /// Obtiene las conversaciones del usuario
  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('chat_messages')
          .select('conversation_id, created_at, content')
          .eq('user_id', userId)
          .eq('role', 'user')
          .order('created_at', ascending: false);

      // Agrupar por conversation_id y obtener el primer mensaje
      final Map<String, Map<String, dynamic>> conversations = {};
      for (final msg in response) {
        final convId = msg['conversation_id'] as String;
        if (!conversations.containsKey(convId)) {
          conversations[convId] = {
            'conversation_id': convId,
            'created_at': msg['created_at'],
            'first_message': msg['content'],
          };
        }
      }

      return conversations.values.toList();
    } catch (e) {
      return [];
    }
  }
}
