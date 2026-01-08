import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../features/resume_builder/domain/entities/resume_entity.dart';
import '../../core/utils/date_utils.dart' as AppDateUtils;

/// Service for generating PDF documents from resume data
class PdfService {
  /// Generate PDF from resume and save to file
  Future<File> generatePdfFile(ResumeEntity resume) async {
    final pdf = await _generatePdf(resume);
    
    // Get directory for saving file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${_getFileName(resume.title)}.pdf';
    final file = File(filePath);
    
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Generate PDF document and share/print
  Future<void> sharePdf(ResumeEntity resume) async {
    final pdf = await _generatePdf(resume);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Save PDF to file and return file path
  Future<String> savePdf(ResumeEntity resume) async {
    final file = await generatePdfFile(resume);
    return file.path;
  }

  /// Generate PDF document
  Future<pw.Document> _generatePdf(ResumeEntity resume) async {
    final pdf = pw.Document();
    final personalInfo = resume.personalInfo;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        build: (pw.Context context) {
          return [
            // Header Section
            _buildHeader(personalInfo),
            pw.SizedBox(height: 24),
            
            // Summary Section
            if (resume.summary != null && resume.summary!.isNotEmpty) ...[
              _buildSectionTitle('Professional Summary'),
              pw.SizedBox(height: 8),
              _buildParagraph(resume.summary!),
              pw.SizedBox(height: 20),
            ],
            
            // Experience Section
            if (resume.experience.isNotEmpty) ...[
              _buildSectionTitle('Experience'),
              pw.SizedBox(height: 12),
              ...resume.experience.map((exp) => _buildExperienceItem(exp)),
              pw.SizedBox(height: 16),
            ],
            
            // Education Section
            if (resume.education.isNotEmpty) ...[
              _buildSectionTitle('Education'),
              pw.SizedBox(height: 12),
              ...resume.education.map((edu) => _buildEducationItem(edu)),
              pw.SizedBox(height: 16),
            ],
            
            // Skills Section
            if (resume.skills.isNotEmpty) ...[
              _buildSectionTitle('Skills'),
              pw.SizedBox(height: 8),
              _buildSkills(resume.skills),
              pw.SizedBox(height: 16),
            ],
            
            // Projects Section
            if (resume.projects.isNotEmpty) ...[
              _buildSectionTitle('Projects'),
              pw.SizedBox(height: 12),
              ...resume.projects.map((project) => _buildProjectItem(project)),
              pw.SizedBox(height: 16),
            ],
            
            // Certifications Section
            if (resume.certifications.isNotEmpty) ...[
              _buildSectionTitle('Certifications'),
              pw.SizedBox(height: 12),
              ...resume.certifications.map((cert) => _buildCertificationItem(cert)),
            ],
          ];
        },
      ),
    );

    return pdf;
  }

