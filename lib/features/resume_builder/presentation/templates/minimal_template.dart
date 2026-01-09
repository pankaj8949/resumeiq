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

/// Minimal ATS-Friendly Template - Ultra-clean, text-focused design
class MinimalTemplate extends StatelessWidget {
  const MinimalTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResumeHeader(
            personalInfo: resume.personalInfo,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
          const Divider(height: 32, thickness: 1),
          if (resume.summary != null && resume.summary!.isNotEmpty) ...[
            SummarySection(summary: resume.summary),
            const SizedBox(height: 20),
          ],
          if (resume.experience.isNotEmpty) ...[
            SectionTitle(title: 'Experience', padding: const EdgeInsets.only(bottom: 12.0, top: 20.0)),
            ExperienceSection(
              experience: resume.experience,
              itemSpacing: 20,
              showBullets: false,
              bulletStyle: '-',
            ),
            const SizedBox(height: 20),
          ],
          if (resume.education.isNotEmpty) ...[
            SectionTitle(title: 'Education', padding: const EdgeInsets.only(bottom: 12.0, top: 20.0)),
            EducationSection(education: resume.education, itemSpacing: 20),
            const SizedBox(height: 20),
          ],
          if (resume.skills.isNotEmpty) ...[
            SectionTitle(title: 'Skills', padding: const EdgeInsets.only(bottom: 12.0, top: 20.0)),
            SkillsSection(
              skills: resume.skills,
              displayStyle: SkillsDisplayStyle.columns,
              columns: 3,
              showBullets: false,
            ),
            const SizedBox(height: 20),
          ],
          if (resume.projects.isNotEmpty) ...[
            SectionTitle(title: 'Projects', padding: const EdgeInsets.only(bottom: 12.0, top: 20.0)),
            ProjectsSection(projects: resume.projects, itemSpacing: 20),
            const SizedBox(height: 20),
          ],
          if (resume.certifications.isNotEmpty) ...[
            SectionTitle(title: 'Certifications', padding: const EdgeInsets.only(bottom: 12.0, top: 20.0)),
            CertificationsSection(certifications: resume.certifications, itemSpacing: 16),
          ],
        ],
      ),
    );
  }
}
