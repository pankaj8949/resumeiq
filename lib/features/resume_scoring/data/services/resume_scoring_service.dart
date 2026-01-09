import '../../../../shared/services/firebase_ai_service.dart';
import '../../../../shared/models/resume_score_model.dart';
import '../../../../shared/models/resume_model.dart';

/// Service for scoring resumes using AI
class ResumeScoringService {
  ResumeScoringService(this._firebaseAI);

  final FirebaseAIService? _firebaseAI;

  Future<ResumeScoreModel> scoreResume(ResumeModel resume, {String? jobDescription}) async {
    try {
      if (_firebaseAI == null) {
        throw Exception('Firebase AI is not configured. Please ensure Firebase is properly set up to use resume scoring features.');
      }
      
      final prompt = _buildScoringPrompt(resume, jobDescription);
      
      final response = await _firebaseAI.generateStructuredResponse(
        prompt: prompt,
        jsonSchema: _getScoringJsonSchema(),
      );

      return ResumeScoreModel(
        id: '',
        resumeId: resume.id,
        userId: resume.userId,
        overallScore: (response['overallScore'] as num).toInt(),
        atsCompatibility: (response['atsCompatibility'] as num).toInt(),
        keywordMatch: (response['keywordMatch'] as num).toInt(),
        contentQuality: (response['contentQuality'] as num).toInt(),
        formatting: (response['formatting'] as num).toInt(),
        grammar: (response['grammar'] as num).toInt(),
        impact: (response['impact'] as num).toInt(),
        strengths: List<String>.from(response['strengths'] ?? []),
        weaknesses: List<String>.from(response['weaknesses'] ?? []),
        suggestions: (response['suggestions'] as List?)
            ?.map((s) => ImprovementSuggestion(
                  category: s['category'] as String,
                  suggestion: s['suggestion'] as String,
                  priority: s['priority'] as String,
                ))
            .toList() ?? [],
        analyzedAt: DateTime.now(),
        jobDescription: jobDescription,
      );
    } catch (e) {
      throw Exception('Failed to score resume: $e');
    }
  }

  String _buildScoringPrompt(ResumeModel resume, String? jobDescription) {
    return '''
Analyze this resume and provide a comprehensive score (0-100) with detailed feedback.

RESUME DATA:
Name: ${resume.personalInfo?.fullName ?? 'N/A'}
Summary: ${resume.summary ?? 'N/A'}
Education: ${resume.education.map((e) => '${e.degree} from ${e.institution}').join(', ')}
Experience: ${resume.experience.map((e) => '${e.position} at ${e.company}').join(', ')}
Skills: ${resume.skills.join(', ')}
Projects: ${resume.projects.map((p) => p.name).join(', ')}
Certifications: ${resume.certifications.map((c) => c.name).join(', ')}

${jobDescription != null ? 'JOB DESCRIPTION:\n$jobDescription\n' : ''}

Provide scores (0-100) for:
1. ATS Compatibility - How well it will pass ATS systems
2. Keyword Match - Relevance to target role/job description
3. Content Quality - Overall content quality and clarity
4. Formatting - Professional formatting and structure
5. Grammar - Grammar and spelling
6. Impact - How impactful and impressive the achievements are

Calculate overallScore as weighted average (ATS: 25%, Keywords: 20%, Content: 20%, Formatting: 10%, Grammar: 10%, Impact: 15%).

Provide:
- 3-5 strengths
- 3-5 weaknesses
- 5-7 improvement suggestions with category (content, formatting, keywords, etc.) and priority (high, medium, low)
''';
  }

  String _getScoringJsonSchema() {
    return '''
{
  "overallScore": "number",
  "atsCompatibility": "number",
  "keywordMatch": "number",
  "contentQuality": "number",
  "formatting": "number",
  "grammar": "number",
  "impact": "number",
  "strengths": ["string"],
  "weaknesses": ["string"],
  "suggestions": [
    {
      "category": "string",
      "suggestion": "string",
      "priority": "string"
    }
  ]
}
''';
  }
}


