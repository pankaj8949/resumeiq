import 'package:resumeiq/models/resume_model.dart';

import 'package:intl/intl.dart';

/// Service for generating HTML templates from ResumeModel
class HtmlTemplateService {
  HtmlTemplateService._();

  /// Generate HTML content for a resume based on template ID
  static String generateHtml({
    required ResumeModel resume,
    required String templateId,
  }) {
    switch (templateId) {
      case 'modern':
      case 'modern_professional':
        return _generateModernTemplate(resume);
      case 'minimal':
        return _generateMinimalTemplate(resume);
      case 'executive':
        return _generateExecutiveTemplate(resume);
      case 'developer':
      case 'tech_developer':
        return _generateDeveloperTemplate(resume);
      case 'creative':
      case 'creative_designer':
        return _generateCreativeTemplate(resume);
      case 'graduate':
        return _generateGraduateTemplate(resume);
      case 'academic':
        return _generateAcademicTemplate(resume);
      case 'product_manager':
        return _generateProductManagerTemplate(resume);
      case 'data_analyst':
        return _generateDataAnalystTemplate(resume);
      case 'marketing':
        return _generateMarketingTemplate(resume);
      case 'sales':
        return _generateSalesTemplate(resume);
      case 'finance':
        return _generateFinanceTemplate(resume);
      case 'operations':
        return _generateOperationsTemplate(resume);
      case 'two_column':
        return _generateTwoColumnTemplate(resume);
      case 'compact':
        return _generateCompactTemplate(resume);
      case 'classic':
        return _generateClassicTemplate(resume);
      case 'tech_lead':
        return _generateTechLeadTemplate(resume);
      case 'consultant':
        return _generateConsultantTemplate(resume);
      case 'executive_summary':
        return _generateExecutiveSummaryTemplate(resume);
      case 'ats_optimized':
        return _generateAtsOptimizedTemplate(resume);
      default:
        return _generateModernTemplate(resume);
    }
  }

