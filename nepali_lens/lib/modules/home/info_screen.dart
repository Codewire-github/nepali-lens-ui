import 'dart:io';

import 'package:flutter/material.dart';

class InfoScreenUnauthorized extends StatefulWidget {
  final File photo;

  const InfoScreenUnauthorized({super.key, required this.photo});

  @override
  State<InfoScreenUnauthorized> createState() => _InfoScreenUnauthorizedState();
}

class _InfoScreenUnauthorizedState extends State<InfoScreenUnauthorized> {
  String nepali_text = '';
  String translation = '';
  File? image;

  @override
  Widget build(BuildContext context) {
    File selectedImage = widget.photo;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.4,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
              child: Image.file(selectedImage, fit: BoxFit.scaleDown),
            ),
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
