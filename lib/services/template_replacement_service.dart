import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../features/resume_builder/domain/entities/resume_entity.dart';

/// Service for replacing template placeholders with user data
class TemplateReplacementService {
  TemplateReplacementService._();
  static final TemplateReplacementService instance =
      TemplateReplacementService._();

  /// Replace template placeholders with user data
  String replaceTemplate(String htmlTemplate, UserModel user) {
    String result = htmlTemplate;

    // Replace personal info - always replace, even if empty
    result = result.replaceAll(
      '\$fullName',
      _escapeHtml(user.displayName ?? ''),
    );
    result = result.replaceAll('\$email', _escapeHtml(user.email));

    // Initials (used by some templates as a monogram)
    final initials = _getInitials(user.displayName ?? '');
    result = result.replaceAll('\$initials', _escapeHtml(initials));

    // Professional title (used by templates under the name).
    // Prefer current designation, otherwise most recent experience position.
    final professionalTitle = (user.currentDesignation ?? '').trim().isNotEmpty
        ? user.currentDesignation!.trim()
        : (user.experience.isNotEmpty ? user.experience.first.position : '');
    result = result.replaceAll(
      '\$professionalTitle',
      _escapeHtml(professionalTitle),
    );

    // Current designation (explicit placeholder)
    result = result.replaceAll(
      '\$currentDesignation',
      _escapeHtml((user.currentDesignation ?? '').trim()),
    );

    // Also handle any remaining {{variable}} syntax as fallback
    result = result.replaceAll(
      '{{fullName}}',
      _escapeHtml(user.displayName ?? ''),
    );
    result = result.replaceAll('{{email}}', _escapeHtml(user.email));
    result = result.replaceAll(
      '{{currentDesignation}}',
      _escapeHtml((user.currentDesignation ?? '').trim()),
    );

    // Handle email Mustache conditionals - email is always present, so replace the conditionals
    result = result.replaceAll(RegExp(r'\{\{#email\}\}', dotAll: true), '');
    result = result.replaceAll(RegExp(r'\{\{/email\}\}', dotAll: true), '');

    // Handle contact info with conditional display
    result = _replaceConditionalContact(result, 'phone', user.phone);
    result = _replaceConditionalContact(result, 'location', user.location);
    result = _replaceConditionalContact(
      result,
      'linkedInUrl',
      user.linkedInUrl,
    );
    result = _replaceConditionalContact(
      result,
      'portfolioUrl',
      user.portfolioUrl,
    );
    result = _replaceConditionalContact(result, 'githubUrl', user.githubUrl);

    // Replace summary - always replace, even if empty (will show empty)
    result = result.replaceAll('\$summary', _escapeHtml(user.summary ?? ''));
    // Remove summary Mustache conditionals
    result = result.replaceAll(RegExp(r'\{\{#summary\}\}', dotAll: true), '');
    result = result.replaceAll(RegExp(r'\{\{/summary\}\}', dotAll: true), '');

    // Replace experience section
    result = _replaceExperienceSection(result, user.experience);

    // Replace education section
    result = _replaceEducationSection(result, user.education);

    // Replace skills section
    result = _replaceSkillsSection(result, user.skills);

    // Replace projects section
    result = _replaceProjectsSection(result, user.projects);

    // Replace certifications section
    result = _replaceCertificationsSection(result, user.certifications);

    // Final cleanup: remove empty spans, Mustache conditionals, and any remaining unreplaced variables
    result = _cleanupEmptyElements(result);
    result = _removeAllMustacheSyntax(result);

    return result;
  }