  /// Base HTML structure wrapper
  static String _wrapHtml({
    required String content,
    required String title,
    String? additionalStyles = '',
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        @page {
            size: A4;
            margin: 0;
        }
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Roboto', 'Helvetica Neue', Arial, sans-serif;
            font-size: 11pt;
            line-height: 1.6;
            color: #333;
            background: white;
            padding: 40px;
        }
        $additionalStyles
    </style>
</head>
<body>
    $content
</body>
</html>
''';
  }

  /// Format date for display
  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM yyyy').format(date);
  }

  /// Format date range
  static String _formatDateRange(
    DateTime? start,
    DateTime? end,
    bool isCurrent,
  ) {
    final startStr = _formatDate(start);
    final endStr = isCurrent ? 'Present' : _formatDate(end);
    if (startStr.isEmpty && endStr.isEmpty) return '';
    return '$startStr - $endStr';
  }

  /// Escape HTML special characters
  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Generate header HTML
  static String _generateHeader(PersonalInfo? personalInfo) {
    if (personalInfo == null) return '';

    final name = _escapeHtml(personalInfo.fullName);
    final contactItems = <String>[];

    if (personalInfo.email != null && personalInfo.email!.isNotEmpty) {
      contactItems.add('📧 ${_escapeHtml(personalInfo.email!)}');
    }
    if (personalInfo.phone != null && personalInfo.phone!.isNotEmpty) {
      contactItems.add('📱 ${_escapeHtml(personalInfo.phone!)}');
    }
    if (personalInfo.location != null && personalInfo.location!.isNotEmpty) {
      contactItems.add('📍 ${_escapeHtml(personalInfo.location!)}');
    }
    if (personalInfo.linkedInUrl != null &&
        personalInfo.linkedInUrl!.isNotEmpty) {
      contactItems.add(
        '💼 <a href="${_escapeHtml(personalInfo.linkedInUrl!)}">LinkedIn</a>',
      );
    }
    if (personalInfo.githubUrl != null && personalInfo.githubUrl!.isNotEmpty) {
      contactItems.add(
        '💻 <a href="${_escapeHtml(personalInfo.githubUrl!)}">GitHub</a>',
      );
    }
    if (personalInfo.portfolioUrl != null &&
        personalInfo.portfolioUrl!.isNotEmpty) {
      contactItems.add(
        '🌐 <a href="${_escapeHtml(personalInfo.portfolioUrl!)}">Portfolio</a>',
      );
    }

    return '''
    <header style="margin-bottom: 30px; text-align: center; border-bottom: 2px solid #2563eb; padding-bottom: 20px;">
        <h1 style="font-size: 28px; font-weight: 700; color: #1e40af; margin-bottom: 10px;">$name</h1>
        <div style="font-size: 11pt; color: #666;">
            ${contactItems.join(' | ')}
        </div>
    </header>
''';
  }

  /// Generate summary section
  static String _generateSummary(String? summary) {
    if (summary == null || summary.isEmpty) return '';
    return '''
    <section style="margin-bottom: 25px;">
        <h2 style="font-size: 16pt; font-weight: 600; color: #1e40af; margin-bottom: 10px; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px;">Professional Summary</h2>
        <p style="text-align: justify; line-height: 1.7;">${_escapeHtml(summary)}</p>
    </section>
''';
  }

  /// Generate experience section
  static String _generateExperience(List<Experience> experience) {
    if (experience.isEmpty) return '';

    final items = experience
        .map((exp) {
          final position = _escapeHtml(exp.position);
          final company = _escapeHtml(exp.company);
          final location = exp.location != null && exp.location!.isNotEmpty
              ? _escapeHtml(exp.location!)
              : '';
          final dateRange = _formatDateRange(
            exp.startDate,
            exp.endDate,
            exp.isCurrentRole ?? false,
          );
          final responsibilities = exp.responsibilities
              .map((r) => '• ${_escapeHtml(r)}')
              .join('<br>');

          return '''
        <div style="margin-bottom: 20px;">
            <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                <div>
                    <strong style="font-size: 12pt; color: #1e40af;">$position</strong>
                    <span style="color: #666;"> - $company</span>
                    ${location.isNotEmpty ? '<span style="color: #999; font-size: 10pt;"> ($location)</span>' : ''}
                </div>
                <div style="color: #666; font-size: 10pt;">$dateRange</div>
            </div>
            ${responsibilities.isNotEmpty ? '<div style="margin-left: 20px; font-size: 10pt; line-height: 1.6;">$responsibilities</div>' : ''}
        </div>
''';
        })
        .join('');

    return '''
    <section style="margin-bottom: 25px;">
        <h2 style="font-size: 16pt; font-weight: 600; color: #1e40af; margin-bottom: 15px; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px;">Professional Experience</h2>
        $items
    </section>
''';
  }

  /// Generate education section
  static String _generateEducation(List<Education> education) {
    if (education.isEmpty) return '';

    final items = education
        .map((edu) {
          final degree = _escapeHtml(edu.degree);
          final institution = _escapeHtml(edu.institution);
          final fieldOfStudy =
              edu.fieldOfStudy != null && edu.fieldOfStudy!.isNotEmpty
              ? ', ${_escapeHtml(edu.fieldOfStudy!)}'
              : '';
          final dateRange = _formatDateRange(edu.startDate, edu.endDate, false);
          final gpa = edu.gpa != null
              ? ' | GPA: ${edu.gpa!.toStringAsFixed(2)}'
              : '';

          return '''
        <div style="margin-bottom: 15px;">
            <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                <div>
                    <strong style="font-size: 11pt; color: #1e40af;">$degree$fieldOfStudy</strong>
                    <span style="color: #666;"> - $institution</span>
                </div>
                <div style="color: #666; font-size: 10pt;">$dateRange$gpa</div>
            </div>
            ${edu.description != null && edu.description!.isNotEmpty ? '<p style="margin-left: 20px; font-size: 10pt; color: #666;">${_escapeHtml(edu.description!)}</p>' : ''}
        </div>
''';
        })
        .join('');

    return '''
    <section style="margin-bottom: 25px;">
        <h2 style="font-size: 16pt; font-weight: 600; color: #1e40af; margin-bottom: 15px; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px;">Education</h2>
        $items
    </section>
''';
  }

  /// Generate skills section
  static String _generateSkills(List<String> skills) {
    if (skills.isEmpty) return '';
    final skillsList = skills.map((s) => _escapeHtml(s)).join(', ');
    return '''
    <section style="margin-bottom: 25px;">
        <h2 style="font-size: 16pt; font-weight: 600; color: #1e40af; margin-bottom: 10px; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px;">Skills</h2>
        <p style="font-size: 10pt; line-height: 1.8;">$skillsList</p>
    </section>
''';
  }

  /// Generate projects section
  static String _generateProjects(List<Project> projects) {
    if (projects.isEmpty) return '';

    final items = projects
        .map((proj) {
          final name = _escapeHtml(proj.name);
          final description = _escapeHtml(proj.description ?? '');
          final technologies =
              proj.technologies != null && proj.technologies!.isNotEmpty
              ? 'Technologies: ${_escapeHtml(proj.technologies!)}'
              : '';
          final url = proj.url != null && proj.url!.isNotEmpty
              ? '<br><a href="${_escapeHtml(proj.url!)}">View Project</a>'
              : '';

          return '''
        <div style="margin-bottom: 15px;">
            <strong style="font-size: 11pt; color: #1e40af;">$name</strong>
            ${description.isNotEmpty ? '<p style="margin-top: 5px; font-size: 10pt; margin-left: 20px;">$description</p>' : ''}
            ${technologies.isNotEmpty ? '<p style="margin-left: 20px; font-size: 9pt; color: #666; font-style: italic;">$technologies</p>' : ''}
            $url
        </div>
''';
        })
        .join('');

    return '''
    <section style="margin-bottom: 25px;">
        <h2 style="font-size: 16pt; font-weight: 600; color: #1e40af; margin-bottom: 15px; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px;">Projects</h2>
        $items
    </section>
''';
  }

  /// Generate certifications section
  static String _generateCertifications(List<Certification> certifications) {
    if (certifications.isEmpty) return '';

    final items = certifications
        .map((cert) {
          final name = _escapeHtml(cert.name);
          final issuer = cert.issuer != null && cert.issuer!.isNotEmpty
              ? ' - ${_escapeHtml(cert.issuer!)}'
              : '';
          final date = cert.issueDate != null
              ? ' (${_formatDate(cert.issueDate)})'
              : '';
          final expiryDate = cert.expiryDate != null
              ? ' - Expires: ${_formatDate(cert.expiryDate)}'
              : '';

          return '''
        <div style="margin-bottom: 10px;">
            <strong style="font-size: 10pt; color: #1e40af;">$name</strong>
            <span style="color: #666; font-size: 10pt;">$issuer$date$expiryDate</span>
        </div>
''';
        })
        .join('');

    return '''
    <section style="margin-bottom: 25px;">
        <h2 style="font-size: 16pt; font-weight: 600; color: #1e40af; margin-bottom: 15px; border-bottom: 1px solid #e5e7eb; padding-bottom: 5px;">Certifications</h2>
        $items
    </section>
''';
  }

  /// Modern Professional Template
  static String _generateModernTemplate(ResumeModel resume) {
    final content =
        '''
${_generateHeader(resume.personalInfo)}
${_generateSummary(resume.summary)}
${_generateExperience(resume.experience)}
${_generateEducation(resume.education)}
${_generateSkills(resume.skills)}
${_generateProjects(resume.projects)}
${_generateCertifications(resume.certifications)}
''';

    return _wrapHtml(
      content: content,
      title: resume.title,
      additionalStyles: '',
    );
  }

  /// Minimal Template (simpler version of modern)
  static String _generateMinimalTemplate(ResumeModel resume) {
    final content =
        '''
${_generateHeader(resume.personalInfo)}
${_generateSummary(resume.summary)}
${_generateExperience(resume.experience)}
${_generateEducation(resume.education)}
${_generateSkills(resume.skills)}
''';

    return _wrapHtml(
      content: content,
      title: resume.title,
      additionalStyles: '''
        h2 {
            border-bottom: 1px solid #ccc !important;
        }
        section {
            margin-bottom: 20px !important;
        }
''',
    );
  }

  /// Executive Template (more formal)
  static String _generateExecutiveTemplate(ResumeModel resume) {
    return _generateModernTemplate(
      resume,
    ); // Same structure, different styling handled via CSS
  }

  /// Developer Template
  static String _generateDeveloperTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Creative Template
  static String _generateCreativeTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Graduate Template
  static String _generateGraduateTemplate(ResumeModel resume) {
    final content =
        '''
${_generateHeader(resume.personalInfo)}
${_generateSummary(resume.summary)}
${_generateEducation(resume.education)}
${_generateExperience(resume.experience)}
${_generateProjects(resume.projects)}
${_generateSkills(resume.skills)}
${_generateCertifications(resume.certifications)}
''';

    return _wrapHtml(content: content, title: resume.title);
  }

  /// Academic Template
  static String _generateAcademicTemplate(ResumeModel resume) {
    return _generateGraduateTemplate(resume);
  }

  /// Product Manager Template
  static String _generateProductManagerTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Data Analyst Template
  static String _generateDataAnalystTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Marketing Template
  static String _generateMarketingTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Sales Template
  static String _generateSalesTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Finance Template
  static String _generateFinanceTemplate(ResumeModel resume) {
    return _generateExecutiveTemplate(resume);
  }

  /// Operations Template
  static String _generateOperationsTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Two Column Template
  static String _generateTwoColumnTemplate(ResumeModel resume) {
    final sidebar =
        '''
    <div style="width: 30%; float: left; padding-right: 20px; border-right: 2px solid #e5e7eb;">
        ${_generateSkills(resume.skills)}
        ${_generateCertifications(resume.certifications)}
        ${resume.personalInfo?.linkedInUrl != null ? '<p style="margin-top: 15px;"><a href="${_escapeHtml(resume.personalInfo!.linkedInUrl!)}">LinkedIn</a></p>' : ''}
    </div>
''';

    final mainContent =
        '''
    <div style="width: 65%; float: right; padding-left: 20px;">
        ${_generateSummary(resume.summary)}
        ${_generateExperience(resume.experience)}
        ${_generateEducation(resume.education)}
        ${_generateProjects(resume.projects)}
    </div>
    <div style="clear: both;"></div>
''';

    final content =
        '''
${_generateHeader(resume.personalInfo)}
<div style="overflow: hidden;">
    $sidebar
    $mainContent
</div>
''';

    return _wrapHtml(
      content: content,
      title: resume.title,
      additionalStyles: '',
    );
  }

  /// Compact Template (one-page optimized)
  static String _generateCompactTemplate(ResumeModel resume) {
    final content =
        '''
${_generateHeader(resume.personalInfo)}
${_generateSummary(resume.summary)}
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
    <div>
        ${_generateExperience(resume.experience.take(3).toList())}
        ${_generateEducation(resume.education.take(2).toList())}
    </div>
    <div>
        ${_generateSkills(resume.skills)}
        ${_generateProjects(resume.projects.take(2).toList())}
        ${_generateCertifications(resume.certifications.take(3).toList())}
    </div>
</div>
''';

    return _wrapHtml(
      content: content,
      title: resume.title,
      additionalStyles: '''
        section {
            margin-bottom: 15px !important;
        }
        h2 {
            font-size: 14pt !important;
            margin-bottom: 8px !important;
        }
''',
    );
  }

  /// Classic Template
  static String _generateClassicTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Tech Lead Template
  static String _generateTechLeadTemplate(ResumeModel resume) {
    return _generateModernTemplate(resume);
  }

  /// Consultant Template
  static String _generateConsultantTemplate(ResumeModel resume) {
    return _generateExecutiveTemplate(resume);
  }

  /// Executive Summary Template
  static String _generateExecutiveSummaryTemplate(ResumeModel resume) {
    final expandedSummary = resume.summary != null && resume.summary!.isNotEmpty
        ? '<div style="margin-bottom: 25px; padding: 20px; background: #f3f4f6; border-left: 4px solid #1e40af;"><p style="font-size: 11pt; line-height: 1.8; text-align: justify;">${_escapeHtml(resume.summary!)}</p></div>'
        : '';

    final content =
        '''
${_generateHeader(resume.personalInfo)}
$expandedSummary
${_generateExperience(resume.experience)}
${_generateEducation(resume.education)}
${_generateSkills(resume.skills)}
''';

    return _wrapHtml(content: content, title: resume.title);
  }

  /// ATS Optimized Template (plain text, minimal styling)
  static String _generateAtsOptimizedTemplate(ResumeModel resume) {
    final content =
        '''
${_generateHeader(resume.personalInfo)}
${_generateSummary(resume.summary)}
${_generateExperience(resume.experience)}
${_generateEducation(resume.education)}
${_generateSkills(resume.skills)}
${_generateCertifications(resume.certifications)}
''';

    return _wrapHtml(
      content: content,
      title: resume.title,
      additionalStyles: '''
        * {
            color: #000 !important;
            background: #fff !important;
        }
        h1, h2 {
            border: none !important;
            text-transform: uppercase;
            font-weight: bold;
        }
        a {
            color: #000 !important;
            text-decoration: none;
        }
''',
    );
  }
}
