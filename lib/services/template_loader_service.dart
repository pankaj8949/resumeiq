import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;

/// Template metadata model
class TemplateMetadata {
  final String id;
  final String title;
  final String description;
  final String filePath;
  final String htmlContent;

  TemplateMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.filePath,
    required this.htmlContent,
  });
}

/// Service for loading and parsing resume templates
class TemplateLoaderService {
  TemplateLoaderService._();
  static final TemplateLoaderService instance = TemplateLoaderService._();

  /// Load all templates from the templates directory
  Future<List<TemplateMetadata>> loadTemplates() async {
    final templates = <TemplateMetadata>[];

    try {
      // List of template files
      final templateFiles = [
        'modern_professional.html',
        'creative_designer.html',
        'executive.html',
        'tech_developer.html',
        'minimal_elegant.html',
      ];

      for (final fileName in templateFiles) {
        try {
          final template = await loadTemplate(fileName);
          if (template != null) {
            templates.add(template);
          }
        } catch (e) {
          // Skip templates that fail to load
          print('Failed to load template $fileName: $e');
        }
      }
    } catch (e) {
      print('Error loading templates: $e');
    }

    return templates;
  }

  /// Load a single template by filename
  Future<TemplateMetadata?> loadTemplate(String fileName) async {
    try {
      // Load HTML file from assets
      final htmlContent = await rootBundle.loadString(
        'lib/templates/$fileName',
      );

      // Parse HTML to extract metadata
      final document = html_parser.parse(htmlContent);

      // Extract title from meta tag
      final titleMeta = document.querySelector('meta[name="template-title"]');
      final title =
          titleMeta?.attributes['content'] ??
          fileName
              .replaceAll('.html', '')
              .replaceAll('_', ' ')
              .split(' ')
              .map(
                (word) => word.isEmpty
                    ? ''
                    : word[0].toUpperCase() + word.substring(1),
              )
              .join(' ');

      // Extract description from meta tag
      final descMeta = document.querySelector(
        'meta[name="template-description"]',
      );
      final description =
          descMeta?.attributes['content'] ?? 'Professional resume template';

      // Generate ID from filename
      final id = fileName.replaceAll('.html', '');

      return TemplateMetadata(
        id: id,
        title: title,
        description: description,
        filePath: 'lib/templates/$fileName',
        htmlContent: htmlContent,
      );
    } catch (e) {
      print('Error loading template $fileName: $e');
      return null;
    }
  }

  /// Get template HTML content by ID
  Future<String?> getTemplateContent(String templateId) async {
    try {
      final template = await loadTemplate('$templateId.html');
      return template?.htmlContent;
    } catch (e) {
      print('Error getting template content for $templateId: $e');
      return null;
    }
  }
}
