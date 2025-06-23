import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TextToText extends StatefulWidget {
  const TextToText({super.key});

  @override
  State<TextToText> createState() => _TextToTextState();
}

class _TextToTextState extends State<TextToText> {
  final TextEditingController _controller = TextEditingController();
  String translatedText = '';
  bool isLoading = false;

  Future<String> translateNepaliToEnglish(String nepaliText) async {
    final url = Uri.parse('http://10.0.2.2:8000/translate');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': nepaliText}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translated_text'] ?? '';
    } else {
      throw Exception('Translation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Enter Nepali Text:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: "e.g. मेरो नाम निकिता हो।",
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final translated = await translateNepaliToEnglish(
                        _controller.text,
                      );
                      setState(() {
                        translatedText = translated;
                        isLoading = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'Translate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (translatedText.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Translated Text:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(translatedText, style: TextStyle(fontSize: 20)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
