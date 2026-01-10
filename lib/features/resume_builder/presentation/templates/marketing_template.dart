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

/// Marketing Professional Template - Campaign and results-focused
class MarketingTemplate extends StatelessWidget {
  const MarketingTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              border: Border(
                left: BorderSide(color: AppTheme.secondaryColor, width: 5),
              ),
            ),
            child: ResumeHeader(
              personalInfo: resume.personalInfo,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              accentColor: AppTheme.secondaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resume.summary != null && resume.summary!.isNotEmpty) ...[
                  SummarySection(summary: resume.summary),
                  const SizedBox(height: 24),
                ],
                if (resume.experience.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Marketing Experience',
                    color: AppTheme.secondaryColor,
                    underline: true,
                  ),
                  const SizedBox(height: 12),
                  ExperienceSection(experience: resume.experience),
                  const SizedBox(height: 24),
                ],
                if (resume.projects.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Campaigns & Projects',
                    color: AppTheme.secondaryColor,
                    underline: true,
                  ),
                  const SizedBox(height: 12),
                  ProjectsSection(projects: resume.projects),
                  const SizedBox(height: 24),
                ],
                if (resume.skills.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Marketing Skills',
                    color: AppTheme.secondaryColor,
                    underline: true,
                  ),
                  const SizedBox(height: 12),
                  SkillsSection(
                    skills: resume.skills,
                    displayStyle: SkillsDisplayStyle.wrap,
                  ),
                  const SizedBox(height: 24),
                ],
                if (resume.education.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Education',
                    color: AppTheme.secondaryColor,
                    underline: true,
                  ),
                  const SizedBox(height: 12),
                  EducationSection(education: resume.education),
                  const SizedBox(height: 24),
                ],
                if (resume.certifications.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Certifications',
                    color: AppTheme.secondaryColor,
                    underline: true,
                  ),
                  const SizedBox(height: 12),
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
