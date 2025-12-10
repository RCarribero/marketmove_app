import 'package:flutter/material.dart';
import '../l10n/pricing_strings.dart';
import '../../../shared/theme/colors.dart';

/// Modal de Terminos y Condiciones / Privacidad
class TermsModal extends StatefulWidget {
  final bool isDark;
  final VoidCallback onAccept;
  final VoidCallback? onDecline;

  const TermsModal({
    super.key,
    required this.isDark,
    required this.onAccept,
    this.onDecline,
  });

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TermsModal(
        isDark: Theme.of(context).brightness == Brightness.dark,
        onAccept: () => Navigator.of(ctx).pop(true),
        onDecline: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  State<TermsModal> createState() => _TermsModalState();
}

class _TermsModalState extends State<TermsModal> {
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: widget.isDark
          ? AppColors.darkCardBackground
          : Colors.white,
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.policy, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Terminos Legales',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tabs
            Row(
              children: [
                _TabButton(
                  label: PricingStrings.get('termsTitle'),
                  isSelected: _currentTab == 0,
                  onTap: () => setState(() => _currentTab = 0),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: PricingStrings.get('privacyTitle'),
                  isSelected: _currentTab == 1,
                  onTap: () => setState(() => _currentTab = 1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _currentTab == 0 ? _termsContent : _privacyContent,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: widget.isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Checkboxes
            _CheckboxRow(
              label: 'He leido y acepto los Terminos y Condiciones',
              value: _acceptedTerms,
              onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
              isDark: widget.isDark,
            ),
            const SizedBox(height: 8),
            _CheckboxRow(
              label: 'He leido y acepto la Politica de Privacidad',
              value: _acceptedPrivacy,
              onChanged: (v) => setState(() => _acceptedPrivacy = v ?? false),
              isDark: widget.isDark,
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onDecline != null)
                  TextButton(
                    onPressed: widget.onDecline,
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: widget.isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _acceptedTerms && _acceptedPrivacy
                      ? widget.onAccept
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Aceptar y Continuar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _termsContent = '''
TERMINOS Y CONDICIONES DE USO

1. ACEPTACION DE TERMINOS
Al acceder y utilizar MarketMove CRM, usted acepta estar sujeto a estos Terminos y Condiciones.

2. USO DEL SERVICIO
El servicio esta destinado unicamente para uso comercial legitimo. Usted se compromete a no utilizar el servicio para actividades ilegales o no autorizadas.

3. CUENTA DE USUARIO
Usted es responsable de mantener la confidencialidad de su cuenta y contrasena. Notifique inmediatamente cualquier uso no autorizado.

4. FACTURACION Y PAGOS
Los planes de pago se facturan segun el periodo seleccionado (mensual o anual). Los precios pueden cambiar con previo aviso de 30 dias.

5. CANCELACION
Puede cancelar su suscripcion en cualquier momento. El acceso continuara hasta el final del periodo de facturacion actual.

6. PROPIEDAD INTELECTUAL
Todo el contenido, marcas y software son propiedad de MarketMove. No puede copiar, modificar o distribuir ninguna parte del servicio.

7. LIMITACION DE RESPONSABILIDAD
El servicio se proporciona "tal cual". No garantizamos que el servicio sea ininterrumpido o libre de errores.

8. MODIFICACIONES
Nos reservamos el derecho de modificar estos terminos. Los cambios entraran en vigor al publicarse en el sitio.

9. LEY APLICABLE
Estos terminos se rigen por las leyes aplicables de la jurisdiccion correspondiente.

10. CONTACTO
Para consultas sobre estos terminos, contacte a: legal@marketmove.com
''';

  static const _privacyContent = '''
POLITICA DE PRIVACIDAD

1. INFORMACION QUE RECOPILAMOS
Recopilamos informacion que usted proporciona directamente, como nombre, email, y datos de facturacion.

2. USO DE LA INFORMACION
Utilizamos su informacion para:
- Proporcionar y mejorar nuestros servicios
- Procesar pagos y transacciones
- Enviar comunicaciones relacionadas con el servicio
- Prevenir fraudes y abusos

3. ALMACENAMIENTO DE DATOS
Sus datos se almacenan de forma segura en servidores protegidos. Implementamos medidas de seguridad estandar de la industria.

4. COMPARTIR INFORMACION
No vendemos su informacion personal. Solo compartimos datos con:
- Proveedores de servicios necesarios para operar
- Cuando lo requiera la ley
- Con su consentimiento explicito

5. COOKIES Y TECNOLOGIAS SIMILARES
Utilizamos cookies para mejorar su experiencia. Puede gestionar las preferencias de cookies en su navegador.

6. DERECHOS DEL USUARIO
Usted tiene derecho a:
- Acceder a sus datos personales
- Rectificar informacion incorrecta
- Solicitar eliminacion de datos
- Oponerse al procesamiento

7. RETENCION DE DATOS
Conservamos sus datos mientras tenga una cuenta activa o segun lo requiera la ley.

8. MENORES DE EDAD
El servicio no esta dirigido a menores de 18 anos. No recopilamos intencionalmente datos de menores.

9. CAMBIOS EN LA POLITICA
Notificaremos cambios significativos a traves de email o aviso en el servicio.

10. CONTACTO
Para consultas de privacidad: privacy@marketmove.com
''';
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isDark;

  const _CheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
