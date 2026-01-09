import 'package:flutter/material.dart';
import '../../domain/entities/resume_entity.dart';
import '../widgets/experience_section.dart';
import '../widgets/education_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/certifications_section.dart';

/// ATS Optimized Template - Maximum ATS compatibility with simple formatting
class AtsOptimizedTemplate extends StatelessWidget {
  const AtsOptimizedTemplate({super.key, required this.resume});

  final ResumeEntity resume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header with all contact info
          if (resume.personalInfo != null) ...[
            Text(
              resume.personalInfo!.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: [
                if (resume.personalInfo!.email != null)
                  Text(resume.personalInfo!.email!),
                if (resume.personalInfo!.phone != null)
                  Text(resume.personalInfo!.phone!),
                if (resume.personalInfo!.location != null)
                  Text(resume.personalInfo!.location!),
              ],
            ),
            const SizedBox(height: 24),
          ],
          if (resume.summary != null && resume.summary!.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'PROFESSIONAL SUMMARY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resume.summary!,
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
          if (resume.experience.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'PROFESSIONAL EXPERIENCE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ExperienceSection(
              experience: resume.experience,
              itemSpacing: 20,
              showBullets: true,
              bulletStyle: '•',
            ),
            const SizedBox(height: 24),
          ],
          if (resume.education.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'EDUCATION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            EducationSection(education: resume.education, itemSpacing: 20),
            const SizedBox(height: 24),
          ],
          if (resume.skills.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'SKILLS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SkillsSection(
              skills: resume.skills,
              displayStyle: SkillsDisplayStyle.columns,
              columns: 4,
              showBullets: false,
            ),
            const SizedBox(height: 24),
          ],
          if (resume.certifications.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'CERTIFICATIONS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            CertificationsSection(certifications: resume.certifications, itemSpacing: 16),
          ],
        ],
      ),
    );
  }
}
