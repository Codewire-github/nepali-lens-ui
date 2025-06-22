import 'dart:convert';
import 'package:http/http.dart' as http;

// Replace with your FastAPI server URL
const String baseUrl = 'http://your_fastapi_server_ip_or_domain:8000';

Future<String> translateNepaliToEnglish(String nepaliText) async {
  final url = Uri.parse('$baseUrl/translate');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'text': nepaliText}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['translated_text'] as String;
  } else {
    throw Exception('Failed to translate text');
  }
}

Future<List<String>> translateBatch(List<String> nepaliTexts) async {
  final url = Uri.parse('$baseUrl/translate_batch');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'texts': nepaliTexts}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(data['results']);
  } else {
    throw Exception('Failed to translate batch');
  }
}
