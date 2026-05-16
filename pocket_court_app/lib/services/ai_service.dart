import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// All AI calls go through our own backend proxy.
/// The Gemini API key lives only on the server — never in the app.
class AiService {
  static Future<String> getResponse(String userMessage) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/ai/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': userMessage}),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] != null) {
          return json['data'] as String;
        }
      }
      return _fallback(userMessage);
    } catch (_) {
      return _fallback(userMessage);
    }
  }

  static String _fallback(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('fir') || m.contains('police')) {
      return 'To file an FIR, visit your nearest police station. If refused, approach the SP or file online at your state police portal. Helpline: 100';
    }
    if (m.contains('consumer') || m.contains('refund')) {
      return 'Under Consumer Protection Act 2019, you can file a complaint at consumerhelpline.gov.in or call 1800-11-4000.';
    }
    if (m.contains('cyber') || m.contains('fraud') || m.contains('upi')) {
      return 'Report cyber crime at cybercrime.gov.in or call 1930 immediately. Preserve all evidence.';
    }
    if (m.contains('traffic') || m.contains('challan')) {
      return 'Pay e-challans at echallan.parivahan.gov.in. Contest wrong challans in court.';
    }
    if (m.contains('domestic') || m.contains('violence')) {
      return 'Under the Protection of Women from Domestic Violence Act 2005, approach a Protection Officer or call 181.';
    }
    return "I'm your AI Legal Assistant. Ask me about your rights, FIR procedures, consumer complaints, cyber crime, traffic violations, or any legal situation you're facing.";
  }
}
