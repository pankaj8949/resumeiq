import 'package:flutter/material.dart';
import '../../domain/entities/resume_entity.dart';
import '../widgets/resume_header.dart';
import '../widgets/section_title.dart';
import '../widgets/summary_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/education_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/certifications_section.dart';
import '../../../../core/theme/app_theme.dart';

/// Corporate Executive Template - Formal and authoritative design
class ExecutiveTemplate extends StatelessWidget {
  const ExecutiveTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with accent bar
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: AppTheme.primaryColor, width: 4),
              ),
            ),
            child: ResumeHeader(
              personalInfo: resume.personalInfo,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.summary != null && resume.summary!.isNotEmpty) ...[
                  SummarySection(summary: resume.summary),
                  const SizedBox(height: 28),
                ],
                if (resume.experience.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Professional Experience',
                    underline: true,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  ExperienceSection(experience: resume.experience),
                  const SizedBox(height: 28),
                ],
                if (resume.education.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Education',
                    underline: true,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  EducationSection(education: resume.education),
                  const SizedBox(height: 28),
                ],
                if (resume.skills.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Core Competencies',
                    underline: true,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  SkillsSection(
                    skills: resume.skills,
                    displayStyle: SkillsDisplayStyle.columns,
                    columns: 4,
                  ),
                  const SizedBox(height: 28),
                ],
                if (resume.certifications.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Certifications & Credentials',
                    underline: true,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  CertificationsSection(certifications: resume.certifications),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
