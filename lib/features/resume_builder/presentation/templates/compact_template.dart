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

/// One-Page Compact Template - Condensed layout for one-page resumes
class CompactTemplate extends StatelessWidget {
  const CompactTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumeHeader(
            personalInfo: resume.personalInfo,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 16),
          if (resume.summary != null && resume.summary!.isNotEmpty) ...[
            SummarySection(
              summary: resume.summary,
              padding: const EdgeInsets.only(bottom: 12.0),
            ),
          ],
          // Two-column layout for compact space
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (resume.experience.isNotEmpty) ...[
                      SectionTitle(
                        title: 'Experience',
                        fontSize: 14,
                        padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
                      ),
                      ExperienceSection(
                        experience: resume.experience,
                        itemSpacing: 12,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (resume.education.isNotEmpty) ...[
                      SectionTitle(
                        title: 'Education',
                        fontSize: 14,
                        padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
                      ),
                      EducationSection(
                        education: resume.education,
                        showGpa: false,
                        showDescription: false,
                        itemSpacing: 12,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (resume.skills.isNotEmpty) ...[
                      SectionTitle(
                        title: 'Skills',
                        fontSize: 14,
                        padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
                      ),
                      SkillsSection(
                        skills: resume.skills,
                        displayStyle: SkillsDisplayStyle.bullets,
                        itemSpacing: 6,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (resume.projects.isNotEmpty) ...[
                      SectionTitle(
                        title: 'Projects',
                        fontSize: 14,
                        padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
                      ),
                      ProjectsSection(
                        projects: resume.projects,
                        itemSpacing: 12,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (resume.certifications.isNotEmpty) ...[
                      SectionTitle(
                        title: 'Certifications',
                        fontSize: 14,
                        padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
                      ),
                      CertificationsSection(
                        certifications: resume.certifications,
                        itemSpacing: 10,
                        showDate: false,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
