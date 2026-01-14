import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../services/template_loader_service.dart';
import 'resume_preview_page.dart';

/// Resume Builder Page - Displays templates with HTML preview
class ResumeBuilderPage extends ConsumerStatefulWidget {
  const ResumeBuilderPage({super.key});

  @override
  ConsumerState<ResumeBuilderPage> createState() => _ResumeBuilderPageState();
}

class _ResumeBuilderPageState extends ConsumerState<ResumeBuilderPage> {
  List<TemplateMetadata> _templates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final templates = await TemplateLoaderService.instance.loadTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load templates: $e')));
      }
    }
  }

  // Predefined color palette with 20 diverse colors
  static final List<Color> _colorPalette = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFEC4899), // Pink
    const Color(0xFF1F2937), // Dark Gray
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF84CC16), // Lime
    const Color(0xFFF97316), // Orange
    const Color(0xFF14B8A6), // Teal
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFA855F7), // Violet
    const Color(0xFFE11D48), // Rose
    const Color(0xFF22C55E), // Emerald
    const Color(0xFF64748B), // Slate
    const Color(0xFFDC2626), // Red-600
    const Color(0xFF7C3AED), // Indigo-600
    const Color(0xFF059669), // Emerald-600
    const Color(0xFFD97706), // Amber-600
  ];

  // Get color scheme for each template - deterministic based on index
  // Same template position will always get the same color (fixed but appears random)
  Color _getTemplateColor(int listIndex) {
    // Use list index for deterministic color assignment
    // This ensures consistent colors based on template order
    final colorIndex = listIndex % _colorPalette.length;
    return _colorPalette[colorIndex];
  }

  // Get icon for each template
  IconData _getTemplateIcon(String templateId) {
    final icons = {
      'modern_professional': Icons.business_center,
      'creative_designer': Icons.palette,
      'executive': Icons.work,
      'tech_developer': Icons.code,
    };
    return icons[templateId] ?? Icons.description;
  }

  Widget _buildTemplateCard(TemplateMetadata template, int index) {
    final templateColor = _getTemplateColor(index);
    final templateIcon = _getTemplateIcon(template.id);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResumePreviewPage(template: template),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                templateColor.withOpacity(0.1),
                templateColor.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circle in top right
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: templateColor.withOpacity(0.1),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: templateColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(templateIcon, color: templateColor, size: 24),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Description - Expanded to fill available space
                    Expanded(
                      child: Text(
                        template.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                          fontSize: 13,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No templates available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a Template',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a resume template to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _templates.length,
                    itemBuilder: (context, index) {
                      return _buildTemplateCard(_templates[index], index);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}