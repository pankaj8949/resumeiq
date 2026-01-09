import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'resume_builder_page.dart';

class ResumeTemplatesPage extends StatelessWidget {
  const ResumeTemplatesPage({super.key});

  static const List<ResumeTemplate> templates = [
    ResumeTemplate(
      id: 'modern',
      name: 'Modern',
      description: 'Clean and professional design',
      color: AppTheme.primaryColor,
      icon: Icons.style,
    ),
    ResumeTemplate(
      id: 'classic',
      name: 'Classic',
      description: 'Traditional and formal layout',
      color: AppTheme.textPrimary,
      icon: Icons.description,
    ),
    ResumeTemplate(
      id: 'creative',
      name: 'Creative',
      description: 'Bold and eye-catching design',
      color: AppTheme.secondaryColor,
      icon: Icons.palette,
    ),
    ResumeTemplate(
      id: 'minimal',
      name: 'Minimal',
      description: 'Simple and elegant layout',
      color: AppTheme.textSecondary,
      icon: Icons.minimize,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Template'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Resume Template',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a template that best fits your style and industry',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateCard(
                  template: template,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ResumeBuilderPage(
                          templateId: template.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ResumeTemplate {
  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onTap,
  });

  final ResumeTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: template.color.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    template.icon,
                    size: 60,
                    color: template.color,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
