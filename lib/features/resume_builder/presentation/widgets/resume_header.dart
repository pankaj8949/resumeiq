import 'package:flutter/material.dart';
import '../../domain/entities/resume_entity.dart';

/// Reusable resume header component
class ResumeHeader extends StatelessWidget {
  const ResumeHeader({
    super.key,
    required this.personalInfo,
    this.textColor,
    this.accentColor,
    this.alignment = TextAlign.center,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.bold,
  });

  final PersonalInfoEntity? personalInfo;
  final Color? textColor;
  final Color? accentColor;
  final TextAlign alignment;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    if (personalInfo == null) {
      return const SizedBox.shrink();
    }

    final defaultTextColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    final defaultAccentColor = accentColor ?? Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment == TextAlign.center
          ? CrossAxisAlignment.center
          : alignment == TextAlign.right
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Text(
          personalInfo!.fullName,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: defaultTextColor,
            letterSpacing: 0.5,
            // fontFamily handled by DefaultTextStyle in PDF export context
          ),
          textAlign: alignment,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: alignment == TextAlign.center
              ? WrapAlignment.center
              : alignment == TextAlign.right
                  ? WrapAlignment.end
                  : WrapAlignment.start,
          spacing: 12,
          runSpacing: 4,
          children: [
            if (personalInfo!.email != null && personalInfo!.email!.isNotEmpty)
              _buildContactItem(
                context,
                personalInfo!.email!,
                defaultTextColor.withOpacity(0.8),
              ),
            if (personalInfo!.phone != null && personalInfo!.phone!.isNotEmpty)
              _buildContactItem(
                context,
                personalInfo!.phone!,
                defaultTextColor.withOpacity(0.8),
              ),
            if (personalInfo!.location != null && personalInfo!.location!.isNotEmpty)
              _buildContactItem(
                context,
                personalInfo!.location!,
                defaultTextColor.withOpacity(0.8),
              ),
            if (personalInfo!.linkedInUrl != null && personalInfo!.linkedInUrl!.isNotEmpty)
              _buildContactItem(
                context,
                'LinkedIn',
                defaultAccentColor,
              ),
            if (personalInfo!.portfolioUrl != null && personalInfo!.portfolioUrl!.isNotEmpty)
              _buildContactItem(
                context,
                'Portfolio',
                defaultAccentColor,
              ),
            if (personalInfo!.githubUrl != null && personalInfo!.githubUrl!.isNotEmpty)
              _buildContactItem(
                context,
                'GitHub',
                defaultAccentColor,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(BuildContext context, String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: color,
        // fontFamily handled by DefaultTextStyle in PDF export context
      ),
    );
  }
}
