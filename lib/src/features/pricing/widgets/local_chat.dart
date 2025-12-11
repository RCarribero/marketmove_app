import 'package:flutter/material.dart';
import '../l10n/pricing_strings.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/services/gemini_service.dart';

/// Widget de chat con IA (Gemini) y FAQ
class LocalChat extends StatefulWidget {
  final bool isDark;

  const LocalChat({super.key, required this.isDark});

  @override
  State<LocalChat> createState() => _LocalChatState();
}

class _LocalChatState extends State<LocalChat> {
  final _controller = TextEditingController();
  final _messages = <ChatMessage>[];
  final _gemini = GeminiService();
  bool _isTyping = false;

  final _faqs = [
    FAQ(
      question: 'Como funciona la prueba gratis?',
      answer:
          'Tienes 30 dias para probar todas las funciones del plan Pro sin costo. No necesitas tarjeta de credito.',
    ),
    FAQ(
      question: 'Puedo cambiar de plan despues?',
      answer:
          'Si, puedes cambiar tu plan en cualquier momento. El cambio se aplica inmediatamente.',
    ),
    FAQ(
      question: 'Que metodos de pago aceptan?',
      answer:
          'Aceptamos tarjetas de credito/debito (Visa, Mastercard, Amex) y PayPal.',
    ),
    FAQ(
      question: 'Puedo cancelar cuando quiera?',
      answer:
          'Si, puedes cancelar en cualquier momento. No hay penalizaciones ni contratos.',
    ),
    FAQ(
      question: 'Hay descuentos para equipos grandes?',
      answer:
          'Si, ofrecemos descuentos especiales para equipos de mas de 10 usuarios. Contactanos.',
    ),
  ];

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();

    // Obtener respuesta de Gemini
    final response = await _gemini.sendMessage(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: response, isUser: false));
      });
    }
  }

  void _selectFaq(FAQ faq) async {
    setState(() {
      _messages.add(ChatMessage(text: faq.question, isUser: true));
      _isTyping = true;
    });

    // Obtener respuesta de IA para la FAQ
    final response = await _gemini.sendMessage(faq.question);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: response, isUser: false));
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 500,
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PricingStrings.get('chatTitle'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Respuestas instantaneas',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty ? _buildFAQList() : _buildMessagesList(),
          ),

          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TypingDot(delay: 0),
                        _TypingDot(delay: 150),
                        _TypingDot(delay: 300),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.darkSurfaceVariant
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: PricingStrings.get('chatPlaceholder'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: widget.isDark
                          ? AppColors.darkCardBackground
                          : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _sendMessage(_controller.text),
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          PricingStrings.get('faq'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: widget.isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._faqs.map(
          (faq) => _FAQItem(
            faq: faq,
            isDark: widget.isDark,
            onTap: () => _selectFaq(faq),
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _MessageBubble(message: msg, isDark: widget.isDark);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary
              : (isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final FAQ faq;
  final bool isDark;
  final VoidCallback onTap;

  const _FAQItem({
    required this.faq,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.help_outline, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                faq.question,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha((150 + 100 * _controller.value).toInt()),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class FAQ {
  final String question;
  final String answer;
  FAQ({required this.question, required this.answer});
}
