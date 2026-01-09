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

/// Consultant Template - Client-focused and results-oriented
class ConsultantTemplate extends StatelessWidget {
  const ConsultantTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      color: Colors.white,
      child: Column(
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
            SectionTitle(title: 'Consulting Experience', underline: true),
            const SizedBox(height: 12),
            ExperienceSection(experience: resume.experience),
            const SizedBox(height: 24),
          ],
          if (resume.projects.isNotEmpty) ...[
            SectionTitle(title: 'Client Engagements', underline: true),
            const SizedBox(height: 12),
            ProjectsSection(projects: resume.projects),
            const SizedBox(height: 24),
          ],
          if (resume.skills.isNotEmpty) ...[
            SectionTitle(title: 'Core Competencies', underline: true),
            const SizedBox(height: 12),
            SkillsSection(
              skills: resume.skills,
              displayStyle: SkillsDisplayStyle.columns,
              columns: 3,
            ),
            const SizedBox(height: 24),
          ],
          if (resume.education.isNotEmpty) ...[
            SectionTitle(title: 'Education', underline: true),
            const SizedBox(height: 12),
            EducationSection(education: resume.education),
            const SizedBox(height: 24),
          ],
          if (resume.certifications.isNotEmpty) ...[
            SectionTitle(title: 'Professional Certifications', underline: true),
            const SizedBox(height: 12),
            CertificationsSection(certifications: resume.certifications),
          ],
        ],
      ),
    );
  }
}
