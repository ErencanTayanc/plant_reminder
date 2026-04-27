import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _apiKey = 'AIzaSyAwzjHey_YT8wY1NvkKGoRxKfQ1teJXvYg'; // <-- replace
  static const _model = 'gemini-2.5-flash';
  static const _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const _prompt = '''
Respond in full sentences. Do not cut words or sentences.

Write a complete answer with:
- Healt Status
- Visible Issues
- Advice (2-3 Bullet Points)
- Watering Tip

Minimum 4 sentences.
''';

  static Future<String> analyzePlant(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {'mime_type': mimeType, 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {'temperature': 0.5, 'maxOutputTokens': 2048},
    });

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      final err = jsonDecode(response.body);
      print(err);
      throw Exception(err['error']['message'] ?? 'Gemini API error');
    }
  }
}
