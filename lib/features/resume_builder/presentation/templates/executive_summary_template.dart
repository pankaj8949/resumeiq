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

/// Executive Summary Template - High-level overview focused
class ExecutiveSummaryTemplate extends StatelessWidget {
  const ExecutiveSummaryTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
            ),
            child: ResumeHeader(
              personalInfo: resume.personalInfo,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              accentColor: AppTheme.primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.summary != null && resume.summary!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SummarySection(
                      summary: resume.summary,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.8,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
                if (resume.experience.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Executive Experience',
                    color: AppTheme.primaryColor,
                    underline: true,
                  ),
                  const SizedBox(height: 16),
                  ExperienceSection(experience: resume.experience),
                  const SizedBox(height: 28),
                ],
                if (resume.education.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Education',
                    color: AppTheme.primaryColor,
                    underline: true,
                  ),
                  const SizedBox(height: 16),
                  EducationSection(education: resume.education),
                  const SizedBox(height: 28),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (resume.skills.isNotEmpty) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(
                              title: 'Key Competencies',
                              color: AppTheme.primaryColor,
                              underline: true,
                            ),
                            const SizedBox(height: 12),
                            SkillsSection(
                              skills: resume.skills,
                              displayStyle: SkillsDisplayStyle.columns,
                              columns: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                    if (resume.certifications.isNotEmpty) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(
                              title: 'Credentials',
                              color: AppTheme.primaryColor,
                              underline: true,
                            ),
                            const SizedBox(height: 12),
                            CertificationsSection(
                              certifications: resume.certifications,
                              showDate: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
