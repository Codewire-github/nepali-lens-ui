import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For mime type

const String baseUrl = 'http://your_fastapi_server_ip_or_domain:8000';

Future<List<String>> performOCR(File imageFile) async {
  final url = Uri.parse('$baseUrl/ocr/');

  var request = http.MultipartRequest('POST', url);
  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'), // or 'png' depending on image
    ),
  );

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(data['text']);
  } else {
    throw Exception('OCR failed: ${response.body}');
  }
}
