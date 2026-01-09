import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/date_utils.dart' as AppDateUtils;
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/pages/edit_profile_page.dart';
import '../providers/resume_provider.dart';
import '../../domain/entities/resume_entity.dart';
import 'resume_preview_page.dart';

class ResumeBuilderPage extends ConsumerStatefulWidget {
  const ResumeBuilderPage({super.key, this.resumeId, this.templateId});

  final String? resumeId;
  final String? templateId;

  @override
  ConsumerState<ResumeBuilderPage> createState() => _ResumeBuilderPageState();
}

class _ResumeBuilderPageState extends ConsumerState<ResumeBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'My Resume');
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _githubController = TextEditingController();
  final _summaryController = TextEditingController();

  int _currentStep = 0;
  final List<EducationEntity> _educationList = [];
  final List<ExperienceEntity> _experienceList = [];
  final List<String> _skillsList = [];
  final List<ProjectEntity> _projectsList = [];
  final List<CertificationEntity> _certificationsList = [];

  bool _isLoadingResume = false;

  @override
  void initState() {
    super.initState();
    // Load resume data if editing, otherwise load from user profile
    if (widget.resumeId != null && widget.resumeId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadResume(widget.resumeId!);
      });
    } else {
      // Load from user profile for new resume
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFromUserProfile();
      });
    }
  }

  void _loadFromUserProfile() {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    // Pre-fill personal info from user profile
    _fullNameController.text = user.displayName ?? '';
    _phoneController.text = user.phone ?? '';
    _locationController.text = user.location ?? '';
    _linkedInController.text = user.linkedInUrl ?? '';
    _portfolioController.text = user.portfolioUrl ?? '';
    _githubController.text = user.githubUrl ?? '';
    _emailController.text = user.email;

    // Pre-fill summary
    _summaryController.text = user.summary ?? '';

    // Pre-fill lists from user profile
    setState(() {
      _educationList.clear();
      _educationList.addAll(user.education);

      _experienceList.clear();
      _experienceList.addAll(user.experience);

      _skillsList.clear();
      _skillsList.addAll(user.skills);

      _projectsList.clear();
      _projectsList.addAll(user.projects);

      _certificationsList.clear();
      _certificationsList.addAll(user.certifications);
    });
  }

  Future<void> _loadResume(String resumeId) async {
    if (!mounted) return;

    setState(() {
      _isLoadingResume = true;
    });

    // First try to get from already loaded resumes
    final resumeState = ref.read(resumeNotifierProvider);
    ResumeEntity? resume;

    // Check if resume is already in the loaded list
    try {
      resume = resumeState.resumes.firstWhere((r) => r.id == resumeId);
    } catch (e) {
      // Resume not in loaded list, will fetch from Firestore
      resume = null;
    }

    // If not found in loaded list, fetch from Firestore
    resume ??= await ref
        .read(resumeNotifierProvider.notifier)
        .loadResume(resumeId);

    if (!mounted) return;

    setState(() {
      _isLoadingResume = false;
    });

    if (resume != null && resume.id.isNotEmpty && mounted) {
      final loadedResume = resume; // Capture non-null reference

      // Populate title
      _titleController.text = loadedResume.title;

      // Populate personal info
      if (loadedResume.personalInfo != null) {
        final personalInfo = loadedResume.personalInfo!;
        _fullNameController.text = personalInfo.fullName;
        _emailController.text = personalInfo.email ?? '';
        _phoneController.text = personalInfo.phone ?? '';
        _locationController.text = personalInfo.location ?? '';
        _linkedInController.text = personalInfo.linkedInUrl ?? '';
        _portfolioController.text = personalInfo.portfolioUrl ?? '';
        _githubController.text = personalInfo.githubUrl ?? '';
      }

      // Populate summary
      _summaryController.text = loadedResume.summary ?? '';

      // Populate lists - these are always non-null (have defaults)
      setState(() {
        _educationList.clear();
        _educationList.addAll(loadedResume.education);

        _experienceList.clear();
        _experienceList.addAll(loadedResume.experience);

        _skillsList.clear();
        _skillsList.addAll(loadedResume.skills);

        _projectsList.clear();
        _projectsList.addAll(loadedResume.projects);

        _certificationsList.clear();
        _certificationsList.addAll(loadedResume.certifications);
      });
    } else if (mounted) {
      final error = ref.read(resumeNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to load resume'),
          backgroundColor: Colors.red,
        ),
      );
      // Go back if failed to load
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedInController.dispose();
    _portfolioController.dispose();
    _githubController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateSummary() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name first')),
      );
      return;
    }

    final personalInfo = PersonalInfoEntity(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    final summary = await ref
        .read(resumeNotifierProvider.notifier)
        .generateSummary(
          personalInfo: personalInfo,
          experience: _experienceList,
          education: _educationList,
          skills: _skillsList,
        );

    if (summary != null && mounted) {
      _summaryController.text = summary;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Summary generated successfully!')),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final personalInfo = PersonalInfoEntity(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      linkedInUrl: _linkedInController.text.trim().isEmpty
          ? null
          : _linkedInController.text.trim(),
      portfolioUrl: _portfolioController.text.trim().isEmpty
          ? null
          : _portfolioController.text.trim(),
      githubUrl: _githubController.text.trim().isEmpty
          ? null
          : _githubController.text.trim(),
    );

    final resume = ResumeEntity(
      id: widget.resumeId ?? '',
      userId: user.id,
      title: _titleController.text.trim(),
      personalInfo: personalInfo,
      summary: _summaryController.text.trim().isEmpty
          ? null
          : _summaryController.text.trim(),
      education: _educationList,
      experience: _experienceList,
      skills: _skillsList,
      projects: _projectsList,
      certifications: _certificationsList,
      theme:
          widget.templateId ??
          (widget.resumeId != null && widget.resumeId!.isNotEmpty
              ? ref.read(resumeNotifierProvider).currentResume?.theme ??
                    'modern'
              : 'modern'),
    );

    // Use update if editing, create if new
    final bool success;
    if (widget.resumeId != null && widget.resumeId!.isNotEmpty) {
      success = await ref
          .read(resumeNotifierProvider.notifier)
          .updateResume(resume);
    } else {
      success = await ref
          .read(resumeNotifierProvider.notifier)
          .createResume(resume);
    }

    if (!mounted) return;

    if (success) {
      // Get the resume ID from the saved resume (in case it's a new resume)
      final savedResume = ref.read(resumeNotifierProvider).currentResume;
      final resumeIdToShow = savedResume?.id ?? widget.resumeId;

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResumePreviewPage(resumeId: resumeIdToShow),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.resumeId != null
                  ? 'Resume updated successfully!'
                  : 'Resume saved successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(resumeNotifierProvider).error ?? 'Failed to save resume',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _quickBuildFromProfile() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to build a resume'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user has minimum required data
    if (user.displayName == null || user.displayName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete your profile first. Go to Profile tab to add your details.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create resume from profile data
    final personalInfo = PersonalInfoEntity(
      fullName: user.displayName ?? '',
      email: user.email,
      phone: user.phone,
      location: user.location,
      linkedInUrl: user.linkedInUrl,
      portfolioUrl: user.portfolioUrl,
      githubUrl: user.githubUrl,
    );

    final resume = ResumeEntity(
      id: '',
      userId: user.id,
      title: '${user.displayName ?? 'My'} Resume',
      personalInfo: personalInfo,
      summary: user.summary,
      education: user.education,
      experience: user.experience,
      skills: user.skills,
      projects: user.projects,
      certifications: user.certifications,
      theme: widget.templateId ?? 'modern',
    );

    // Create the resume
    final success = await ref
        .read(resumeNotifierProvider.notifier)
        .createResume(resume);

    if (!mounted) return;

    if (success) {
      final savedResume = ref.read(resumeNotifierProvider).currentResume;
      final resumeIdToShow = savedResume?.id;

      if (mounted && resumeIdToShow != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResumePreviewPage(resumeId: resumeIdToShow),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume created from your profile!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        final error = ref.read(resumeNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to create resume'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;
    final isNewResume = widget.resumeId == null || widget.resumeId!.isEmpty;
    final hasProfileData =
        user != null &&
        (user.displayName != null && user.displayName!.isNotEmpty);

    // Show loading indicator while loading resume
    if (_isLoadingResume ||
        (widget.resumeId != null &&
            resumeState.isLoading &&
            resumeState.currentResume == null)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.resumeId != null ? 'Edit Resume' : 'Build Resume'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // For new resumes with profile data, show quick build option
    if (isNewResume && hasProfileData) {
      final profileUser =
          user; // Safe because hasProfileData ensures user is not null
      return Scaffold(
        appBar: AppBar(title: const Text('Build Resume')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.description,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Build Resume from Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll use your profile information to create your resume instantly.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _quickBuildFromProfile,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Build Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Profile Summary',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow(
                        'Name',
                        profileUser.displayName ?? 'Not set',
                      ),
                      _buildSummaryRow('Email', profileUser.email),
                      _buildSummaryRow(
                        'Education',
                        '${profileUser.education.length} entries',
                      ),
                      _buildSummaryRow(
                        'Experience',
                        '${profileUser.experience.length} entries',
                      ),
                      _buildSummaryRow(
                        'Skills',
                        '${profileUser.skills.length} skills',
                      ),
                      _buildSummaryRow(
                        'Projects',
                        '${profileUser.projects.length} projects',
                      ),
                      _buildSummaryRow(
                        'Certifications',
                        '${profileUser.certifications.length} certifications',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resumeId != null ? 'Edit Resume' : 'Build Resume'),
        actions: [
          if (resumeState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _handleSave, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (details.stepIndex > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(
                      details.stepIndex < _getSteps().length - 1
                          ? 'Continue'
                          : 'Save & Preview',
                    ),
                  ),
                ],
              ),
            );
          },
          onStepContinue: () {
            // Validate current step before proceeding
            if (_currentStep == 0) {
              // Validate basic info step
              if (!_formKey.currentState!.validate()) {
                return;
              }
              if (_fullNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your full name')),
                );
                return;
              }
            }

            if (_currentStep < _getSteps().length - 1) {
              setState(() => _currentStep++);
            } else {
              // On the last step, save the resume and navigate to preview
              _handleSave();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              // On first step, go back to previous screen
              Navigator.of(context).pop();
            }
          },
          onStepTapped: (stepIndex) {
            // Allow users to tap on any step to navigate to it
            // Only allow going to previous steps or current step (no jumping ahead)
            if (stepIndex <= _currentStep) {
              setState(() {
                _currentStep = stepIndex;
              });
            } else {
              // If trying to jump ahead, validate current step first
              if (_currentStep == 0 &&
                  _fullNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please complete the current step before proceeding',
                    ),
                  ),
                );
              } else {
                setState(() {
                  _currentStep = stepIndex;
                });
              }
            }
          },
          steps: _getSteps(),
        ),
      ),
    );
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text('Basic Info'),
        content: _buildBasicInfoStep(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Education'),
        content: _buildEducationStep(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Experience'),
        content: _buildExperienceStep(),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Skills'),
        content: _buildSkillsStep(),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Projects & Certifications'),
        content: _buildProjectsCertificationsStep(),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _titleController,
            label: 'Resume Title',
            hint: 'e.g., Software Engineer Resume',
            validator: (value) =>
                Validators.required(value, fieldName: 'Resume title'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _fullNameController,
            label: 'Full Name *',
            hint: 'Enter your full name',
            validator: (value) =>
                Validators.required(value, fieldName: 'Full name'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'your.email@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Phone',
            hint: '+1 234 567 8900',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'City, Country',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _linkedInController,
            label: 'LinkedIn URL',
            hint: 'https://linkedin.com/in/yourprofile',
            keyboardType: TextInputType.url,
            validator: Validators.url,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _portfolioController,
            label: 'Portfolio URL',
            hint: 'https://yourportfolio.com',
            keyboardType: TextInputType.url,
            validator: Validators.url,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _githubController,
            label: 'GitHub URL',
            hint: 'https://github.com/username',
            keyboardType: TextInputType.url,
            validator: Validators.url,
          ),
          const SizedBox(height: 24),
          const Text(
            'Professional Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _summaryController,
                  label: 'Summary',
                  hint: 'Write a brief professional summary...',
                  maxLines: 5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _handleGenerateSummary,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate with AI'),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ..._educationList.asMap().entries.map((entry) {
            final index = entry.key;
            final education = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(education.degree),
                subtitle: Text(education.institution),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      setState(() => _educationList.removeAt(index)),
                ),
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () => _showAddEducationDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Education'),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ..._experienceList.asMap().entries.map((entry) {
            final index = entry.key;
            final experience = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(experience.position),
                subtitle: Text(experience.company),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      setState(() => _experienceList.removeAt(index)),
                ),
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () => _showAddExperienceDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Experience'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsStep() {
    final skillController = TextEditingController();
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skillsList.map((skill) {
              return Chip(
                label: Text(skill),
                onDeleted: () => setState(() => _skillsList.remove(skill)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: skillController,
                  label: 'Add Skill',
                  hint: 'Enter a skill',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (skillController.text.trim().isNotEmpty) {
                    setState(() {
                      _skillsList.add(skillController.text.trim());
                      skillController.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsCertificationsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Projects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._projectsList.asMap().entries.map((entry) {
            final index = entry.key;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(_projectsList[index].name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      setState(() => _projectsList.removeAt(index)),
                ),
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () => _showAddProjectDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Project'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Certifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._certificationsList.asMap().entries.map((entry) {
            final index = entry.key;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(_certificationsList[index].name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () =>
                      setState(() => _certificationsList.removeAt(index)),
                ),
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed: () => _showAddCertificationDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Certification'),
          ),
        ],
      ),
    );
  }

  void _showAddEducationDialog() {
    final institutionController = TextEditingController();
    final degreeController = TextEditingController();
    final fieldController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Education'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: institutionController,
                  label: 'Institution *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: degreeController,
                  label: 'Degree *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: fieldController,
                  label: 'Field of Study',
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(
                    startDate != null
                        ? AppDateUtils.DateUtils.formatDate(
                            startDate,
                            format: 'MMM yyyy',
                          )
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setDialogState(() => startDate = date);
                  },
                ),
                ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(
                    endDate != null
                        ? AppDateUtils.DateUtils.formatDate(
                            endDate,
                            format: 'MMM yyyy',
                          )
                        : 'Select date (optional)',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setDialogState(() => endDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (institutionController.text.trim().isEmpty ||
                    degreeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill required fields'),
                    ),
                  );
                  return;
                }
                setState(() {
                  _educationList.add(
                    EducationEntity(
                      institution: institutionController.text.trim(),
                      degree: degreeController.text.trim(),
                      fieldOfStudy: fieldController.text.trim().isEmpty
                          ? null
                          : fieldController.text.trim(),
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExperienceDialog() {
    final companyController = TextEditingController();
    final positionController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    bool isCurrent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: companyController,
                  label: 'Company *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: positionController,
                  label: 'Position *',
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Current Role'),
                  value: isCurrent,
                  onChanged: (value) =>
                      setDialogState(() => isCurrent = value ?? false),
                ),
                if (!isCurrent) ...[
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(
                      startDate != null
                          ? AppDateUtils.DateUtils.formatDate(
                              startDate,
                              format: 'MMM yyyy',
                            )
                          : 'Select date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setDialogState(() => startDate = date);
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(
                      endDate != null
                          ? AppDateUtils.DateUtils.formatDate(
                              endDate,
                              format: 'MMM yyyy',
                            )
                          : 'Select date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setDialogState(() => endDate = date);
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (companyController.text.trim().isEmpty ||
                    positionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill required fields'),
                    ),
                  );
                  return;
                }
                setState(() {
                  _experienceList.add(
                    ExperienceEntity(
                      company: companyController.text.trim(),
                      position: positionController.text.trim(),
                      startDate: startDate,
                      endDate: isCurrent ? null : endDate,
                      isCurrentRole: isCurrent,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProjectDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final techController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                label: 'Project Name *',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: descController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: techController,
                label: 'Technologies',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: urlController,
                label: 'URL',
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              setState(() {
                _projectsList.add(
                  ProjectEntity(
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                    technologies: techController.text.trim().isEmpty
                        ? null
                        : techController.text.trim(),
                    url: urlController.text.trim().isEmpty
                        ? null
                        : urlController.text.trim(),
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCertificationDialog() {
    final nameController = TextEditingController();
    final issuerController = TextEditingController();
    DateTime? issueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Certification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Certification Name *',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: issuerController,
                  label: 'Issuing Organization',
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Issue Date'),
                  subtitle: Text(
                    issueDate != null
                        ? AppDateUtils.DateUtils.formatDate(
                            issueDate,
                            format: 'MMM yyyy',
                          )
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setDialogState(() => issueDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                setState(() {
                  _certificationsList.add(
                    CertificationEntity(
                      name: nameController.text.trim(),
                      issuer: issuerController.text.trim().isEmpty
                          ? null
                          : issuerController.text.trim(),
                      issueDate: issueDate,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
