import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../services/ai_resume_enhancement_service.dart';
import '../providers/auth_provider.dart';
import '../services/template_loader_service.dart';
import 'resume_preview_page.dart';

/// AI Resume Generation Page - Shows progress while AI enhances resume
class AIResumeGenerationPage extends ConsumerStatefulWidget {
  const AIResumeGenerationPage({
    super.key,
    required this.template,
  });

  final TemplateMetadata template;

  @override
  ConsumerState<AIResumeGenerationPage> createState() => _AIResumeGenerationPageState();
}

class _AIResumeGenerationPageState extends ConsumerState<AIResumeGenerationPage> {
  bool _isGenerating = true;
  bool _hasError = false;
  String? _errorMessage;
  String _currentStep = 'Analyzing your profile...';

  @override
  void initState() {
    super.initState();
    _generateEnhancedResume();
  }

  Future<void> _generateEnhancedResume() async {
    try {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) {
        setState(() {
          _isGenerating = false;
          _hasError = true;
          _errorMessage = 'Please sign in to generate your resume';
        });
        return;
      }

      setState(() {
        _currentStep = 'Analyzing your experience and skills...';
      });

      // Generate enhanced resume
      final enhancedUser = await AIResumeEnhancementService.instance
          .generateEnhancedResume(user);

      setState(() {
        _currentStep = 'Preparing preview...';
      });

      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        // Show success and navigate to resume preview (with Save/Share like normal resumes)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI resume generated! You can now preview, build PDF, save and share.'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to preview after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ResumePreviewPage(
                  template: widget.template,
                  overrideUser: enhancedUser,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _hasError = true;
        _errorMessage = 'Failed to generate enhanced resume: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate AI Resume'),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: _isGenerating
            ? _buildGeneratingState()
            : _hasError
                ? _buildErrorState()
                : _buildSuccessState(),
      ),
    );
  }

  Widget _buildGeneratingState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Generating Your Enhanced Resume',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _currentStep,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Our AI is analyzing your profile and creating an optimized resume',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Generation Failed',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'An error occurred while generating your resume',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go Back'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isGenerating = true;
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _generateEnhancedResume();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'AI Resume Ready!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your original profile/resumes were not changed. Preview it now and use Save/Share like a normal resume.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
