import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import '../core/theme/app_theme.dart';
import '../services/template_loader_service.dart';
import '../services/template_replacement_service.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_page.dart';
import 'resume_building_loading_page.dart';

/// Resume Preview Page - Shows HTML template preview with options to edit profile
class ResumePreviewPage extends ConsumerStatefulWidget {
  final TemplateMetadata template;

  const ResumePreviewPage({super.key, required this.template});

  @override
  ConsumerState<ResumePreviewPage> createState() => _ResumePreviewPageState();
}

class _ResumePreviewPageState extends ConsumerState<ResumePreviewPage> {
  final bool _isLoading = false;
  late WebViewControllerPlus _webViewController;
  LocalhostServer? _localhostServer;
  bool _isServerStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      _localhostServer = LocalhostServer();
      await _localhostServer!.start(port: 0);

      _webViewController = WebViewControllerPlus()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000));

      if (mounted) {
        setState(() {
          _isServerStarted = true;
        });
        _loadHtmlContent();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isServerStarted = true;
        });
        _loadHtmlContent();
      }
    }
  }

  void _loadHtmlContent() {
    final user = ref.read(authNotifierProvider).user;
    final replacedHtml = user != null
        ? TemplateReplacementService.instance.replaceTemplate(
            widget.template.htmlContent,
            user,
          )
        : widget.template.htmlContent;

    // Load HTML string using data URI
    _webViewController.loadRequest(
      Uri.dataFromString(replacedHtml, mimeType: 'text/html', encoding: utf8),
    );
  }

  @override
  void dispose() {
    _localhostServer?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final missingFields = user != null
        ? TemplateReplacementService.instance.getMissingFields(user)
        : <String>[];

    // Reload HTML content when user or template changes
    if (_isServerStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHtmlContent();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.title),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Missing Fields Warning Banner
          if (missingFields.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Some information is missing',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Missing: ${missingFields.join(", ")}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.orange.shade800,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
          // Profile Update Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update your profile details',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Make sure your resume information is up to date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // HTML Preview
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _isServerStarted
                      ? WebViewWidget(controller: _webViewController)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              final user = ref.read(authNotifierProvider).user;
                              if (user != null) {
                                final replacedHtml = TemplateReplacementService
                                    .instance
                                    .replaceTemplate(
                                      widget.template.htmlContent,
                                      user,
                                    );
                                final updatedTemplate = TemplateMetadata(
                                  id: widget.template.id,
                                  title: widget.template.title,
                                  description: widget.template.description,
                                  filePath: widget.template.filePath,
                                  htmlContent: replacedHtml,
                                );
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => ResumeBuildingLoadingPage(
                                      template: updatedTemplate,
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Use This Template',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
