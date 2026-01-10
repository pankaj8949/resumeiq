import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../domain/entities/resume_entity.dart';
import '../templates/html_template_service.dart';

/// PDF Generator service for resume templates using HTML to PDF
class ResumePdfGenerator {
  ResumePdfGenerator._();

  /// Generate PDF from resume HTML template
  static Future<void> generatePdf({
    required ResumeEntity resume,
    required BuildContext context,
    required String templateId,
  }) async {
    try {
      // Generate HTML content from template
      final htmlContent = HtmlTemplateService.generateHtml(
        resume: resume,
        templateId: templateId,
      );

      // Convert HTML to PDF using printing package
      final pdfBytes = await Printing.convertHtml(
        format: PdfPageFormat.a4,
        html: htmlContent,
      );

      if (!context.mounted) return;

      // Show share/print dialog with the generated PDF bytes
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      if (!context.mounted) return;

      debugPrint('PDF Generation Error: $e');
      debugPrint('Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Generate PDF bytes (for saving to file)
  static Future<Uint8List?> generatePdfBytes({
    required ResumeEntity resume,
    required String templateId,
  }) async {
    try {
      // Generate HTML content from template
      final htmlContent = HtmlTemplateService.generateHtml(
        resume: resume,
        templateId: templateId,
      );

      // Convert HTML to PDF using printing package
      return await Printing.convertHtml(
        format: PdfPageFormat.a4,
        html: htmlContent,
      );
    } catch (e, stackTrace) {
      debugPrint('PDF Generation Error (bytes): $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
