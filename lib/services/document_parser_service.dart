import 'dart:io';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:logger/logger.dart';
import '../models/resume_model.dart';
import '../core/errors/exceptions.dart';
import 'firebase_ai_service.dart';
import '../core/utils/date_utils.dart';

/// Service for parsing uploaded resume documents (PDF/DOCX) and extracting structured data
class DocumentParserService {
  DocumentParserService(this._firebaseAI) : _logger = Logger();

  final FirebaseAIService? _firebaseAI;
  final Logger _logger;

  /// Parse a document file and extract resume data
  Future<ResumeModel> parseDocument({
    required String filePath,
    required String userId,
    required String fileName,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ApiException(
          message: 'File does not exist: $filePath',
          code: 'FILE_NOT_FOUND',
        );
      }

      // Get file extension
      final extension = fileName.split('.').last.toLowerCase();

      // Extract text based on file type
      String extractedText;
      switch (extension) {
        case 'pdf':
          extractedText = await _extractTextFromPdf(filePath);
          break;
        case 'docx':
        case 'doc':
          // TODO: Add DOCX parsing support
          // For now, throw an error suggesting PDF
          throw ApiException(
            message: 'DOCX parsing is not yet supported. Please upload a PDF file.',
            code: 'UNSUPPORTED_FORMAT',
          );
        default:
          throw ApiException(
            message: 'Unsupported file format: $extension',
            code: 'UNSUPPORTED_FORMAT',
          );
      }

      if (extractedText.trim().isEmpty) {
        throw ApiException(
          message: 'Could not extract text from document. The file may be corrupted or empty.',
          code: 'EMPTY_EXTRACTION',
        );
      }

      // Use AI to parse the extracted text into structured resume data
      return await _parseTextToResume(
        extractedText: extractedText,
        userId: userId,
        fileName: fileName,
      );
    } catch (e) {
      _logger.e('Failed to parse document', error: e);
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to parse document: ${e.toString()}',
        code: 'PARSE_FAILED',
      );
    }
  }

  /// Extract text from PDF file
  Future<String> _extractTextFromPdf(String filePath) async {
    try {
      // Load PDF document using fromPath
      final pdfDoc = await PDFDoc.fromPath(filePath);
      
      // Extract all text from the document at once
      final text = await pdfDoc.text;

      return text;
    } catch (e) {
      _logger.e('Failed to extract text from PDF', error: e);
      throw ApiException(
        message: 'Failed to extract text from PDF: ${e.toString()}',
        code: 'PDF_EXTRACTION_FAILED',
      );
    }
  }

  /// Use AI to parse extracted text into structured ResumeModel
  Future<ResumeModel> _parseTextToResume({
    required String extractedText,
    required String userId,
    required String fileName,
  }) async {
    final firebaseAI = _firebaseAI;
    if (firebaseAI == null) {
      throw ApiException(
        message: 'Firebase AI is not configured. Cannot parse resume document.',
        code: 'AI_NOT_CONFIGURED',
      );
    }

    try {
      final prompt = _buildParsingPrompt(extractedText);
      final jsonSchema = _getResumeJsonSchema();

      final response = await firebaseAI.generateStructuredResponse(
        prompt: prompt,
        jsonSchema: jsonSchema,
      );

      // Convert AI response to ResumeModel
      return _jsonToResumeModel(response, userId, fileName);
    } catch (e) {
      _logger.e('Failed to parse text to resume', error: e);
      throw ApiException(
        message: 'Failed to parse resume from document: ${e.toString()}',
        code: 'AI_PARSING_FAILED',
      );
    }
  }

  /// Build prompt for AI to extract resume data
  String _buildParsingPrompt(String extractedText) {
    return '''
Extract structured resume data from the following text. Identify and organize all information into the appropriate fields.

RESUME TEXT:
$extractedText

Extract the following information:
1. Personal Information: Full name, email, phone, location, LinkedIn, portfolio, GitHub
2. Summary/Objective: Professional summary or objective statement
3. Education: All education entries with institution, degree, field of study, dates, GPA, description
4. Experience: All work experience with company, position, dates, location, responsibilities, current role indicator
5. Skills: List of all skills mentioned
6. Projects: All projects with name, description, technologies, URL, dates
7. Certifications: All certifications with name, issuer, issue date, expiry date, credential ID, URL

For dates, use ISO format (YYYY-MM-DD) or null if not found.
For lists, return empty arrays if no items found.
Be thorough and extract all available information.
''';
  }

  /// Get JSON schema for resume structure
  String _getResumeJsonSchema() {
    return '''
{
  "personalInfo": {
    "fullName": "string",
    "email": "string|null",
    "phone": "string|null",
    "location": "string|null",
    "linkedInUrl": "string|null",
    "portfolioUrl": "string|null",
    "githubUrl": "string|null"
  },
  "summary": "string|null",
  "education": [
    {
      "institution": "string",
      "degree": "string",
      "fieldOfStudy": "string|null",
      "startDate": "string|null",
      "endDate": "string|null",
      "description": "string|null",
      "gpa": "string|null"
    }
  ],
  "experience": [
    {
      "company": "string",
      "position": "string",
      "startDate": "string|null",
      "endDate": "string|null",
      "location": "string|null",
      "responsibilities": ["string"],
      "isCurrentRole": "boolean"
    }
  ],
  "skills": ["string"],
  "projects": [
    {
      "name": "string",
      "description": "string|null",
      "technologies": ["string"],
      "url": "string|null",
      "startDate": "string|null",
      "endDate": "string|null"
    }
  ],
  "certifications": [
    {
      "name": "string",
      "issuer": "string|null",
      "issueDate": "string|null",
      "expiryDate": "string|null",
      "credentialId": "string|null",
      "url": "string|null"
    }
  ]
}
''';
  }

  /// Convert AI JSON response to ResumeModel
  ResumeModel _jsonToResumeModel(
    Map<String, dynamic> json,
    String userId,
    String fileName,
  ) {
    // Extract personal info
    PersonalInfo? personalInfo;
    if (json['personalInfo'] != null) {
      final pi = json['personalInfo'] as Map<String, dynamic>;
      if (pi['fullName'] != null) {
        personalInfo = PersonalInfo(
          fullName: pi['fullName'] as String,
          email: pi['email'] as String?,
          phone: pi['phone'] as String?,
          location: pi['location'] as String?,
          linkedInUrl: pi['linkedInUrl'] as String?,
          portfolioUrl: pi['portfolioUrl'] as String?,
          githubUrl: pi['githubUrl'] as String?,
        );
      }
    }

    // Extract education
    final educationList = <Education>[];
    if (json['education'] != null) {
      final eduList = json['education'] as List;
      for (final edu in eduList) {
        final eduMap = edu as Map<String, dynamic>;
        educationList.add(Education(
          institution: eduMap['institution'] as String? ?? '',
          degree: eduMap['degree'] as String? ?? '',
          fieldOfStudy: eduMap['fieldOfStudy'] as String?,
          startDate: DateUtils.parseDate(eduMap['startDate'] as String?),
          endDate: DateUtils.parseDate(eduMap['endDate'] as String?),
          description: eduMap['description'] as String?,
          gpa: eduMap['gpa'] != null ? double.tryParse(eduMap['gpa'].toString()) : null,
        ));
      }
    }

    // Extract experience
    final experienceList = <Experience>[];
    if (json['experience'] != null) {
      final expList = json['experience'] as List;
      for (final exp in expList) {
        final expMap = exp as Map<String, dynamic>;
        experienceList.add(Experience(
          company: expMap['company'] as String? ?? '',
          position: expMap['position'] as String? ?? '',
          startDate: DateUtils.parseDate(expMap['startDate'] as String?),
          endDate: DateUtils.parseDate(expMap['endDate'] as String?),
          location: expMap['location'] as String?,
          responsibilities: (expMap['responsibilities'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          isCurrentRole: expMap['isCurrentRole'] as bool? ?? false,
        ));
      }
    }

    // Extract skills
    final skillsList = <String>[];
    if (json['skills'] != null) {
      final skills = json['skills'] as List;
      skillsList.addAll(skills.map((s) => s.toString()));
    }

    // Extract projects
    final projectsList = <Project>[];
    if (json['projects'] != null) {
      final projList = json['projects'] as List;
      for (final proj in projList) {
        final projMap = proj as Map<String, dynamic>;
        final technologies = (projMap['technologies'] as List?)
                ?.map((t) => t.toString())
                .toList() ??
            [];
        projectsList.add(Project(
          name: projMap['name'] as String? ?? '',
          description: projMap['description'] as String?,
          technologies: technologies.join(', '), // Project model expects String, not List
          url: projMap['url'] as String?,
          startDate: DateUtils.parseDate(projMap['startDate'] as String?),
          endDate: DateUtils.parseDate(projMap['endDate'] as String?),
        ));
      }
    }

    // Extract certifications
    final certificationsList = <Certification>[];
    if (json['certifications'] != null) {
      final certList = json['certifications'] as List;
      for (final cert in certList) {
        final certMap = cert as Map<String, dynamic>;
        certificationsList.add(Certification(
          name: certMap['name'] as String? ?? '',
          issuer: certMap['issuer'] as String?,
          issueDate: DateUtils.parseDate(certMap['issueDate'] as String?),
          expiryDate: DateUtils.parseDate(certMap['expiryDate'] as String?),
          credentialId: certMap['credentialId'] as String?,
          url: certMap['url'] as String?,
        ));
      }
    }

    // Generate title from file name or personal info
    final title = personalInfo?.fullName != null
        ? '${personalInfo!.fullName} - Resume'
        : fileName.replaceAll(RegExp(r'\.(pdf|docx|doc)$'), '');

    return ResumeModel(
      id: '', // Will be set when saved
      userId: userId,
      title: title,
      personalInfo: personalInfo,
      summary: json['summary'] as String?,
      education: educationList,
      experience: experienceList,
      skills: skillsList,
      projects: projectsList,
      certifications: certificationsList,
      theme: 'modern',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
