import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../providers/resume_provider.dart';
import '../../domain/entities/resume_entity.dart';
import '../templates/template_registry.dart';
import '../pdf/resume_pdf_generator.dart';
import 'resume_builder_page.dart';

class ResumePreviewPage extends ConsumerStatefulWidget {
  const ResumePreviewPage({super.key, this.resumeId});

  final String? resumeId;

  @override
  ConsumerState<ResumePreviewPage> createState() => _ResumePreviewPageState();
}

class _ResumePreviewPageState extends ConsumerState<ResumePreviewPage> {
  bool _isGeneratingPdf = false;
  String _selectedTemplateId = 'modern'; // Default template
  final ExportDelegate _exportDelegate = ExportDelegate(
    options: ExportOptions(
      pageFormatOptions: PageFormatOptions.a4(),
    ),
    // Note: We don't provide ttfFonts here to use default fonts for PDF
    // This avoids the "unsupported font" error with Google Fonts
  );
  static const String _exportFrameId = 'resume_export_frame';

  @override
  void initState() {
    super.initState();
    // Load resume data if resumeId is provided
    if (widget.resumeId != null && widget.resumeId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(resumeNotifierProvider.notifier).loadResume(widget.resumeId!);
      });
    }
  }

  Future<void> _exportPdf(ResumeEntity resume) async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      await ResumePdfGenerator.generatePdf(
        exportDelegate: _exportDelegate,
        context: context,
        exportFrameId: _exportFrameId,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  void _showTemplateSelector(ResumeEntity resume) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TemplateSelectorSheet(
        currentTemplateId: _selectedTemplateId,
        onTemplateSelected: (templateId) {
          setState(() {
            _selectedTemplateId = templateId;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeNotifierProvider);
    
    // If resumeId provided, load and show that resume
    ResumeEntity? resume;
    if (widget.resumeId != null && widget.resumeId!.isNotEmpty) {
      // Check if we have the resume loaded
      resume = resumeState.currentResume;
      
      // Verify it's the correct resume
      if (resume != null && resume.id != widget.resumeId) {
        resume = null; // Wrong resume, need to load the correct one
      }
      
      // If not loaded yet and not currently loading, load it
      if (resume == null && !resumeState.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(resumeNotifierProvider.notifier).loadResume(widget.resumeId!);
        });
      }
      
      if (resume == null && resumeState.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Resume Preview')),
          body: const LoadingWidget(),
        );
      }
    } else {
      // Otherwise show current resume from state
      resume = resumeState.currentResume;
    }

    if (resume == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resume Preview'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: EmptyStateWidget(
          icon: Icons.description,
          title: 'No Resume Data',
          message: 'Resume data is not available. Please go back and try again.',
          action: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ),
      );
    }

    // At this point, resume is guaranteed to be non-null
    final displayResume = resume;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayResume.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.style),
            tooltip: 'Select Template',
            onPressed: () => _showTemplateSelector(displayResume),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Resume',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ResumeBuilderPage(resumeId: displayResume.id),
                ),
              );
            },
          ),
          IconButton(
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: _isGeneratingPdf ? null : () => _exportPdf(displayResume),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ExportFrame(
          frameId: _exportFrameId,
          exportDelegate: _exportDelegate,
          child: Builder(
            builder: (context) {
              // Override theme to use system fonts for PDF export
              // This avoids "unsupported font" error with Google Fonts
              return Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    displayLarge: Theme.of(context).textTheme.displayLarge?.copyWith(fontFamily: null),
                    displayMedium: Theme.of(context).textTheme.displayMedium?.copyWith(fontFamily: null),
                    displaySmall: Theme.of(context).textTheme.displaySmall?.copyWith(fontFamily: null),
                    headlineLarge: Theme.of(context).textTheme.headlineLarge?.copyWith(fontFamily: null),
                    headlineMedium: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: null),
                    headlineSmall: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: null),
                    titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: null),
                    titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: null),
                    titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(fontFamily: null),
                    bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: null),
                    bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: null),
                    bodySmall: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: null),
                    labelLarge: Theme.of(context).textTheme.labelLarge?.copyWith(fontFamily: null),
                    labelMedium: Theme.of(context).textTheme.labelMedium?.copyWith(fontFamily: null),
                    labelSmall: Theme.of(context).textTheme.labelSmall?.copyWith(fontFamily: null),
                  ),
                ),
                child: _buildTemplatePreview(displayResume),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTemplatePreview(ResumeEntity resume) {
    final templateInfo = TemplateRegistry.getTemplateById(_selectedTemplateId) ??
        TemplateRegistry.getDefaultTemplate();
    return templateInfo.factory(resume);
  }

}

/// Template selector bottom sheet
class _TemplateSelectorSheet extends StatelessWidget {
  const _TemplateSelectorSheet({
    required this.currentTemplateId,
    required this.onTemplateSelected,
  });

  final String currentTemplateId;
  final ValueChanged<String> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    final categories = TemplateRegistry.getCategories();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Template',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Template list grouped by category
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, categoryIndex) {
                    final category = categories[categoryIndex];
                    final templates = TemplateRegistry.getTemplatesByCategory(category);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            final isSelected = template.id == currentTemplateId;

                            return InkWell(
                              onTap: () => onTemplateSelected(template.id),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? AppTheme.primaryColor.withOpacity(0.05)
                                      : Colors.white,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isSelected ? Icons.check_circle : Icons.style,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey.shade600,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      template.name,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : Colors.black87,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      template.description,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (categoryIndex < categories.length - 1)
                          const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