  String _getInitials(String fullName) {
    final cleaned = fullName.trim();
    if (cleaned.isEmpty) return '';
    final parts =
        cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s[0].toUpperCase();
    }
    final first = parts.first[0];
    final last = parts.last[0];
    return (first + last).toUpperCase();
  }

  /// Clean up empty elements and unreplaced variables
  String _cleanupEmptyElements(String template) {
    String result = template;

    // Remove empty spans (spans with only whitespace, emoji, or empty content)
    result = result.replaceAll(
      RegExp(r'<span[^>]*>\s*📧\s*</span>', dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<span[^>]*>\s*📱\s*</span>', dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<span[^>]*>\s*📍\s*</span>', dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<span[^>]*>\s*🔗\s*</span>', dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<span[^>]*>\s*🌐\s*</span>', dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<span[^>]*>\s*💻\s*</span>', dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<span[^>]*>\s*</span>', dotAll: true),
      '',
    );

    // Remove empty divs that might have been left behind
    result = result.replaceAll(
      RegExp(r'<div class="item-subtitle">\s*</div>', dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<div class="certification-issuer">\s*</div>', dotAll: true),
      '',
    );
    result = result.replaceAll(
      RegExp(r'<div class="item-description">\s*</div>', dotAll: true),
      '',
    );

    // Remove any remaining unreplaced $ variables as safety net (shouldn't happen if all templates are updated)
    result = result.replaceAll(
      RegExp(r'\$[A-Z_]+', dotAll: true),
      '',
    ); // Only remove loop markers if any remain
    result = result.replaceAll(
      RegExp(r'\$[a-z]+', dotAll: true),
      '',
    ); // Remove any simple variables that weren't replaced

    return result;
  }

  /// Remove all remaining Mustache syntax patterns
  String _removeAllMustacheSyntax(String template) {
    String result = template;

    // Remove all Mustache conditionals ({{#field}} and {{/field}})
    result = result.replaceAll(RegExp(r'\{\{#\w+\}\}', dotAll: true), '');
    result = result.replaceAll(RegExp(r'\{\{/\w+\}\}', dotAll: true), '');
    result = result.replaceAll(
      RegExp(r'\{\{\^\w+\}\}', dotAll: true),
      '',
    ); // Negative conditionals

    // Remove any remaining {{variable}} patterns that weren't replaced
    result = result.replaceAll(RegExp(r'\{\{[^}]+\}\}', dotAll: true), '');

    return result;
  }

  String _replaceExperienceSection(
    String template,
    List<ExperienceEntity> experiences,
  ) {
    final pattern = RegExp(
      r'\$EXPERIENCE_START(.*?)\$EXPERIENCE_END',
      dotAll: true,
    );

    if (experiences.isEmpty) {
      return template.replaceAll(pattern, '');
    }

    return template.replaceAllMapped(pattern, (match) {
      final itemTemplate = match.group(1) ?? '';
      final buffer = StringBuffer();

      for (final exp in experiences) {
        String itemHtml = itemTemplate;
        itemHtml = itemHtml.replaceAll('\$position', _escapeHtml(exp.position));
        itemHtml = itemHtml.replaceAll('\$company', _escapeHtml(exp.company));

        // Handle location - show " | location" only if present
        if (exp.location != null && exp.location!.isNotEmpty) {
          itemHtml = itemHtml.replaceAll(
            '\$expLocation',
            ' | ${_escapeHtml(exp.location!)}',
          );
        } else {
          itemHtml = itemHtml.replaceAll('\$expLocation', '');
        }

        // Clean up any double spaces or trailing separators
        itemHtml = itemHtml.replaceAll(
          RegExp(r'\s+\|\s+', dotAll: true),
          ' | ',
        );
        itemHtml = itemHtml.replaceAll(
          RegExp(r'^\s*\|\s+', dotAll: true, multiLine: true),
          '',
        );

        final startDate = exp.startDate != null
            ? DateFormat('MMM yyyy').format(exp.startDate!)
            : '';
        final endDate = exp.isCurrentRole == true
            ? 'Present'
            : (exp.endDate != null
                  ? DateFormat('MMM yyyy').format(exp.endDate!)
                  : '');
        itemHtml = itemHtml.replaceAll('\$startDate', startDate);
        itemHtml = itemHtml.replaceAll('\$endDate', endDate);

        // Replace responsibilities
        if (exp.responsibilities.isNotEmpty) {
          final respPattern = RegExp(
            r'\$RESPONSIBILITIES_START(.*?)\$RESPONSIBILITIES_END',
            dotAll: true,
          );
          itemHtml = itemHtml.replaceAllMapped(respPattern, (respMatch) {
            final liTemplate = respMatch.group(1) ?? '';
            return exp.responsibilities
                .map(
                  (r) =>
                      liTemplate.replaceAll('\$responsibility', _escapeHtml(r)),
                )
                .join('');
          });
        } else {
          // Remove the entire ul block if no responsibilities
          itemHtml = itemHtml.replaceAll(
            RegExp(
              r'\$RESPONSIBILITIES_START.*?\$RESPONSIBILITIES_END',
              dotAll: true,
            ),
            '',
          );
          // Also remove empty ul tags that might be left
          itemHtml = itemHtml.replaceAll(
            RegExp(
              r'<ul[^>]*>\s*</ul>',
              dotAll: true,
            ),
            '',
          );
        }

        // Handle description - show if present (must be done after responsibilities)
        // Format as paragraph text, not list item
        if (exp.description != null && exp.description!.isNotEmpty) {
          final marginTop = exp.responsibilities.isNotEmpty ? '8px' : '0px';
          // If description was authored as bullet lines (common with AI), flatten it into a single paragraph.
          final normalized = exp.description!
              // remove leading bullet markers per line: -, •, –, —
              .replaceAll(
                RegExp(r'^\s*[-•–—]\s*', multiLine: true),
                '',
              )
              // collapse newlines into spaces
              .replaceAll(RegExp(r'[\r\n]+'), ' ')
              // collapse repeated whitespace
              .replaceAll(RegExp(r'\s{2,}'), ' ')
              .trim();

          final descHtml =
              '<p style="margin-top: $marginTop; margin-bottom: 0; padding: 0; display: block;">${_escapeHtml(normalized)}</p>';
          itemHtml = itemHtml.replaceAll('\$expDescription', descHtml);
        } else {
          itemHtml = itemHtml.replaceAll('\$expDescription', '');
        }

        buffer.writeln(itemHtml);
      }

      return buffer.toString();
    });
  }

  String _replaceEducationSection(
    String template,
    List<EducationEntity> educations,
  ) {
    final pattern = RegExp(
      r'\$EDUCATION_START(.*?)\$EDUCATION_END',
      dotAll: true,
    );

    if (educations.isEmpty) {
      return template.replaceAll(pattern, '');
    }

    return template.replaceAllMapped(pattern, (match) {
      final itemTemplate = match.group(1) ?? '';
      final buffer = StringBuffer();

      for (final edu in educations) {
        String itemHtml = itemTemplate;
        itemHtml = itemHtml.replaceAll('\$degree', _escapeHtml(edu.degree));

        // Handle fieldOfStudy - show " in fieldOfStudy" only if present
        if (edu.fieldOfStudy != null && edu.fieldOfStudy!.isNotEmpty) {
          itemHtml = itemHtml.replaceAll(
            '\$fieldOfStudy',
            ' in ${_escapeHtml(edu.fieldOfStudy!)}',
          );
        } else {
          itemHtml = itemHtml.replaceAll('\$fieldOfStudy', '');
        }

        itemHtml = itemHtml.replaceAll(
          '\$institution',
          _escapeHtml(edu.institution),
        );

        final startDate = edu.startDate != null
            ? DateFormat('yyyy').format(edu.startDate!)
            : '';
        final endDate = edu.endDate != null
            ? DateFormat('yyyy').format(edu.endDate!)
            : '';
        itemHtml = itemHtml.replaceAll('\$eduStartDate', startDate);
        itemHtml = itemHtml.replaceAll('\$eduEndDate', endDate);

        // Handle description and GPA
        String descText = '';
        if (edu.description != null && edu.description!.isNotEmpty) {
          descText = _escapeHtml(edu.description!);
        }
        if (edu.gpa != null) {
          descText += '${descText.isNotEmpty ? ' | ' : ''}GPA: ${edu.gpa}';
        }
        if (descText.isNotEmpty) {
          // Wrap description in a div for proper styling
          final descHtml = '<div style="margin-top: 0; margin-bottom: 0; color: inherit; font-size: inherit; line-height: inherit;">$descText</div>';
          itemHtml = itemHtml.replaceAll('\$description', descHtml);
        } else {
          // Remove empty description div if no content
          itemHtml = itemHtml.replaceAll(
            RegExp(
              r'<div[^>]*class="[^"]*item-description[^"]*"[^>]*>\s*\$description\s*</div>',
              dotAll: true,
            ),
            '',
          );
          itemHtml = itemHtml.replaceAll('\$description', '');
        }
        itemHtml = itemHtml.replaceAll(
          '\$gpa',
          '',
        ); // Already handled in description

        buffer.writeln(itemHtml);
      }

      return buffer.toString();
    });
  }

  String _replaceSkillsSection(String template, List<String> skills) {
    final pattern = RegExp(r'\$SKILLS_START(.*?)\$SKILLS_END', dotAll: true);

    if (skills.isEmpty) {
      return template.replaceAll(pattern, '');
    }

    return template.replaceAllMapped(pattern, (match) {
      final itemTemplate = match.group(1) ?? '';
      return skills
          .map(
            (skill) => itemTemplate.replaceAll('\$skill', _escapeHtml(skill)),
          )
          .join('');
    });
  }

  String _replaceProjectsSection(
    String template,
    List<ProjectEntity> projects,
  ) {
    final pattern = RegExp(
      r'\$PROJECTS_START(.*?)\$PROJECTS_END',
      dotAll: true,
    );

    if (projects.isEmpty) {
      // Remove any section wrapper that contains the projects markers (regardless of heading text).
      return template
          .replaceAll(
            RegExp(
              r'<div[^>]*class="[^"]*section[^"]*"[^>]*>[\s\S]*?\$PROJECTS_START[\s\S]*?\$PROJECTS_END[\s\S]*?</div>',
              dotAll: true,
            ),
            '',
          )
          .replaceAll(pattern, '');
    }

    return template.replaceAllMapped(pattern, (match) {
      final itemTemplate = match.group(1) ?? '';
      final buffer = StringBuffer();

      for (final project in projects) {
        String itemHtml = itemTemplate;
        itemHtml = itemHtml.replaceAll(
          '\$projectName',
          _escapeHtml(project.name),
        );

        // Handle URL - always replace, empty string if not present
        itemHtml = itemHtml.replaceAll(
          '\$projectUrl',
          _escapeHtml(project.url ?? ''),
        );

        // Handle project description - show if present
        if (project.description != null && project.description!.isNotEmpty) {
          final descHtml = '<div style="margin-top: 8px; margin-bottom: 0;">${_escapeHtml(project.description!)}</div>';
          itemHtml = itemHtml.replaceAll('\$projectDescription', descHtml);
        } else {
          itemHtml = itemHtml.replaceAll('\$projectDescription', '');
        }
        itemHtml = itemHtml.replaceAll(
          '\$projectTechnologies',
          _escapeHtml(project.technologies ?? ''),
        );

        final startDate = project.startDate != null
            ? DateFormat('yyyy').format(project.startDate!)
            : '';
        final endDate = project.endDate != null
            ? DateFormat('yyyy').format(project.endDate!)
            : 'Present';
        itemHtml = itemHtml.replaceAll('\$projectStartDate', startDate);
        itemHtml = itemHtml.replaceAll('\$projectEndDate', endDate);

        buffer.writeln(itemHtml);
      }

      return buffer.toString();
    });
  }

  String _replaceCertificationsSection(
    String template,
    List<CertificationEntity> certifications,
  ) {
    final pattern = RegExp(
      r'\$CERTIFICATIONS_START(.*?)\$CERTIFICATIONS_END',
      dotAll: true,
    );

    if (certifications.isEmpty) {
      // Remove any section wrapper that contains the certifications markers (regardless of heading text).
      return template
          .replaceAll(
            RegExp(
              r'<div[^>]*class="[^"]*section[^"]*"[^>]*>[\s\S]*?\$CERTIFICATIONS_START[\s\S]*?\$CERTIFICATIONS_END[\s\S]*?</div>',
              dotAll: true,
            ),
            '',
          )
          .replaceAll(pattern, '');
    }

    return template.replaceAllMapped(pattern, (match) {
      final itemTemplate = match.group(1) ?? '';
      final buffer = StringBuffer();

      for (final cert in certifications) {
        String itemHtml = itemTemplate;
        itemHtml = itemHtml.replaceAll('\$certName', _escapeHtml(cert.name));
        itemHtml = itemHtml.replaceAll(
          '\$certIssuer',
          _escapeHtml(cert.issuer ?? ''),
        );

        final issueDate = cert.issueDate != null
            ? DateFormat('yyyy').format(cert.issueDate!)
            : '';
        itemHtml = itemHtml.replaceAll('\$certIssueDate', issueDate);

        buffer.writeln(itemHtml);
      }

      return buffer.toString();
    });
  }

  /// Replace conditional contact info - hide span if empty
  String _replaceConditionalContact(
    String template,
    String fieldName,
    String? value,
  ) {
    String result = template;

    if (value != null && value.isNotEmpty) {
      // Replace the variable with the value
      result = result.replaceAll('\$$fieldName', _escapeHtml(value));
      // Also handle {{variable}} syntax
      result = result.replaceAll('{{$fieldName}}', _escapeHtml(value));
      // Remove Mustache conditionals - value exists, so keep content but remove conditionals
      result = result.replaceAll(
        RegExp(r'\{\{#$fieldName\}\}', dotAll: true),
        '',
      );
      result = result.replaceAll(
        RegExp(r'\{\{/$fieldName\}\}', dotAll: true),
        '',
      );
    } else {
      // Remove the entire span element if value is empty
      result = result.replaceAll(
        RegExp(r'<span[^>]*>\s*\$' + fieldName + r'\s*</span>', dotAll: true),
        '',
      );
      result = result.replaceAll(
        RegExp(
          r'<span[^>]*>\s*📧\s*\$' + fieldName + r'\s*</span>',
          dotAll: true,
        ),
        '',
      );
      result = result.replaceAll(
        RegExp(
          r'<span[^>]*>\s*📱\s*\$' + fieldName + r'\s*</span>',
          dotAll: true,
        ),
        '',
      );
      result = result.replaceAll(
        RegExp(
          r'<span[^>]*>\s*📍\s*\$' + fieldName + r'\s*</span>',
          dotAll: true,
        ),
        '',
      );
      result = result.replaceAll(
        RegExp(
          r'<span[^>]*>\s*🔗\s*\$' + fieldName + r'\s*</span>',
          dotAll: true,
        ),
        '',
      );
      result = result.replaceAll(
        RegExp(
          r'<span[^>]*>\s*🌐\s*\$' + fieldName + r'\s*</span>',
          dotAll: true,
        ),
        '',
      );
      result = result.replaceAll(
        RegExp(
          r'<span[^>]*>\s*💻\s*\$' + fieldName + r'\s*</span>',
          dotAll: true,
        ),
        '',
      );
      // Remove standalone variable
      result = result.replaceAll('\$$fieldName', '');
      // Remove entire Mustache conditional block if value is empty
      result = result.replaceAll(
        RegExp(r'\{\{#$fieldName\}\}.*?\{\{/$fieldName\}\}', dotAll: true),
        '',
      );
      result = result.replaceAll('{{$fieldName}}', '');
    }

    return result;
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Get list of missing fields for warnings
  List<String> getMissingFields(UserModel user) {
    final missing = <String>[];

    if (user.displayName == null || user.displayName!.isEmpty) {
      missing.add('Full Name');
    }
    if (user.phone == null || user.phone!.isEmpty) {
      missing.add('Phone');
    }
    if (user.location == null || user.location!.isEmpty) {
      missing.add('Location');
    }
    if (user.currentDesignation == null || user.currentDesignation!.isEmpty) {
      missing.add('Current Designation');
    }
    if (user.summary == null || user.summary!.isEmpty) {
      missing.add('Professional Summary');
    }
    if (user.experience.isEmpty) {
      missing.add('Work Experience');
    }
    if (user.education.isEmpty) {
      missing.add('Education');
    }
    if (user.skills.isEmpty) {
      missing.add('Skills');
    }

    return missing;
  }
}
