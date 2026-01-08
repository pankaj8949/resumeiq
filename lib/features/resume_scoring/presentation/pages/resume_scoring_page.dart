import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../resume_builder/presentation/providers/resume_provider.dart';
import '../../../resume_builder/domain/entities/resume_entity.dart';
import '../../data/services/resume_scoring_service.dart';
import '../../../../shared/models/resume_score_model.dart';
import '../../../../shared/models/resume_model.dart' as model;

final scoringServiceProvider = Provider<ResumeScoringService>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return ResumeScoringService(geminiService);
});

class ResumeScoringPage extends ConsumerStatefulWidget {
  const ResumeScoringPage({super.key});

  @override
  ConsumerState<ResumeScoringPage> createState() => _ResumeScoringPageState();
}

class _ResumeScoringPageState extends ConsumerState<ResumeScoringPage> {
  bool _isAnalyzing = false;
  ResumeScoreModel? _scoreResult;
  String? _error;

  Future<void> _pickAndAnalyzeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isAnalyzing = true;
          _error = null;
        });

        // For now, score using saved resumes
        // TODO: Parse uploaded file and extract resume data
        _analyzeResume();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick file: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeResume() async {
    try {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) {
        setState(() {
          _error = 'Please sign in first';
          _isAnalyzing = false;
        });
        return;
      }

      // Load user's latest resume
      await ref.read(resumeNotifierProvider.notifier).loadUserResumes(user.id);
      final resumes = ref.read(resumeNotifierProvider).resumes;

      if (resumes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = 'No resumes found. Please create a resume first using the Resume Builder.';
          _isAnalyzing = false;
        });
        return;
      }

      // Use the latest resume for scoring
      final latestResume = resumes.first;
      _performScoring(latestResume);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Analysis failed: $e';
        _isAnalyzing = false;
      });
    }
  }

  void _scoreExistingResume() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    await ref.read(resumeNotifierProvider.notifier).loadUserResumes(user.id);
    
    if (!mounted) return;
    
    final resumes = ref.read(resumeNotifierProvider).resumes;

    if (resumes.isEmpty) {
      setState(() {
        _error = 'No resumes found. Please create a resume first.';
        _isAnalyzing = false;
      });
      return;
    }

    // Show resume selection dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Resume'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: resumes.length,
            itemBuilder: (context, index) {
              final resume = resumes[index];
              return ListTile(
                title: Text(resume.title),
                subtitle: Text('Score: ${resume.score ?? 'Not scored'}'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _performScoring(resume);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _performScoring(ResumeEntity resume) async {
    try {
      if (!mounted) return;
      
      setState(() {
        _isAnalyzing = true;
        _error = null;
        _scoreResult = null;
      });

      // Convert ResumeEntity to ResumeModel
      final resumeModel = _entityToModel(resume);
      
      // Get the scoring service
      final scoringService = ref.read(scoringServiceProvider);
      
      // Score the resume
      final score = await scoringService.scoreResume(resumeModel);
      
      if (!mounted) return;
      
      // Update the resume with the new score by creating a new entity
      final updatedResume = ResumeEntity(
        id: resume.id,
        userId: resume.userId,
        title: resume.title,
        personalInfo: resume.personalInfo,
        summary: resume.summary,
        education: resume.education,
        experience: resume.experience,
        skills: resume.skills,
        projects: resume.projects,
        certifications: resume.certifications,
        theme: resume.theme,
        createdAt: resume.createdAt,
        updatedAt: resume.updatedAt,
        score: score.overallScore, // Update score
        fileUrl: resume.fileUrl,
      );
      await ref.read(resumeNotifierProvider.notifier).updateResume(updatedResume);
      
      setState(() {
        _isAnalyzing = false;
        _scoreResult = score;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Scoring failed: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  /// Convert ResumeEntity to ResumeModel for scoring service
  model.ResumeModel _entityToModel(ResumeEntity entity) {
    return model.ResumeModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      personalInfo: entity.personalInfo != null
          ? model.PersonalInfo(
              fullName: entity.personalInfo!.fullName,
              email: entity.personalInfo!.email,
              phone: entity.personalInfo!.phone,
              location: entity.personalInfo!.location,
              linkedInUrl: entity.personalInfo!.linkedInUrl,
              portfolioUrl: entity.personalInfo!.portfolioUrl,
              githubUrl: entity.personalInfo!.githubUrl,
            )
          : null,
      summary: entity.summary,
      education: entity.education
          .map((e) => model.Education(
                institution: e.institution,
                degree: e.degree,
                fieldOfStudy: e.fieldOfStudy,
                startDate: e.startDate,
                endDate: e.endDate,
                description: e.description,
                gpa: e.gpa,
              ))
          .toList(),
      experience: entity.experience
          .map((e) => model.Experience(
                company: e.company,
                position: e.position,
                startDate: e.startDate,
                endDate: e.endDate,
                responsibilities: e.responsibilities,
                location: e.location,
                isCurrentRole: e.isCurrentRole,
              ))
          .toList(),
      skills: entity.skills,
      projects: entity.projects
          .map((p) => model.Project(
                name: p.name,
                description: p.description,
                technologies: p.technologies,
                url: p.url,
                startDate: p.startDate,
                endDate: p.endDate,
              ))
          .toList(),
      certifications: entity.certifications
          .map((c) => model.Certification(
                name: c.name,
                issuer: c.issuer,
                issueDate: c.issueDate,
                expiryDate: c.expiryDate,
                credentialId: c.credentialId,
                url: c.url,
              ))
          .toList(),
      theme: entity.theme,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      score: entity.score,
      fileUrl: entity.fileUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analyzing Resume...')),
        body: const LoadingWidget(message: 'Analyzing your resume with AI...'),
      );
    }

    if (_scoreResult != null) {
      return _buildScoreResults();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Resume'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.assessment, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Get AI-Powered Resume Analysis',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your resume or select an existing one to get detailed scoring and improvement suggestions',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickAndAnalyzeFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Resume (PDF/DOCX)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _scoreExistingResume,
              icon: const Icon(Icons.folder),
              label: const Text('Score Existing Resume'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.errorColor),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What you\'ll get:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('Overall Score (0-100)', Icons.star),
                    _buildFeatureItem('Section-wise Breakdown', Icons.analytics),
                    _buildFeatureItem('ATS Compatibility Score', Icons.check_circle),
                    _buildFeatureItem('Improvement Suggestions', Icons.lightbulb),
                    _buildFeatureItem('Keyword Optimization Tips', Icons.search),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildScoreResults() {
    final score = _scoreResult!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Score'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _scoreResult = null),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Score Card
            Card(
              color: AppTheme.getScoreColor(score.overallScore),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Overall Score',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${score.overallScore}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score.overallScore >= 80
                          ? 'Excellent! Your resume is ATS-optimized.'
                          : score.overallScore >= 60
                              ? 'Good, but there\'s room for improvement.'
                              : 'Needs significant improvements.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Breakdown
            Text(
              'Score Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildScoreItem('ATS Compatibility', score.atsCompatibility),
            _buildScoreItem('Keyword Match', score.keywordMatch),
            _buildScoreItem('Content Quality', score.contentQuality),
            _buildScoreItem('Formatting', score.formatting),
            _buildScoreItem('Grammar', score.grammar),
            _buildScoreItem('Impact', score.impact),
            const SizedBox(height: 24),
            // Strengths
            if (score.strengths.isNotEmpty) ...[
              Text(
                'Strengths',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...score.strengths.map((strength) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: AppTheme.successColor),
                      title: Text(strength),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
            // Weaknesses
            if (score.weaknesses.isNotEmpty) ...[
              Text(
                'Areas for Improvement',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...score.weaknesses.map((weakness) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: AppTheme.warningColor),
                      title: Text(weakness),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
            // Suggestions
            if (score.suggestions.isNotEmpty) ...[
              Text(
                'Improvement Suggestions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...score.suggestions.map((suggestion) => Card(
                    child: ListTile(
                      leading: Icon(
                        suggestion.priority == 'high'
                            ? Icons.priority_high
                            : suggestion.priority == 'medium'
                                ? Icons.remove_circle_outline
                                : Icons.info_outline,
                        color: suggestion.priority == 'high'
                            ? AppTheme.errorColor
                            : suggestion.priority == 'medium'
                                ? AppTheme.warningColor
                                : AppTheme.textSecondary,
                      ),
                      title: Text(suggestion.category),
                      subtitle: Text(suggestion.suggestion),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.getScoreColor(score),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.getScoreColor(score)),
            ),
          ),
        ],
      ),
    );
  }
}