  /// Build header with personal information
  pw.Widget _buildHeader(PersonalInfoEntity? personalInfo) {
    if (personalInfo == null) {
      return pw.Container();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          personalInfo.fullName,
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            if (personalInfo.email != null) ...[
              _buildContactText(personalInfo.email!),
              if (personalInfo.phone != null || personalInfo.location != null) 
                pw.Text(' • ', style: pw.TextStyle(fontSize: 10)),
            ],
            if (personalInfo.phone != null) ...[
              _buildContactText(personalInfo.phone!),
              if (personalInfo.location != null) 
                pw.Text(' • ', style: pw.TextStyle(fontSize: 10)),
            ],
            if (personalInfo.location != null)
              _buildContactText(personalInfo.location!),
          ],
        ),
        if (personalInfo.linkedInUrl != null || personalInfo.githubUrl != null || personalInfo.portfolioUrl != null) ...[
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              if (personalInfo.linkedInUrl != null) ...[
                _buildContactText('LinkedIn: ${personalInfo.linkedInUrl!}'),
                if (personalInfo.githubUrl != null || personalInfo.portfolioUrl != null) 
                  pw.Text(' • ', style: pw.TextStyle(fontSize: 10)),
              ],
              if (personalInfo.githubUrl != null) ...[
                _buildContactText('GitHub: ${personalInfo.githubUrl!}'),
                if (personalInfo.portfolioUrl != null) 
                  pw.Text(' • ', style: pw.TextStyle(fontSize: 10)),
              ],
              if (personalInfo.portfolioUrl != null)
                _buildContactText('Portfolio: ${personalInfo.portfolioUrl!}'),
            ],
          ),
        ],
      ],
    );
  }

  pw.Widget _buildContactText(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
    );
  }

  /// Build section title
  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue700, width: 2),
        ),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue700,
        ),
      ),
    );
  }

  /// Build paragraph text
  pw.Widget _buildParagraph(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
      textAlign: pw.TextAlign.justify,
    );
  }

  /// Build experience item
  pw.Widget _buildExperienceItem(ExperienceEntity experience) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    experience.position,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    experience.company,
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            if (experience.startDate != null || experience.endDate != null)
              pw.Text(
                _formatDateRange(
                  experience.startDate,
                  experience.endDate,
                  experience.isCurrentRole ?? false,
                ),
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
          ],
        ),
        if (experience.location != null) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            experience.location!,
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
        if (experience.responsibilities.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          ...experience.responsibilities.map((responsibility) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: pw.TextStyle(fontSize: 11)),
                    pw.Expanded(
                      child: pw.Text(
                        responsibility,
                        style: pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
                      ),
                    ),
                  ],
                ),
              )),
        ],
        pw.SizedBox(height: 12),
      ],
    );
  }

  /// Build education item
  pw.Widget _buildEducationItem(EducationEntity education) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    education.degree,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    education.institution,
                    style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                  if (education.fieldOfStudy != null)
                    pw.Text(
                      education.fieldOfStudy!,
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  if (education.gpa != null)
                    pw.Text(
                      'GPA: ${education.gpa}',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  if (education.description != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      education.description!,
                      style: pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            if (education.startDate != null || education.endDate != null)
              pw.Text(
                _formatDateRange(education.startDate, education.endDate, false),
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  /// Build skills
  pw.Widget _buildSkills(List<String> skills) {
    return pw.Wrap(
      spacing: 6,
      runSpacing: 6,
      children: skills.map((skill) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.blue200, width: 0.5),
            ),
            child: pw.Text(
              skill,
              style: pw.TextStyle(fontSize: 9, color: PdfColors.blue900),
            ),
          )).toList(),
    );
  }

  /// Build project item
  pw.Widget _buildProjectItem(ProjectEntity project) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                project.name,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (project.startDate != null || project.endDate != null)
              pw.Text(
                _formatDateRange(project.startDate, project.endDate, false),
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
          ],
        ),
        if (project.description != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            project.description!,
            style: pw.TextStyle(fontSize: 10, lineSpacing: 1.4),
          ),
        ],
        if (project.technologies != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Technologies: ${project.technologies!}',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
        if (project.url != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            project.url!,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.blue700,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ],
        pw.SizedBox(height: 12),
      ],
    );
  }

  /// Build certification item
  pw.Widget _buildCertificationItem(CertificationEntity certification) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    certification.name,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (certification.issuer != null)
                    pw.Text(
                      certification.issuer!,
                      style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                    ),
                  if (certification.credentialId != null)
                    pw.Text(
                      'Credential ID: ${certification.credentialId!}',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                ],
              ),
            ),
            if (certification.issueDate != null)
              pw.Text(
                AppDateUtils.DateUtils.formatDate(certification.issueDate!, format: 'MMM yyyy'),
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
          ],
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  /// Format date range
  String _formatDateRange(DateTime? startDate, DateTime? endDate, bool isCurrent) {
    final start = startDate != null
        ? AppDateUtils.DateUtils.formatDate(startDate, format: 'MMM yyyy')
        : '';
    final end = isCurrent
        ? 'Present'
        : (endDate != null
            ? AppDateUtils.DateUtils.formatDate(endDate, format: 'MMM yyyy')
            : '');
    
    if (start.isEmpty && end.isEmpty) return '';
    if (start.isEmpty) return end;
    if (end.isEmpty) return start;
    return '$start - $end';
  }

  /// Get file name from resume title
  String _getFileName(String title) {
    // Remove special characters and replace spaces with underscores
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'_+'), '_');
  }
}

