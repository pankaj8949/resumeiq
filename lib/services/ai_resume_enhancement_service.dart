import 'dart:convert';
import 'package:resumeiq/models/user_model.dart';
import 'package:resumeiq/features/resume_builder/domain/entities/resume_entity.dart';
import 'package:resumeiq/services/firebase_ai_service.dart';
import 'package:intl/intl.dart';

/// Service for AI-powered resume enhancement
class AIResumeEnhancementService {
  AIResumeEnhancementService._();
  static final AIResumeEnhancementService instance = AIResumeEnhancementService._();

  final FirebaseAIService _aiService = FirebaseAIService();

  /// Generate an enhanced resume using AI
  Future<UserModel> generateEnhancedResume(UserModel user) async {
    try {
      // Build comprehensive prompt with user's existing data
      final prompt = _buildEnhancementPrompt(user);

      // Generate enhanced resume content
      final enhancedContent = await _aiService.generateText(
        prompt: prompt,
        temperature: 0.7, // Balanced creativity and accuracy
        maxOutputTokens: 4000,
      );

      // Parse and apply enhancements
      return _applyEnhancements(user, enhancedContent);
    } catch (e) {
      // If AI fails, return original user data
      return user;
    }
  }

  String _buildEnhancementPrompt(UserModel user) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are an expert resume writer and career coach. Your task is to enhance the following resume information to create a professional, ATS-friendly, and compelling resume.');
    buffer.writeln('');
    buffer.writeln('CURRENT RESUME INFORMATION:');
    buffer.writeln('');
    
    // Personal Info
    buffer.writeln('PERSONAL INFORMATION:');
    buffer.writeln('Name: ${user.displayName ?? "Not provided"}');
    buffer.writeln('Email: ${user.email}');
    buffer.writeln('Phone: ${user.phone ?? "Not provided"}');
    buffer.writeln('Location: ${user.location ?? "Not provided"}');
    buffer.writeln('LinkedIn: ${user.linkedInUrl ?? "Not provided"}');
    buffer.writeln('Portfolio: ${user.portfolioUrl ?? "Not provided"}');
    buffer.writeln('GitHub: ${user.githubUrl ?? "Not provided"}');
    buffer.writeln('');
    
    // Summary
    if (user.summary != null && user.summary!.isNotEmpty) {
      buffer.writeln('CURRENT SUMMARY:');
      buffer.writeln(user.summary);
      buffer.writeln('');
    }
    
    // Experience
    if (user.experience.isNotEmpty) {
      buffer.writeln('EXPERIENCE:');
      for (var exp in user.experience) {
        buffer.writeln('- Position: ${exp.position}');
        buffer.writeln('  Company: ${exp.company}');
        if (exp.location != null) buffer.writeln('  Location: ${exp.location}');
        if (exp.startDate != null) {
          buffer.writeln('  Start: ${DateFormat('MMM yyyy').format(exp.startDate!)}');
        }
        if (exp.endDate != null) {
          buffer.writeln('  End: ${DateFormat('MMM yyyy').format(exp.endDate!)}');
        } else if (exp.isCurrentRole == true) {
          buffer.writeln('  End: Present');
        }
        if (exp.description != null && exp.description!.isNotEmpty) {
          buffer.writeln('  Description: ${exp.description}');
        }
        if (exp.responsibilities.isNotEmpty) {
          buffer.writeln('  Responsibilities:');
          for (var resp in exp.responsibilities) {
            buffer.writeln('    - $resp');
          }
        }
        buffer.writeln('');
      }
    }
    
    // Education
    if (user.education.isNotEmpty) {
      buffer.writeln('EDUCATION:');
      for (var edu in user.education) {
        buffer.writeln('- Degree: ${edu.degree}');
        buffer.writeln('  Institution: ${edu.institution}');
        if (edu.fieldOfStudy != null) buffer.writeln('  Field: ${edu.fieldOfStudy}');
        if (edu.gpa != null) buffer.writeln('  GPA: ${edu.gpa}');
        if (edu.description != null && edu.description!.isNotEmpty) {
          buffer.writeln('  Description: ${edu.description}');
        }
        buffer.writeln('');
      }
    }
    
    // Skills
    if (user.skills.isNotEmpty) {
      buffer.writeln('SKILLS: ${user.skills.join(", ")}');
      buffer.writeln('');
    }
    
    // Projects
    if (user.projects.isNotEmpty) {
      buffer.writeln('PROJECTS:');
      for (var proj in user.projects) {
        buffer.writeln('- Name: ${proj.name}');
        if (proj.description != null) buffer.writeln('  Description: ${proj.description}');
        if (proj.technologies != null) buffer.writeln('  Technologies: ${proj.technologies}');
        if (proj.url != null) buffer.writeln('  URL: ${proj.url}');
        buffer.writeln('');
      }
    }
    
