import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

/// PDF Generator service for resume templates
class ResumePdfGenerator {
  ResumePdfGenerator._();

  /// Generate PDF from resume using specified template
  static Future<void> generatePdf({
    required ExportDelegate exportDelegate,
    required BuildContext context,
    required String exportFrameId,
  }) async {
    try {
      // Wait a bit for widget rendering
      await Future.delayed(const Duration(milliseconds: 500));

      // Export to PDF document using existing ExportFrame
      final pdf = await exportDelegate.exportToPdfDocument(exportFrameId);

      if (!context.mounted) return;

      // Show share/print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await pdf.save(),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Generate PDF bytes (for saving to file)
  static Future<Uint8List?> generatePdfBytes({
    required ExportDelegate exportDelegate,
    required String exportFrameId,
  }) async {
    try {
      // Wait a bit for widget rendering
      await Future.delayed(const Duration(milliseconds: 500));

      // Export to PDF document using existing ExportFrame
      final pdf = await exportDelegate.exportToPdfDocument(exportFrameId);

      // Convert to bytes
      return await pdf.save();
    } catch (e) {
      return null;
    }
  }
}
