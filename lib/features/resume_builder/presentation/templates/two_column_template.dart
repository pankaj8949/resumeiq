import 'package:flutter/material.dart';
import '../../domain/entities/resume_entity.dart';
import '../widgets/resume_header.dart';
import '../widgets/section_title.dart';
import '../widgets/summary_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/education_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/certifications_section.dart';
import '../../../../core/theme/app_theme.dart';

/// Two-Column Layout Template - Sidebar with skills and main content
class TwoColumnTemplate extends StatelessWidget {
  const TwoColumnTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar
          Container(
            width: 220,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.personalInfo != null)
                  ResumeHeader(
                    personalInfo: resume.personalInfo,
                    alignment: TextAlign.left,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                const SizedBox(height: 24),
                if (resume.skills.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Skills',
                    fontSize: 14,
                    padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
                  ),
                  SkillsSection(
                    skills: resume.skills,
                    displayStyle: SkillsDisplayStyle.bullets,
                    showBullets: true,
                  ),
                  const SizedBox(height: 24),
                ],
                if (resume.certifications.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Certifications',
                    fontSize: 14,
                    padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
                  ),
                  CertificationsSection(
                    certifications: resume.certifications,
                    showDate: false,
                    itemSpacing: 12,
                  ),
                  const SizedBox(height: 24),
                ],
                if (resume.education.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Education',
                    fontSize: 14,
                    padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
                  ),
                  EducationSection(
                    education: resume.education,
                    showGpa: false,
                    showDescription: false,
                    itemSpacing: 16,
                  ),
                ],
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (resume.summary != null && resume.summary!.isNotEmpty) ...[
                    SummarySection(summary: resume.summary),
                    const SizedBox(height: 24),
                  ],
                  if (resume.experience.isNotEmpty) ...[
                    SectionTitle(title: 'Professional Experience', underline: true),
                    const SizedBox(height: 12),
                    ExperienceSection(experience: resume.experience),
                    const SizedBox(height: 24),
                  ],
                  if (resume.projects.isNotEmpty) ...[
                    SectionTitle(title: 'Projects', underline: true),
                    const SizedBox(height: 12),
                    ProjectsSection(projects: resume.projects),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
