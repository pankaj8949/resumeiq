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

/// Modern Professional Template - Clean and contemporary design
class ModernTemplate extends StatelessWidget {
  const ModernTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumeHeader(
            personalInfo: resume.personalInfo,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 24),
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
          if (resume.education.isNotEmpty) ...[
            SectionTitle(title: 'Education', underline: true),
            const SizedBox(height: 12),
            EducationSection(education: resume.education),
            const SizedBox(height: 24),
          ],
          if (resume.skills.isNotEmpty) ...[
            SectionTitle(title: 'Skills', underline: true),
            const SizedBox(height: 12),
            SkillsSection(
              skills: resume.skills,
              displayStyle: SkillsDisplayStyle.wrap,
              showBullets: false,
            ),
            const SizedBox(height: 24),
          ],
          if (resume.projects.isNotEmpty) ...[
            SectionTitle(title: 'Projects', underline: true),
            const SizedBox(height: 12),
            ProjectsSection(projects: resume.projects),
            const SizedBox(height: 24),
          ],
          if (resume.certifications.isNotEmpty) ...[
            SectionTitle(title: 'Certifications', underline: true),
            const SizedBox(height: 12),
            CertificationsSection(certifications: resume.certifications),
          ],
        ],
      ),
    );
  }
}
