import 'dart:io';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:techhype/controllers/voice_recognition_controller.dart';

import '../utils/file_utils.dart';
import '../utils/utilis.dart';

class PdfController extends GetxController {
  List<Map<String, dynamic>> pdfFiles = <Map<String, dynamic>>[];
  late FileUtils fileUtils;
  String? existingFileName;
  late final VoiceRecognitionController voiceController;

  @override
  void onInit() {
    super.onInit();
    fileUtils = FileUtils();
    voiceController = Get.find<VoiceRecognitionController>();
  }

  void loadPdfFiles() async {
    pdfFiles = await fileUtils.getAllSavedPdfs();
    update();
    // for (var fileMap in pdfFiles) {
    //   String fileName = fileMap['fileName'];
    //   File file = fileMap['file'];
    //
    //   print('File Name: $fileName');
    //   print('File Path: ${file.path}');
    // }
  }

  Future<void> createAndSavePdf(String text) async {
    if (await Permission.storage.isGranted) {
      await fileUtils.createAndSavePdf(text);
      voiceController.clearTextField();
      loadPdfFiles();
    } else {
      await requestStoragePermission();
    }
  }

  Future<void> editPdf(String fileName, String newText) async {
    await fileUtils.editExistingPdf(fileName, newText);
    setExistingFileNameForEditing(null);
    voiceController.clearTextField();
  }

  Future<String> extractTextFromPdf(String fileName) async {
    return await fileUtils.extractTextFromPdf(fileName);
  }

  Future<void> requestStoragePermission() async {
    await Permission.storage.request();
    if (await Permission.storage.isPermanentlyDenied) {
      showToast("Storage permission is permanently denied.");
      await openAppSettings();
    }
  }

  void setExistingFileNameForEditing(String? name) {
    existingFileName = name;
    update();
  }

  void handleSavePdf() {
    if (voiceController.isRecording) {
      showToast("Recording is in progress");
    } else {
      if (voiceController.textController.text.isNotEmpty) {
        if (existingFileName != null) {
          editPdf(existingFileName ?? '',
              voiceController.textController.text.trim());
        } else {
          createAndSavePdf(voiceController.textController.text.trim());
        }
      } else {
        showToast("Nothing to save");
      }
    }
  }

  void handleEditPdf(String fileName) async {
    final String text = await extractTextFromPdf(fileName);
    voiceController.clearTextField();
    voiceController.updateTextField(text);
    setExistingFileNameForEditing(fileName);
  }
}
