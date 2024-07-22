import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techhype/list_english_words.dart';
import 'package:techhype/ui/voice_recognition_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Voice to Text App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VoiceRecognitionScreen(),

    );
  }
}
