import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:nepali_lens/modules/home/info_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  CameraController? _controller;
  File? _image;
  bool isFlashOn = false;
  final double _defaultZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    setState(() {
      _image = null;
    });
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      await _controller!.dispose();
      await _updateImage(File(image.path));

      if (_image != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (BuildContext context) =>
                    InfoScreenUnauthorized(photo: _image!),
          ),
        );
      }
      await _initializeCamera();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateImage(File imageFile) async {
    setState(() {
      _image = imageFile;
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first, // fallback if no back camera
      );

      _controller = CameraController(backCamera, ResolutionPreset.high);

      try {
        await _controller!.initialize();
        if (!mounted) return;
        await _controller!.setZoomLevel(_defaultZoomLevel);

        setState(() {});
      } on CameraException catch (e) {
        debugPrint("camera error $e");
      }
    }
  }

  void toggleFlash() async {
    if (_controller != null && _controller!.value.isInitialized) {
      if (!isFlashOn) {
        await _controller?.setFlashMode(FlashMode.torch);
      } else {
        await _controller?.setFlashMode(FlashMode.off);
      }
      setState(() {
        isFlashOn = !isFlashOn;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            Container(
              height: double.infinity,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 90),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Container(
                  height: 100,
                  child: CameraPreview(_controller!),
                ),
              ),
            )
          else
            Center(child: CircularProgressIndicator()),

          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, right: 20),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black.withOpacity(0.7),
                ),
                child: IconButton(
                  onPressed: () {
                    toggleFlash();
                  },
                  icon: Icon(
                    Icons.flash_on,
                    size: 25,
                    color: isFlashOn ? Colors.orange : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 125, left: 30),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white.withOpacity(0.7),
                ),
                child: IconButton(
                  onPressed: () async {
                    await _getImage(ImageSource.gallery);
                    if (_image != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (BuildContext context) =>
                                  InfoScreenUnauthorized(photo: _image!),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.photo_library, size: 35),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 110),
              child: GestureDetector(
                onTap: () async {
                  await _takePicture();
                },
                child: Container(
                  height: 90,
                  width: 90,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.translate,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Translate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
