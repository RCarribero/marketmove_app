import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  static final _supabase = Supabase.instance.client;

  /// Envia un email con archivo adjunto usando la Edge Function
  static Future<bool> sendEmailWithAttachment({
    required String to,
    required String subject,
    required String body,
    File? attachment,
    String? attachmentName,
  }) async {
    try {
      // Prepare attachment if provided
      String? attachmentBase64;
      String? fileName;

      if (attachment != null && await attachment.exists()) {
        final bytes = await attachment.readAsBytes();
        attachmentBase64 = base64Encode(bytes);
        fileName = attachmentName ?? attachment.path.split('/').last;
      }

      // Call Edge Function
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'to': to,
          'subject': subject,
          'body': body,
          if (attachmentBase64 != null) 'attachmentBase64': attachmentBase64,
          if (fileName != null) 'attachmentName': fileName,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Error desconocido';
        throw Exception(error);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Envia un reporte por email
  static Future<bool> sendReport({
    required String recipientEmail,
    required String reportType,
    required String period,
    required File reportFile,
  }) async {
    final subject = 'Reporte MarketMove - $reportType';
    final body =
        '''
Adjunto encontraras el reporte de $reportType correspondiente al periodo: $period.

Este reporte fue generado automaticamente desde la aplicacion MarketMove.

Contenido del reporte:
- $reportType
- Periodo: $period
- Generado: ${DateTime.now().toString().split('.')[0]}

Saludos cordiales,
El equipo de MarketMove
''';

    return sendEmailWithAttachment(
      to: recipientEmail,
      subject: subject,
      body: body,
      attachment: reportFile,
      attachmentName: reportFile.path.split('/').last,
    );
  }
}
