import 'package:flutter/material.dart';
import 'package:nepali_lens/modules/home/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nepali Lens',
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
