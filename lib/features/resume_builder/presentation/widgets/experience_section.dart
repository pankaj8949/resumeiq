import 'package:flutter/material.dart';
import '../../domain/entities/resume_entity.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;

/// Reusable experience section component
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({
    super.key,
    required this.experience,
    this.itemSpacing = 16.0,
    this.showBullets = true,
    this.bulletStyle = '•',
  });

  final List<ExperienceEntity> experience;
  final double itemSpacing;
  final bool showBullets;
  final String bulletStyle;

  @override
  Widget build(BuildContext context) {
    if (experience.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: experience
          .map((exp) => _ExperienceItem(
                experience: exp,
                itemSpacing: itemSpacing,
                showBullets: showBullets,
                bulletStyle: bulletStyle,
              ))
          .toList(),
    );
  }
}

class _ExperienceItem extends StatelessWidget {
  const _ExperienceItem({
    required this.experience,
    required this.itemSpacing,
    required this.showBullets,
    required this.bulletStyle,
  });

  final ExperienceEntity experience;
  final double itemSpacing;
  final bool showBullets;
  final String bulletStyle;

  String _formatDateRange(DateTime? start, DateTime? end, bool isCurrent) {
    if (start == null) return '';
    final startStr = AppDateUtils.DateUtils.formatDate(start);
    if (end == null || isCurrent) {
      return '$startStr - Present';
    }
    final endStr = AppDateUtils.DateUtils.formatDate(end);
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: itemSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.position,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      experience.company,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              if (experience.startDate != null)
                Text(
                  _formatDateRange(
                    experience.startDate,
                    experience.endDate,
                    experience.isCurrentRole ?? false,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.right,
                ),
            ],
          ),
          if (experience.location != null && experience.location!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              experience.location!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
          if (experience.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...experience.responsibilities.map(
              (responsibility) => Padding(
                padding: EdgeInsets.only(
                  left: showBullets ? 16.0 : 0,
                  bottom: 4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBullets)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                        child: Text(
                          bulletStyle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        responsibility,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
