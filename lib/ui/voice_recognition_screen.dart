import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techhype/controllers/pdf_controller.dart';
import 'package:techhype/controllers/voice_recognition_controller.dart';
import 'package:techhype/ui/pdf_files_view.dart';
import 'package:techhype/ui/spell_check.dart';
import 'package:techhype/ui/start_stop_button.dart';


class VoiceRecognitionScreen extends StatelessWidget {
  VoiceRecognitionScreen({super.key});

  final controller = Get.put(VoiceRecognitionController());
  final pdfController = Get.put(PdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recognition'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed:pdfController.handleSavePdf,
            icon: const Icon(
              Icons.save,
              color: Colors.black54,
            ),
          )
        ],
      ),
      body: GetBuilder<VoiceRecognitionController>(
        builder: (ctrl) => SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              if (controller.textController.text.isNotEmpty)
                SpellCheck(controller: controller.textController),
              const SizedBox(height: 20),
              Center(
                child: StartStopButton(
                    onPress: ctrl.listen, isRecording: ctrl.isRecording),
              ),
              const SizedBox(
                height: 12,
              ),
              const PdfFilesView(),
            ],
          ),
        ),
      ),
    );
  }
}
