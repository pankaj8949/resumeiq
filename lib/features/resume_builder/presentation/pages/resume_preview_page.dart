import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../shared/services/pdf_service.dart';
import '../providers/resume_provider.dart';
import '../../domain/entities/resume_entity.dart';
import 'resume_builder_page.dart';

class ResumePreviewPage extends ConsumerStatefulWidget {
  const ResumePreviewPage({super.key, this.resumeId});

  final String? resumeId;

  @override
  ConsumerState<ResumePreviewPage> createState() => _ResumePreviewPageState();
}

class _ResumePreviewPageState extends ConsumerState<ResumePreviewPage> {
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    // Load resume data if resumeId is provided
    if (widget.resumeId != null && widget.resumeId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(resumeNotifierProvider.notifier).loadResume(widget.resumeId!);
      });
    }
  }

  Future<void> _exportPdf(ResumeEntity resume) async {
    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfService = PdfService();
      
      // Show share dialog
      await pdfService.sharePdf(resume);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeNotifierProvider);
    
    // If resumeId provided, load and show that resume
    ResumeEntity? resume;
    if (widget.resumeId != null && widget.resumeId!.isNotEmpty) {
      // Check if we have the resume loaded
      resume = resumeState.currentResume;
      
      // Verify it's the correct resume
      if (resume != null && resume.id != widget.resumeId) {
        resume = null; // Wrong resume, need to load the correct one
      }
      
      // If not loaded yet and not currently loading, load it
      if (resume == null && !resumeState.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(resumeNotifierProvider.notifier).loadResume(widget.resumeId!);
        });
      }
      
      if (resume == null && resumeState.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Resume Preview')),
          body: const LoadingWidget(),
        );
      }
    } else {
      // Otherwise show current resume from state
      resume = resumeState.currentResume;
    }

    if (resume == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resume Preview'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: EmptyStateWidget(
          icon: Icons.description,
          title: 'No Resume Data',
          message: 'Resume data is not available. Please go back and try again.',
          action: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ),
      );
    }

    // At this point, resume is guaranteed to be non-null
    final displayResume = resume;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayResume.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Resume',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ResumeBuilderPage(resumeId: displayResume.id),
                ),
              );
            },
          ),
          IconButton(
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: _isGeneratingPdf ? null : () => _exportPdf(displayResume),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(displayResume),
            const SizedBox(height: 32),
            
            // Summary Section
            if (displayResume.summary != null && displayResume.summary!.isNotEmpty) ...[
              _buildSectionTitle('Professional Summary'),
              const SizedBox(height: 12),
              _buildSectionContent(displayResume.summary!),
              const SizedBox(height: 32),
            ],
            
            // Experience Section
            if (displayResume.experience.isNotEmpty) ...[
              _buildSectionTitle('Experience'),
              const SizedBox(height: 12),
              ...displayResume.experience.map((exp) => _buildExperienceItem(exp)),
              const SizedBox(height: 32),
            ],
            
            // Education Section
            if (displayResume.education.isNotEmpty) ...[
              _buildSectionTitle('Education'),
              const SizedBox(height: 12),
              ...displayResume.education.map((edu) => _buildEducationItem(edu)),
              const SizedBox(height: 32),
            ],
            
            // Skills Section
            if (displayResume.skills.isNotEmpty) ...[
              _buildSectionTitle('Skills'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayResume.skills.map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                )).toList(),
              ),
              const SizedBox(height: 32),
            ],
            
            // Projects Section
            if (displayResume.projects.isNotEmpty) ...[
              _buildSectionTitle('Projects'),
              const SizedBox(height: 12),
              ...displayResume.projects.map((project) => _buildProjectItem(project)),
              const SizedBox(height: 32),
            ],
            
            // Certifications Section
            if (displayResume.certifications.isNotEmpty) ...[
              _buildSectionTitle('Certifications'),
              const SizedBox(height: 12),
              ...displayResume.certifications.map((cert) => _buildCertificationItem(cert)),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ResumeEntity resume) {
    final personalInfo = resume.personalInfo;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              personalInfo?.fullName ?? 'Your Name',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            if (personalInfo?.email != null)
              _buildContactInfo(Icons.email, personalInfo!.email!),
            if (personalInfo?.phone != null)
              _buildContactInfo(Icons.phone, personalInfo!.phone!),
            if (personalInfo?.location != null)
              _buildContactInfo(Icons.location_on, personalInfo!.location!),
            if (personalInfo?.linkedInUrl != null)
              _buildContactInfo(Icons.link, personalInfo!.linkedInUrl!),
            if (personalInfo?.githubUrl != null)
              _buildContactInfo(Icons.code, personalInfo!.githubUrl!),
            if (personalInfo?.portfolioUrl != null)
              _buildContactInfo(Icons.web, personalInfo!.portfolioUrl!),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildExperienceItem(ExperienceEntity experience) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        experience.position,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        experience.company,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (experience.startDate != null || experience.endDate != null)
                  Text(
                    _formatDateRange(experience.startDate, experience.endDate, experience.isCurrentRole ?? false),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            if (experience.location != null) ...[
              const SizedBox(height: 4),
              Text(
                experience.location!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
            if (experience.responsibilities.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...experience.responsibilities.map((responsibility) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            responsibility,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEducationItem(EducationEntity education) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    education.degree,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    education.institution,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  if (education.fieldOfStudy != null)
                    Text(
                      education.fieldOfStudy!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (education.gpa != null)
                    Text(
                      'GPA: ${education.gpa}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (education.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      education.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            if (education.startDate != null || education.endDate != null)
              Text(
                _formatDateRange(education.startDate, education.endDate, false),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(ProjectEntity project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (project.startDate != null || project.endDate != null)
                  Text(
                    _formatDateRange(project.startDate, project.endDate, false),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            if (project.description != null) ...[
              const SizedBox(height: 8),
              Text(
                project.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (project.technologies != null) ...[
              const SizedBox(height: 8),
              Text(
                'Technologies: ${project.technologies!}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
            if (project.url != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // TODO: Open URL
                },
                child: Text(
                  project.url!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationItem(CertificationEntity certification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certification.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (certification.issuer != null)
                    Text(
                      certification.issuer!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  if (certification.credentialId != null)
                    Text(
                      'Credential ID: ${certification.credentialId!}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (certification.issueDate != null)
              Text(
                AppDateUtils.DateUtils.formatDate(certification.issueDate!, format: 'MMM yyyy'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

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
}
