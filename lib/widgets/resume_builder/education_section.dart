import 'package:flutter/material.dart';
import 'package:resumeiq/models/resume_model.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;

/// Reusable education section component
class EducationSection extends StatelessWidget {
  const EducationSection({
    super.key,
    required this.education,
    this.itemSpacing = 16.0,
    this.showGpa = true,
    this.showDescription = true,
  });

  final List<Education> education;
  final double itemSpacing;
  final bool showGpa;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    if (education.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: education
          .map((edu) => _EducationItem(
                education: edu,
                itemSpacing: itemSpacing,
                showGpa: showGpa,
                showDescription: showDescription,
              ))
          .toList(),
    );
  }
}

class _EducationItem extends StatelessWidget {
  const _EducationItem({
    required this.education,
    required this.itemSpacing,
    required this.showGpa,
    required this.showDescription,
  });

  final Education education;
  final double itemSpacing;
  final bool showGpa;
  final bool showDescription;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      education.degree,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (education.fieldOfStudy != null && education.fieldOfStudy!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        education.fieldOfStudy!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      education.institution,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              if (education.startDate != null || education.endDate != null)
                Text(
                  _formatDateRange(education.startDate, education.endDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.right,
                ),
            ],
          ),
          if (showGpa && education.gpa != null) ...[
            const SizedBox(height: 4),
            Text(
              'GPA: ${education.gpa!.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
          if (showDescription &&
              education.description != null &&
              education.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              education.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
