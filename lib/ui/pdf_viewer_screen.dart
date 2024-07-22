import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final File file;

  const PdfViewerScreen({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:const Text("View Document"),
          centerTitle: true,
        ),
        body: SfPdfViewer.file(file));
  }
}
