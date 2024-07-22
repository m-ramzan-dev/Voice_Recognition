import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:techhype/controllers/pdf_controller.dart';
import 'package:techhype/controllers/voice_recognition_controller.dart';
import 'package:techhype/ui/pdf_viewer_screen.dart';

class PdfFilesView extends StatefulWidget {
  const PdfFilesView({super.key});

  @override
  State<PdfFilesView> createState() => _PdfFilesViewState();
}

class _PdfFilesViewState extends State<PdfFilesView> {
  final pdfController = Get.find<PdfController>();
  final voiceController = Get.find<VoiceRecognitionController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pdfController.loadPdfFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PdfController>(
      builder: (ctrl) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ctrl.pdfFiles.isNotEmpty
                ? "Your previous speech files"
                : "Your speech files will appear here",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: ctrl.pdfFiles.length,
              itemBuilder: (context, index) {
                final pdfFile = ctrl.pdfFiles[index]['file'];
                final fileName = ctrl.pdfFiles[index]['fileName'];

                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Image.asset(
                        "assets/pdf.png",
                        width: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(fileName),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () {
                                Get.to(() => PdfViewerScreen(file: pdfFile));
                              },
                              child: const Text("View")),
                          TextButton(
                              onPressed: () => ctrl.handleEditPdf(fileName),
                              child: const Text("Edit")),
                          TextButton(
                              onPressed: () async {
                                await Share.shareFiles([pdfFile.path],
                                    text: 'Here is your PDF file');
                              },
                              child: const Text("Share")),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
