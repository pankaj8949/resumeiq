import 'package:flutter/material.dart';
import '../../domain/entities/resume_entity.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;

/// Reusable projects section component
class ProjectsSection extends StatelessWidget {
  const ProjectsSection({
    super.key,
    required this.projects,
    this.itemSpacing = 16.0,
    this.showDateRange = true,
    this.showTechnologies = true,
  });

  final List<ProjectEntity> projects;
  final double itemSpacing;
  final bool showDateRange;
  final bool showTechnologies;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: projects
          .map((project) => _ProjectItem(
                project: project,
                itemSpacing: itemSpacing,
                showDateRange: showDateRange,
                showTechnologies: showTechnologies,
              ))
          .toList(),
    );
  }
}

class _ProjectItem extends StatelessWidget {
  const _ProjectItem({
    required this.project,
    required this.itemSpacing,
    required this.showDateRange,
    required this.showTechnologies,
  });

  final ProjectEntity project;
  final double itemSpacing;
  final bool showDateRange;
  final bool showTechnologies;

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    if (start == null) {
      return AppDateUtils.DateUtils.formatDate(end);
    }
    if (end == null) {
      return '${AppDateUtils.DateUtils.formatDate(start)} - Present';
    }
    return AppDateUtils.DateUtils.formatDateRange(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: itemSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (showDateRange && (project.startDate != null || project.endDate != null))
                Text(
                  _formatDateRange(project.startDate, project.endDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.right,
                ),
            ],
          ),
          if (project.description != null && project.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              project.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (showTechnologies &&
              project.technologies != null &&
              project.technologies!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Technologies: ${project.technologies!}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          if (project.url != null && project.url!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              project.url!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
