/// Strings de internacionalizacion para pricing
class PricingStrings {
  static const Map<String, Map<String, String>> _strings = {
    // Espanol
    'es': {
      'title': 'Planes y Precios',
      'subtitle': 'Elige el plan perfecto para tu negocio',
      'monthly': 'Mensual',
      'annual': 'Anual',
      'perMonth': '/mes',
      'perYear': '/año',
      'save': 'Ahorra',
      'free': 'Gratis',
      'mostPopular': 'Mas Popular',
      'recommended': 'Recomendado',
      'selectPlan': 'Elegir Plan',
      'startTrial': 'Iniciar Prueba Gratis',
      'trialDays': 'dias de prueba',
      'trialRemaining': 'dias restantes de prueba',
      'trialExpired': 'Tu prueba ha expirado',
      'upgrade': 'Mejorar Plan',
      'currentPlan': 'Plan Actual',
      'features': 'Caracteristicas',
      'compare': 'Comparar Planes',
      'faq': 'Preguntas Frecuentes',
      'support': 'Soporte',
      'chatTitle': 'Chat de Ayuda',
      'chatPlaceholder': 'Escribe tu pregunta...',
      'termsTitle': 'Terminos y Condiciones',
      'privacyTitle': 'Politica de Privacidad',
      'acceptTerms': 'Acepto los terminos y condiciones',
      'login': 'Iniciar Sesion',
      'register': 'Registrarse',
      'contacts': 'contactos',
      'users': 'usuarios',
      'unlimited': 'Ilimitado',
      'included': 'Incluido',
      'notIncluded': 'No incluido',
      'currency': 'USD',
      'currencySymbol': '\$',
    },
    // English
    'en': {
      'title': 'Plans & Pricing',
      'subtitle': 'Choose the perfect plan for your business',
      'monthly': 'Monthly',
      'annual': 'Annual',
      'perMonth': '/mo',
      'perYear': '/yr',
      'save': 'Save',
      'mostPopular': 'Most Popular',
      'recommended': 'Recommended',
      'selectPlan': 'Select Plan',
      'startTrial': 'Start Free Trial',
      'trialDays': 'days trial',
      'trialRemaining': 'trial days remaining',
      'trialExpired': 'Your trial has expired',
      'upgrade': 'Upgrade Plan',
      'currentPlan': 'Current Plan',
      'features': 'Features',
      'compare': 'Compare Plans',
      'faq': 'FAQ',
      'support': 'Support',
      'chatTitle': 'Help Chat',
      'chatPlaceholder': 'Type your question...',
      'termsTitle': 'Terms & Conditions',
      'privacyTitle': 'Privacy Policy',
      'acceptTerms': 'I accept the terms and conditions',
      'login': 'Login',
      'register': 'Sign Up',
      'contacts': 'contacts',
      'users': 'users',
      'unlimited': 'Unlimited',
      'included': 'Included',
      'notIncluded': 'Not included',
      'currency': 'USD',
      'currencySymbol': '\$',
    },
    // Portugues
    'pt': {
      'title': 'Planos e Precos',
      'subtitle': 'Escolha o plano perfeito para o seu negocio',
      'monthly': 'Mensal',
      'annual': 'Anual',
      'perMonth': '/mes',
      'perYear': '/ano',
      'save': 'Economize',
      'mostPopular': 'Mais Popular',
      'recommended': 'Recomendado',
      'selectPlan': 'Escolher Plano',
      'startTrial': 'Iniciar Teste Gratis',
      'trialDays': 'dias de teste',
      'trialRemaining': 'dias restantes de teste',
      'trialExpired': 'Seu teste expirou',
      'upgrade': 'Atualizar Plano',
      'currentPlan': 'Plano Atual',
      'features': 'Recursos',
      'compare': 'Comparar Planos',
      'faq': 'Perguntas Frequentes',
      'support': 'Suporte',
      'chatTitle': 'Chat de Ajuda',
      'chatPlaceholder': 'Digite sua pergunta...',
      'termsTitle': 'Termos e Condicoes',
      'privacyTitle': 'Politica de Privacidade',
      'acceptTerms': 'Aceito os termos e condicoes',
      'login': 'Entrar',
      'register': 'Cadastrar',
      'contacts': 'contatos',
      'users': 'usuarios',
      'unlimited': 'Ilimitado',
      'included': 'Incluido',
      'notIncluded': 'Nao incluido',
      'currency': 'BRL',
      'currencySymbol': 'R\$',
    },
  };

  static String _currentLocale = 'es';

  /// Establecer idioma
  static void setLocale(String locale) {
    if (_strings.containsKey(locale)) {
      _currentLocale = locale;
    }
  }

  /// Obtener idioma actual
  static String get currentLocale => _currentLocale;

  /// Obtener string
  static String get(String key) {
    return _strings[_currentLocale]?[key] ?? _strings['es']?[key] ?? key;
  }

  /// Detectar idioma del sistema
  static void detectSystemLocale(String systemLocale) {
    final lang = systemLocale.split('_').first.toLowerCase();
    if (_strings.containsKey(lang)) {
      _currentLocale = lang;
    }
  }

  /// Idiomas disponibles
  static List<String> get availableLocales => _strings.keys.toList();

  /// Obtener simbolo de moneda
  static String get currencySymbol => get('currencySymbol');

  /// Formatear precio
  static String formatPrice(double price) {
    return '${currencySymbol}${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)}';
  }
}
