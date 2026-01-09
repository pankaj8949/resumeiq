/// Service for generating PDF documents from Flutter widgets using flutter_to_pdf
/// Note: This service is kept for compatibility, but the actual export is handled
/// directly in the ResumePreviewPage using ExportFrame and ExportDelegate
class PdfService {
  /// Get file name from resume title
  static String getFileName(String title) {
    // Remove special characters and replace spaces with underscores
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'_+'), '_');
  }
}
