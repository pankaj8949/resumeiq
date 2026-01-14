import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'dart:convert';

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
        'ats_friendly.html',
        'classic_traditional.html',
        'bold_modern.html',
        'academic_scholar.html',
        'navy_blue.html',
        'forest_green.html',
        'charcoal_gray.html',
        'navy_sidebar.html',
        'icon_timeline.html',
        'azure_timeline.html',
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
      var htmlContent = await rootBundle.loadString(
        'lib/templates/$fileName',
      );

      // Inline sidebar image for Forest Green (data-URI) so it works in WebView data: preview and PDF conversion.
      htmlContent = await _inlineForestGreenSidebarImage(htmlContent);

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

  Future<String> _inlineForestGreenSidebarImage(String html) async {
    const token = '__FOREST_GREEN_BG__';
    if (!html.contains(token)) return html;

    try {
      // Preferred: local asset image (user-provided)
      final bytes = await rootBundle.load('assets/images/forest_green.jpg');
      final b64 = base64Encode(bytes.buffer.asUint8List());
      final dataUrl = 'data:image/jpeg;base64,$b64';
      return html.replaceAll(token, dataUrl);
    } catch (_) {
      // Fallback: free Unsplash jungle/plant image feed
      // Source: user requested Unsplash jungle plants search page:
      // https://unsplash.com/s/photos/jungle-plants
      const fallbackUrl =
          'https://source.unsplash.com/featured/900x1500?jungle,plants';
      return html.replaceAll(token, fallbackUrl);
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

  /// Load templates filtered by category
  /// If categoryId is 'all' or empty, returns all templates
  Future<List<TemplateMetadata>> loadTemplatesByCategory(String categoryId) async {
    final allTemplates = await loadTemplates();
    
    // If category is 'all' or empty, return all templates
    if (categoryId.isEmpty || categoryId.toLowerCase() == 'all') {
      return allTemplates;
    }

    // Category mapping based on template IDs
    final categoryMapping = {
      'professional': ['modern_professional', 'executive', 'ats_friendly', 'classic_traditional', 'navy_blue', 'charcoal_gray', 'navy_sidebar', 'icon_timeline', 'azure_timeline'],
      'creative': ['creative_designer', 'minimal_elegant', 'bold_modern'],
      'tech': ['tech_developer', 'ats_friendly'],
      'ats': ['ats_friendly', 'classic_traditional', 'navy_blue', 'navy_sidebar'],
      'academic': ['academic_scholar'],
      'healthcare': ['forest_green'],
    };

    final categoryTemplates = categoryMapping[categoryId.toLowerCase()] ?? [];
    
    if (categoryTemplates.isEmpty) {
      // If category not found, return all templates
      return allTemplates;
    }

    return allTemplates.where((template) {
      return categoryTemplates.contains(template.id);
    }).toList();
  }
}
