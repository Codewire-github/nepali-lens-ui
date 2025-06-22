import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class InfoScreenUnauthorized extends StatefulWidget {
  final File photo;

  const InfoScreenUnauthorized({super.key, required this.photo});

  @override
  State<InfoScreenUnauthorized> createState() => _InfoScreenUnauthorizedState();
}

class _InfoScreenUnauthorizedState extends State<InfoScreenUnauthorized> {
  String nepaliText = '';
  String translation = '';
  bool isLoading = true;
  String loadingMessage = 'Extracting text from image...';

  @override
  void initState() {
    super.initState();
    processImage(widget.photo);
  }

  Future<void> processImage(File imageFile) async {
    try {
      // Step 1: OCR
      setState(() {
        loadingMessage = 'Extracting text from image...';
        isLoading = true;
      });

      final ocrText = await performOCR(imageFile);

      setState(() {
        nepaliText = ocrText;
      });

      // Step 2: Translation
      setState(() {
        loadingMessage = 'Translating into English language...';
      });

      final translated = await translateNepaliToEnglish(ocrText);

      setState(() {
        translation = translated;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        nepaliText = 'Error: ${e.toString()}';
      });
    }
  }

  Future<String> performOCR(File imageFile) async {
    final url = Uri.parse('http://10.0.2.2:8080/ocr/');

    final request = http.MultipartRequest('POST', url);
    final mimeType =
        lookupMimeType(imageFile.path) ?? 'application/octet-stream';
    final typeSplit = mimeType.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(typeSplit[0], typeSplit[1]),
      ),
    );

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody.body);
      return (data['text'] as List).join(' ');
    } else {
      throw Exception('OCR failed: ${responseBody.body}');
    }
  }

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
    File selectedImage = widget.photo;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.sizeOf(context).height * 0.4,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                  child: Image.file(selectedImage, fit: BoxFit.scaleDown),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child:
                      isLoading
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20),
                              Text(loadingMessage),
                            ],
                          )
                          : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Extracted Nepali Text:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(nepaliText),
                                const SizedBox(height: 20),
                                const Text(
                                  "Translated English Text:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(translation),
                              ],
                            ),
                          ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 50),
              child: Container(
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
            ),
          ),
        ],
      ),
    );
  }
}
