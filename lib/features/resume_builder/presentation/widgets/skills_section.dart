import 'package:flutter/material.dart';

/// Reusable skills section component
class SkillsSection extends StatelessWidget {
  const SkillsSection({
    super.key,
    required this.skills,
    this.displayStyle = SkillsDisplayStyle.wrap,
    this.showBullets = true,
    this.itemSpacing = 8.0,
    this.columns = 3,
  });

  final List<String> skills;
  final SkillsDisplayStyle displayStyle;
  final bool showBullets;
  final double itemSpacing;
  final int columns;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (displayStyle) {
      case SkillsDisplayStyle.wrap:
        return Wrap(
          spacing: itemSpacing,
          runSpacing: itemSpacing / 2,
          children: skills.map((skill) => _buildSkillItem(context, skill)).toList(),
        );
      case SkillsDisplayStyle.columns:
        return _buildColumnLayout(context);
      case SkillsDisplayStyle.bullets:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: skills
              .map(
                (skill) => Padding(
                  padding: EdgeInsets.only(bottom: itemSpacing / 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showBullets)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                          child: Text(
                            '•',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          skill,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
    }
  }

  Widget _buildSkillItem(BuildContext context, String skill) {
    return Text(
      skill,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildColumnLayout(BuildContext context) {
    final skillsPerColumn = (skills.length / columns).ceil();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columns, (columnIndex) {
        final startIndex = columnIndex * skillsPerColumn;
        final endIndex = (startIndex + skillsPerColumn).clamp(0, skills.length);
        final columnSkills = skills.sublist(startIndex, endIndex);

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnSkills
                .map(
                  (skill) => Padding(
                    padding: EdgeInsets.only(bottom: itemSpacing / 2),
                    child: Text(
                      skill,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }
}

enum SkillsDisplayStyle {
  wrap,
  columns,
  bullets,
}
