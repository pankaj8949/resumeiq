import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:html_to_pdf/html_to_pdf.dart';

/// Service for converting HTML to PDF
class HtmlToPdfService {
  HtmlToPdfService._();
  static final HtmlToPdfService instance = HtmlToPdfService._();

  /// Convert HTML content to PDF file
  Future<File?> convertHtmlToPdf(String htmlContent, String fileName) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final targetPath = directory.path;

      // Convert HTML to PDF using html_to_pdf package
      final generatedPdfFile = await HtmlToPdf.convertFromHtmlContent(
        htmlContent: htmlContent,
        printPdfConfiguration: PrintPdfConfiguration(
          targetDirectory: targetPath,
          targetName: fileName,
          printSize: PrintSize.A4,
          printOrientation: PrintOrientation.Portrait,
        ),
      );

      // The generated file path will be: targetPath/fileName.pdf
      final filePath = '$targetPath/$fileName.pdf';
      final file = File(filePath);

      // Verify file exists
      if (await file.exists()) {
        return file;
      } else {
        // If file doesn't exist at expected path, return the generated file
        return generatedPdfFile;
      }
    } catch (e) {
      print('Error converting HTML to PDF: $e');
      return null;
    }
  }

  /// Share PDF file
  Future<void> sharePdf(File pdfFile) async {
    try {
      await Printing.sharePdf(
        bytes: await pdfFile.readAsBytes(),
        filename: pdfFile.path.split('/').last,
      );
    } catch (e) {
      print('Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Open PDF file
  Future<void> openPdf(File pdfFile) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async {
          return await pdfFile.readAsBytes();
        },
      );
    } catch (e) {
      print('Error opening PDF: $e');
      rethrow;
    }
  }
}
