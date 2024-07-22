import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:techhype/utils/utilis.dart';

class FileUtils {
  static final FileUtils _instance = FileUtils._internal();

  factory FileUtils() {
    return _instance;
  }

  FileUtils._internal() {
    init();
  }

  Directory? dir;

  Future<void> init() async {
    dir = await (Platform.isIOS
        ? getApplicationSupportDirectory()
        : getApplicationDocumentsDirectory());
  }


  Future<void> createAndSavePdf(String text) async {
    try {
      final PdfDocument document = PdfDocument();
      String fileName = DateTime.now().toString();
      final PdfPage page = document.pages.add();
      final PdfTextElement textElement = PdfTextElement(
        text: text,
        font: PdfStandardFont(PdfFontFamily.helvetica, 18),
      );
      final PdfLayoutResult layoutResult = textElement.draw(
        page: page,
        bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, page
        .getClientSize().height),
      )!;

      final String filePath = path.join(dir!.path, '$fileName.pdf');

      final List<int> bytes = document.saveSync();
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      document.dispose();

      debugPrint('PDF saved at $filePath');
      showToast('PDF saved successfully.');
    } catch (e) {
      debugPrint('Error creating or saving PDF: $e');
      showToast('Unable to save PDF.');
    }
  }

  Future<List<Map<String, dynamic>>> getAllSavedPdfs() async {
    if (dir == null) {
      await init();
    }
    final List<FileSystemEntity> files = dir!.listSync();

    final List<Map<String, dynamic>> pdfFilesWithNames = files
        .where((file) => path.extension(file.path) == '.pdf')
        .map((file) => {
              'fileName': path.basename(file.path),
              'file': File(file.path),
            })
        .toList();

    return pdfFilesWithNames;
  }

  Future<void> editExistingPdf(String fileName, String newText,
      {int pageIndex = 0}) async {
    final String filePath = path.join(dir!.path, fileName);

    final File file = File(filePath);
    if (await file.exists()) {
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      if (pageIndex < document.pages.count) {
        final PdfPage existingPage = document.pages[pageIndex];
        final Size pageSize = existingPage.size;

        document.pages.removeAt(pageIndex);

        final PdfPage newPage = document.pages.insert(pageIndex, pageSize);

        newPage.graphics.drawString(
          newText,
          PdfStandardFont(PdfFontFamily.helvetica, 18),
          bounds: Rect.fromLTWH(0, 0, newPage.getClientSize().width, newPage.getClientSize().height),
        );

        await file.writeAsBytes(await document.save(), flush: true);

        document.dispose();

        debugPrint('PDF edited and saved at $filePath');
        showToast('PDF edited and saved successfully.');
      } else {
        debugPrint('Invalid page index');
        showToast('Unable to edit PDF.');
      }
    } else {
      debugPrint('PDF file not found');
      showToast('PDF file not found.');
    }
  }

  Future<String> extractTextFromPdf(String fileName) async {
    final String filePath = path.join(dir!.path, fileName);

    final File file = File(filePath);
    if (await file.exists()) {
      final List<int> bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      String extractedText = '';
      PdfTextExtractor textExtractor = PdfTextExtractor(document);
      for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
        String pageText = textExtractor.extractText(
            startPageIndex: pageIndex, endPageIndex: pageIndex);
        extractedText += pageText;
      }

      String trimmedText = extractedText.trim();

      document.dispose();

      return trimmedText;
    } else {
      print('PDF file not found');
      return '';
    }
  }
}
