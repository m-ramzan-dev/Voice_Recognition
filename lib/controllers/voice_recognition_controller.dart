import 'dart:async';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:techhype/controllers/pdf_controller.dart';
import 'package:techhype/utils/utilis.dart';
import 'package:web_socket_channel/io.dart';

import '../ui/spell_check.dart';

class VoiceRecognitionController extends GetxController {
  final CustomTextEdittingController textController =
      CustomTextEdittingController();

  final serverUrl =
      'wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=16000&language=en-GB';
  late final RecorderStream _recorder = RecorderStream();

  late StreamSubscription _recorderStatus;
  late StreamSubscription _audioStream;

  late IOWebSocketChannel channel;
  bool isRecording = false;

  void listen() async {
    if (await Permission.microphone.isGranted) {
      if (isRecording) {
        stopRecord();
      } else {
        if (Get.find<PdfController>().existingFileName == null) {
          // user is creating new voice pdf
          updateTextField('');
        }
        startRecord();
      }
      isRecording = !isRecording;
      update();
    } else {
      requestMicPermission();
    }
  }

  void updateTextField(String? text) {
    if (text != null) {
      textController.text = "${textController.text} ${text.trim()}";
      update();
    }
  }

  void clearTextField() {
    textController.clear();
    update();
  }

  void startRecord() async {
    await initStream();
    await _recorder.start();
  }

  void stopRecord() async {
    await _recorder.stop();
  }

  Future<void> requestMicPermission() async {
    await Permission.microphone.request();
    if (await Permission.microphone.isPermanentlyDenied) {
      showToast("Microphone permission is permanently denied.");
      await openAppSettings();
    }
  }

  Future<void> initStream() async {
    channel = IOWebSocketChannel.connect(Uri.parse(serverUrl), headers: {
      'Authorization':
          'Token ${const String.fromEnvironment('DEEPGRAM_API_KEY')}'
    });

    channel.stream.listen((event) async {
      final parsedJson = jsonDecode(event);
      debugPrint("parsedJson=>$parsedJson");
      updateTextField(
          parsedJson['channel']?['alternatives']?[0]?['transcript'] ?? '');
    });

    _audioStream = _recorder.audioStream.listen((data) {
      channel.sink.add(data);
    });

    _recorderStatus = _recorder.status.listen((status) {
      debugPrint("listening status=>$status");
    });

    await Future.wait([
      _recorder.initialize(),
    ]);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    _recorderStatus.cancel();
    _audioStream.cancel();
    channel.sink.close();
    super.dispose();
  }
}
