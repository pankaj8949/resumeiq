import 'package:flutter/material.dart';
import '../../domain/entities/resume_entity.dart';
import '../widgets/resume_header.dart';
import '../widgets/section_title.dart';
import '../widgets/summary_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/education_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/certifications_section.dart';

/// Classic Template - Traditional and formal layout
class ClassicTemplate extends StatelessWidget {
  const ClassicTemplate({super.key, required this.resume});

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
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 32),
          if (resume.summary != null && resume.summary!.isNotEmpty) ...[
            SummarySection(summary: resume.summary),
            const SizedBox(height: 32),
          ],
          if (resume.experience.isNotEmpty) ...[
            SectionTitle(
              title: 'Professional Experience',
              padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
            ),
            ExperienceSection(experience: resume.experience, itemSpacing: 24),
            const SizedBox(height: 32),
          ],
          if (resume.education.isNotEmpty) ...[
            SectionTitle(
              title: 'Education',
              padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
            ),
            EducationSection(education: resume.education, itemSpacing: 24),
            const SizedBox(height: 32),
          ],
          if (resume.skills.isNotEmpty) ...[
            SectionTitle(
              title: 'Skills',
              padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
            ),
            SkillsSection(
              skills: resume.skills,
              displayStyle: SkillsDisplayStyle.columns,
              columns: 3,
            ),
            const SizedBox(height: 32),
          ],
          if (resume.certifications.isNotEmpty) ...[
            SectionTitle(
              title: 'Certifications',
              padding: const EdgeInsets.only(bottom: 16.0, top: 24.0),
            ),
            CertificationsSection(certifications: resume.certifications, itemSpacing: 20),
          ],
        ],
      ),
    );
  }
}
