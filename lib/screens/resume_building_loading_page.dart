import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../core/theme/app_theme.dart';
import '../services/template_loader_service.dart';
import '../services/html_to_pdf_service.dart';
import '../services/template_replacement_service.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

/// Resume Building Loading Page - Converts HTML to PDF
class ResumeBuildingLoadingPage extends ConsumerStatefulWidget {
  final TemplateMetadata template;

  const ResumeBuildingLoadingPage({
    super.key,
    required this.template,
  });

  @override
  ConsumerState<ResumeBuildingLoadingPage> createState() =>
      _ResumeBuildingLoadingPageState();
}

class _ResumeBuildingLoadingPageState
    extends ConsumerState<ResumeBuildingLoadingPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _convertToPdf();
  }

  Future<void> _convertToPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      // Get user data and replace template placeholders
      final user = ref.read(authNotifierProvider).user;
      final htmlContent = user != null
          ? TemplateReplacementService.instance.replaceTemplate(
              widget.template.htmlContent,
              user,
            )
          : widget.template.htmlContent;

      // Generate file name with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = '${widget.template.id}_$timestamp';

      // Convert HTML to PDF
      final pdfFile = await HtmlToPdfService.instance.convertHtmlToPdf(
        htmlContent,
        fileName,
      );

      if (pdfFile != null && await pdfFile.exists()) {
        setState(() {
          _pdfFile = pdfFile;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to create PDF file');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfFile == null) return;

    try {
      await HtmlToPdfService.instance.sharePdf(_pdfFile!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _savePdf() async {
    if (_pdfFile == null) return;

    try {
      // Get the directory where user wants to save
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory == null) {
        // User cancelled the directory picker
        return;
      }

      // Generate file name with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'Resume_${widget.template.id}_$timestamp.pdf';
      final destinationPath = '$selectedDirectory/$fileName';

      // Copy the PDF file to the selected directory
      final destinationFile = await _pdfFile!.copy(destinationPath);

      if (await destinationFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resume saved successfully to:\n$destinationPath'),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Failed to save file');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Building Resume'),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _isLoading
            ? _buildLoadingState()
            : _hasError
                ? _buildErrorState()
                : _buildSuccessState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Converting to PDF...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we generate your resume',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Conversion Failed',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'An error occurred while generating the PDF',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go Back'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _convertToPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Resume Created!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your resume has been successfully converted to PDF',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _savePdf,
                  icon: const Icon(Icons.save),
                  label: const Text('Save PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _sharePdf,
                  icon: const Icon(Icons.share),
                  label: const Text('Share PDF'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}