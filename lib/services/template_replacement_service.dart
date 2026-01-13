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

    // Also handle any remaining {{variable}} syntax as fallback
    result = result.replaceAll(
      '{{fullName}}',
      _escapeHtml(user.displayName ?? ''),
    );
    result = result.replaceAll('{{email}}', _escapeHtml(user.email));

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
          itemHtml = itemHtml.replaceAll(
            RegExp(
              r'\$RESPONSIBILITIES_START.*?\$RESPONSIBILITIES_END',
              dotAll: true,
            ),
            '',
          );
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
        itemHtml = itemHtml.replaceAll('\$description', descText);
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
      return template.replaceAll(pattern, '');
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

        itemHtml = itemHtml.replaceAll(
          '\$projectDescription',
          _escapeHtml(project.description ?? ''),
        );
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
      return template.replaceAll(pattern, '');
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