    // Certifications
    if (user.certifications.isNotEmpty) {
      buffer.writeln('CERTIFICATIONS:');
      for (var cert in user.certifications) {
        buffer.writeln('- Name: ${cert.name}');
        if (cert.issuer != null) buffer.writeln('  Issuer: ${cert.issuer}');
        buffer.writeln('');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('ENHANCEMENT REQUIREMENTS:');
    buffer.writeln('1. Create a compelling professional summary (2-3 sentences) that highlights key achievements, skills, and value proposition. Make it ATS-friendly with relevant keywords.');
    buffer.writeln('2. Enhance each experience entry:');
    buffer.writeln('   - Rewrite descriptions to be achievement-focused with quantifiable results');
    buffer.writeln('   - Add impactful responsibility bullets that use action verbs');
    buffer.writeln('   - Ensure each bullet point starts with a strong action verb');
    buffer.writeln('   - Include metrics, percentages, and specific achievements where possible');
    buffer.writeln('   - Make descriptions more professional and impactful');
    buffer.writeln('3. Enhance education descriptions to highlight relevant coursework, achievements, or honors');
    buffer.writeln('4. Ensure all content is professional, concise, and ATS-optimized');
    buffer.writeln('5. Maintain accuracy - do not add false information, only enhance what exists');
    buffer.writeln('');
    buffer.writeln('OUTPUT FORMAT:');
    buffer.writeln('Provide the enhanced resume in the following JSON format:');
    buffer.writeln('{');
    buffer.writeln('  "summary": "Enhanced professional summary (2-3 sentences)",');
    buffer.writeln('  "experience": [');
    buffer.writeln('    {');
    buffer.writeln('      "description": "Enhanced description with achievements",');
    buffer.writeln('      "responsibilities": ["Enhanced bullet 1", "Enhanced bullet 2", ...]');
    buffer.writeln('    },');
    buffer.writeln('    ...');
    buffer.writeln('  ],');
    buffer.writeln('  "education": [');
    buffer.writeln('    {');
    buffer.writeln('      "description": "Enhanced education description"');
    buffer.writeln('    },');
    buffer.writeln('    ...');
    buffer.writeln('  ]');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('IMPORTANT: Only return valid JSON. Do not include markdown formatting or explanations.');

    return buffer.toString();
  }

  UserModel _applyEnhancements(UserModel user, String aiResponse) {
    try {
      // Clean the response (remove markdown if present)
      var cleanResponse = aiResponse.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.startsWith('```')) {
        cleanResponse = cleanResponse.substring(3);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      cleanResponse = cleanResponse.trim();

      // Parse JSON
      final Map<String, dynamic> enhancements = 
          (cleanResponse.contains('{') && cleanResponse.contains('}'))
              ? _parseJsonResponse(cleanResponse)
              : _parseTextResponse(aiResponse, user);

      // Apply enhancements
      final enhancedSummary = enhancements['summary'] as String? ?? user.summary;
      
      // Enhance experience
      final enhancedExperience = <ExperienceEntity>[];
      final expEnhancements = enhancements['experience'] as List? ?? [];
      for (int i = 0; i < user.experience.length; i++) {
        final originalExp = user.experience[i];
        final expEnh = i < expEnhancements.length 
            ? expEnhancements[i] as Map<String, dynamic>? 
            : null;
        
        enhancedExperience.add(ExperienceEntity(
          company: originalExp.company,
          position: originalExp.position,
          startDate: originalExp.startDate,
          endDate: originalExp.endDate,
          location: originalExp.location,
          isCurrentRole: originalExp.isCurrentRole,
          description: expEnh?['description'] as String? ?? originalExp.description,
          responsibilities: (expEnh?['responsibilities'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              originalExp.responsibilities,
        ));
      }

      // Enhance education
      final enhancedEducation = <EducationEntity>[];
      final eduEnhancements = enhancements['education'] as List? ?? [];
      for (int i = 0; i < user.education.length; i++) {
        final originalEdu = user.education[i];
        final eduEnh = i < eduEnhancements.length 
            ? eduEnhancements[i] as Map<String, dynamic>? 
            : null;
        
        enhancedEducation.add(EducationEntity(
          institution: originalEdu.institution,
          degree: originalEdu.degree,
          fieldOfStudy: originalEdu.fieldOfStudy,
          startDate: originalEdu.startDate,
          endDate: originalEdu.endDate,
          gpa: originalEdu.gpa,
          description: eduEnh?['description'] as String? ?? originalEdu.description,
        ));
      }

      // Return enhanced user model
      return UserModel(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        phone: user.phone,
        location: user.location,
        linkedInUrl: user.linkedInUrl,
        portfolioUrl: user.portfolioUrl,
        githubUrl: user.githubUrl,
        summary: enhancedSummary,
        education: enhancedEducation,
        experience: enhancedExperience,
        skills: user.skills,
        projects: user.projects,
        certifications: user.certifications,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );
    } catch (e) {
      // If parsing fails, return original user
      return user;
    }
  }

  Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      // Try to find JSON object in the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd + 1);
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        return decoded;
      }
    } catch (e) {
      // Try to extract JSON from markdown code blocks
      try {
        final codeBlockMatch = RegExp(r'```(?:json)?\s*(\{.*?\})\s*```', dotAll: true).firstMatch(response);
        if (codeBlockMatch != null) {
          final jsonStr = codeBlockMatch.group(1) ?? '';
          return json.decode(jsonStr) as Map<String, dynamic>;
        }
      } catch (e2) {
        // Fall through to text parsing
      }
    }
    return {};
  }

  Map<String, dynamic> _parseTextResponse(String response, UserModel user) {
    // Fallback: extract summary from text response
    final result = <String, dynamic>{};
    
    // Try to find summary
    final summaryPatterns = [
      RegExp(r'Summary[:\s]+(.*?)(?:\n\n|\nExperience|$)', dotAll: true, caseSensitive: false),
      RegExp(r'Professional Summary[:\s]+(.*?)(?:\n\n|\nExperience|$)', dotAll: true, caseSensitive: false),
    ];
    
    for (final pattern in summaryPatterns) {
      final match = pattern.firstMatch(response);
      if (match != null) {
        result['summary'] = match.group(1)?.trim() ?? user.summary;
        break;
      }
    }
    
    return result;
  }
}
