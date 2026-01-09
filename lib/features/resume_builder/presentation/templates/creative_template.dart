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

/// Designer / Creative Template - Bold and eye-catching design
class CreativeTemplate extends StatelessWidget {
  const CreativeTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored header section
          Container(
            padding: const EdgeInsets.all(36.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ResumeHeader(
              personalInfo: resume.personalInfo,
              textColor: Colors.white,
              accentColor: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
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
                    title: 'Experience',
                    color: AppTheme.primaryColor,
                    fontSize: 20,
                    underline: true,
                  ),
                  const SizedBox(height: 16),
                  ExperienceSection(experience: resume.experience),
                  const SizedBox(height: 24),
                ],
                if (resume.projects.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Portfolio Projects',
                    color: AppTheme.primaryColor,
                    fontSize: 20,
                    underline: true,
                  ),
                  const SizedBox(height: 16),
                  ProjectsSection(projects: resume.projects),
                  const SizedBox(height: 24),
                ],
                if (resume.skills.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Skills & Tools',
                    color: AppTheme.primaryColor,
                    fontSize: 20,
                    underline: true,
                  ),
                  const SizedBox(height: 16),
                  SkillsSection(
                    skills: resume.skills,
                    displayStyle: SkillsDisplayStyle.wrap,
                  ),
                  const SizedBox(height: 24),
                ],
                if (resume.education.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Education',
                    color: AppTheme.primaryColor,
                    fontSize: 20,
                    underline: true,
                  ),
                  const SizedBox(height: 16),
                  EducationSection(education: resume.education),
                  const SizedBox(height: 24),
                ],
                if (resume.certifications.isNotEmpty) ...[
                  SectionTitle(
                    title: 'Certifications',
                    color: AppTheme.primaryColor,
                    fontSize: 20,
                    underline: true,
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
