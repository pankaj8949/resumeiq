import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/resume_model.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../core/utils/validators.dart';
import '../core/utils/date_utils.dart' as AppDateUtils;
import '../widgets/common/custom_text_field.dart';

/// Multi-step profile setup page for collecting user information after login
class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _hasInitialized = false;

  // Step 1: Basic Info + Contact & Summary
  final _step1FormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedInUrlController = TextEditingController();
  final _portfolioUrlController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _summaryController = TextEditingController();

  // Step 2: Professional Details (Optional)
  final List<Education> _educationList = [];
  final List<Experience> _experienceList = [];
  final List<String> _skillsList = [];
  final List<Project> _projectsList = [];
  final List<Certification> _certificationsList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormData();
    });
  }

  void _initializeFormData() {
    if (_hasInitialized) return;

    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _fullNameController.text = user.displayName ?? '';
      _phoneController.text = user.phone ?? '';
      _locationController.text = user.location ?? '';
      _linkedInUrlController.text = user.linkedInUrl ?? '';
      _portfolioUrlController.text = user.portfolioUrl ?? '';
      _githubUrlController.text = user.githubUrl ?? '';
      _summaryController.text = user.summary ?? '';
      
      // Convert entities to models for Step 2
      _educationList.addAll((user.education).map((e) => Education(
        institution: e.institution,
        degree: e.degree,
        fieldOfStudy: e.fieldOfStudy,
        startDate: e.startDate,
        endDate: e.endDate,
        description: e.description,
        gpa: e.gpa,
      )));
      _experienceList.addAll((user.experience).map((e) => Experience(
        company: e.company,
        position: e.position,
        startDate: e.startDate,
        endDate: e.endDate,
        responsibilities: e.responsibilities,
        location: e.location,
        isCurrentRole: e.isCurrentRole,
      )));
      _skillsList.addAll(user.skills);
      _projectsList.addAll((user.projects).map((p) => Project(
        name: p.name,
        description: p.description,
        technologies: p.technologies,
        url: p.url,
        startDate: p.startDate,
        endDate: p.endDate,
      )));
      _certificationsList.addAll((user.certifications).map((c) => Certification(
        name: c.name,
        issuer: c.issuer,
        issueDate: c.issueDate,
        expiryDate: c.expiryDate,
        credentialId: c.credentialId,
        url: c.url,
      )));
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedInUrlController.dispose();
    _portfolioUrlController.dispose();
    _githubUrlController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_currentStep == 0) {
      // Validate Step 1 (Required fields, but validate URLs if provided)
      if (!_step1FormKey.currentState!.validate()) {
        return;
      }
      // Move to next step
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      // Submit profile with all data
      await _submitProfile();
    }
  }

  Future<void> _skipStep() async {
    if (_currentStep == 1) {
      // Skip step 2 and submit with only basic info
      await _submitProfile();
    }
  }

  Future<void> _submitProfile() async {
    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(authNotifierProvider.notifier).updateProfile(
          displayName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          linkedInUrl: _linkedInUrlController.text.trim().isEmpty
              ? null
              : _linkedInUrlController.text.trim(),
          portfolioUrl: _portfolioUrlController.text.trim().isEmpty
              ? null
              : _portfolioUrlController.text.trim(),
          githubUrl: _githubUrlController.text.trim().isEmpty
              ? null
              : _githubUrlController.text.trim(),
          summary: _summaryController.text.trim().isEmpty
              ? null
              : _summaryController.text.trim(),
          education: _educationList.isEmpty ? null : _educationList,
          experience: _experienceList.isEmpty ? null : _experienceList,
          skills: _skillsList.isEmpty ? null : _skillsList,
          projects: _projectsList.isEmpty ? null : _projectsList,
          certifications: _certificationsList.isEmpty ? null : _certificationsList,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } else {
      final error = ref.read(authNotifierProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update profile'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedValue = value.trim();
    final uri = Uri.tryParse(trimmedValue);

    if (uri == null ||
        (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))) {
      return 'Please enter a valid URL (e.g., https://example.com)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // If profile becomes complete, this page will be replaced by AuthWrapper
    if (authState.user != null && _isProfileComplete(authState.user!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: AppTheme.surfaceColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_currentStep + 1} / 2',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentStep == 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : _skipStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppTheme.primaryColor),
                          ),
                          child: const Text(
                            "I'll add these information later",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _currentStep == 1 ? 'Complete Profile' : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_add, size: 64, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s start with some basic information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide the following required information',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            validator: Validators.name,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: Validators.phoneNumber,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location *',
              hintText: 'Enter your city or location',
              prefixIcon: Icon(Icons.location_on),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => Validators.required(value, fieldName: 'Location'),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 32),
          Text(
            'Contact & Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your professional links and summary (optional)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _linkedInUrlController,
            decoration: const InputDecoration(
              labelText: 'LinkedIn URL',
              hintText: 'https://linkedin.com/in/yourprofile',
              prefixIcon: Icon(Icons.business),
            ),
            keyboardType: TextInputType.url,
            validator: _validateUrl,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _portfolioUrlController,
            decoration: const InputDecoration(
              labelText: 'Portfolio URL',
              hintText: 'https://yourportfolio.com',
              prefixIcon: Icon(Icons.public),
            ),
            keyboardType: TextInputType.url,
            validator: _validateUrl,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _githubUrlController,
            decoration: const InputDecoration(
              labelText: 'GitHub URL',
              hintText: 'https://github.com/yourusername',
              prefixIcon: Icon(Icons.code),
            ),
            keyboardType: TextInputType.url,
            validator: _validateUrl,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _summaryController,
            decoration: const InputDecoration(
              labelText: 'Professional Summary',
              hintText: 'Write a brief summary about yourself',
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 24),
          Text(
            '* Required fields',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.work_outline, size: 64, color: AppTheme.primaryColor),
        const SizedBox(height: 16),
        Text(
          'Professional Details',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Add your education, experience, skills, projects, and certifications (optional)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Education Section
        _buildSectionHeader('Education', Icons.school, () => _showAddEducationDialog()),
        const SizedBox(height: 12),
        if (_educationList.isEmpty)
          _buildEmptyState('No education entries yet. Tap "Add Education" to add one.')
        else
          ..._educationList.asMap().entries.map((entry) {
            final index = entry.key;
            final education = entry.value;
            return _buildEducationCard(education, index);
          }),
        const SizedBox(height: 24),

        // Experience Section
        _buildSectionHeader('Experience', Icons.work, () => _showAddExperienceDialog()),
        const SizedBox(height: 12),
        if (_experienceList.isEmpty)
          _buildEmptyState('No experience entries yet. Tap "Add Experience" to add one.')
        else
          ..._experienceList.asMap().entries.map((entry) {
            final index = entry.key;
            final experience = entry.value;
            return _buildExperienceCard(experience, index);
          }),
        const SizedBox(height: 24),

        // Skills Section
        _buildSectionHeader('Skills', Icons.star, () => _showAddSkillDialog()),
        const SizedBox(height: 12),
        if (_skillsList.isEmpty)
          _buildEmptyState('No skills yet. Tap "Add Skill" to add one.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skillsList.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              return Chip(
                label: Text(skill),
                onDeleted: () => setState(() => _skillsList.removeAt(index)),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),

        // Projects Section
        _buildSectionHeader('Projects', Icons.code, () => _showAddProjectDialog()),
        const SizedBox(height: 12),
        if (_projectsList.isEmpty)
          _buildEmptyState('No projects yet. Tap "Add Project" to add one.')
        else
          ..._projectsList.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            return _buildProjectCard(project, index);
          }),
        const SizedBox(height: 24),

        // Certifications Section
        _buildSectionHeader('Certifications', Icons.verified, () => _showAddCertificationDialog()),
        const SizedBox(height: 12),
        if (_certificationsList.isEmpty)
          _buildEmptyState('No certifications yet. Tap "Add Certification" to add one.')
        else
          ..._certificationsList.asMap().entries.map((entry) {
            final index = entry.key;
            final certification = entry.value;
            return _buildCertificationCard(certification, index);
          }),
        const SizedBox(height: 24),

        Text(
          'You can skip this step and add these details later',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEducationCard(Education education, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.school, color: AppTheme.primaryColor),
        title: Text(education.degree),
        subtitle: Text(
          '${education.institution}${education.fieldOfStudy != null ? ' - ${education.fieldOfStudy}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _educationList.removeAt(index)),
        ),
        onTap: () => _showEditEducationDialog(index),
      ),
    );
  }

  Widget _buildExperienceCard(Experience experience, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.work, color: AppTheme.primaryColor),
        title: Text(experience.position),
        subtitle: Text(
          '${experience.company}${experience.location != null ? ' - ${experience.location}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _experienceList.removeAt(index)),
        ),
        onTap: () => _showEditExperienceDialog(index),
      ),
    );
  }

  Widget _buildProjectCard(Project project, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.code, color: AppTheme.primaryColor),
        title: Text(project.name),
        subtitle: Text(project.description ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _projectsList.removeAt(index)),
        ),
        onTap: () => _showEditProjectDialog(index),
      ),
    );
  }

  Widget _buildCertificationCard(Certification certification, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.verified, color: AppTheme.primaryColor),
        title: Text(certification.name),
        subtitle: Text(certification.issuer ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => setState(() => _certificationsList.removeAt(index)),
        ),
        onTap: () => _showEditCertificationDialog(index),
      ),
    );
  }

  // Dialog methods
  void _showAddEducationDialog() => _showEducationDialog();
  void _showEditEducationDialog(int index) => _showEducationDialog(index: index);

  void _showEducationDialog({int? index}) {
    final institutionController = TextEditingController(
      text: index != null ? _educationList[index].institution : '',
    );
    final degreeController = TextEditingController(
      text: index != null ? _educationList[index].degree : '',
    );
    final fieldController = TextEditingController(
      text: index != null ? _educationList[index].fieldOfStudy ?? '' : '',
    );
    DateTime? startDate = index != null ? _educationList[index].startDate : null;
    DateTime? endDate = index != null ? _educationList[index].endDate : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index != null ? 'Edit Education' : 'Add Education'),
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
                        ? AppDateUtils.DateUtils.formatDate(startDate, format: 'MMM yyyy')
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
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
                        ? AppDateUtils.DateUtils.formatDate(endDate, format: 'MMM yyyy')
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
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }
                setState(() {
                  final education = Education(
                    institution: institutionController.text.trim(),
                    degree: degreeController.text.trim(),
                    fieldOfStudy: fieldController.text.trim().isEmpty
                        ? null
                        : fieldController.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                  );
                  if (index != null) {
                    _educationList[index] = education;
                  } else {
                    _educationList.add(education);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(index != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExperienceDialog() => _showExperienceDialog();
  void _showEditExperienceDialog(int index) => _showExperienceDialog(index: index);

  void _showExperienceDialog({int? index}) {
    final companyController = TextEditingController(
      text: index != null ? _experienceList[index].company : '',
    );
    final positionController = TextEditingController(
      text: index != null ? _experienceList[index].position : '',
    );
    final locationController = TextEditingController(
      text: index != null ? _experienceList[index].location ?? '' : '',
    );
    final responsibilitiesController = TextEditingController(
      text: index != null ? _experienceList[index].responsibilities.join('\n') : '',
    );
    DateTime? startDate = index != null ? _experienceList[index].startDate : null;
    DateTime? endDate = index != null ? _experienceList[index].endDate : null;
    bool isCurrent = index != null ? (_experienceList[index].isCurrentRole ?? false) : false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index != null ? 'Edit Experience' : 'Add Experience'),
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
                CustomTextField(
                  controller: locationController,
                  label: 'Location',
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
                          ? AppDateUtils.DateUtils.formatDate(startDate, format: 'MMM yyyy')
                          : 'Select date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
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
                          ? AppDateUtils.DateUtils.formatDate(endDate, format: 'MMM yyyy')
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
                const SizedBox(height: 16),
                CustomTextField(
                  controller: responsibilitiesController,
                  label: 'Responsibilities (one per line)',
                  maxLines: 5,
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
                if (companyController.text.trim().isEmpty ||
                    positionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }
                setState(() {
                  final experience = Experience(
                    company: companyController.text.trim(),
                    position: positionController.text.trim(),
                    location: locationController.text.trim().isEmpty
                        ? null
                        : locationController.text.trim(),
                    startDate: startDate,
                    endDate: isCurrent ? null : endDate,
                    isCurrentRole: isCurrent,
                    responsibilities: responsibilitiesController.text
                        .trim()
                        .split('\n')
                        .where((r) => r.trim().isNotEmpty)
                        .toList(),
                  );
                  if (index != null) {
                    _experienceList[index] = experience;
                  } else {
                    _experienceList.add(experience);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(index != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSkillDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: CustomTextField(
          controller: controller,
          label: 'Skill',
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _skillsList.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog() => _showProjectDialog();
  void _showEditProjectDialog(int index) => _showProjectDialog(index: index);

  void _showProjectDialog({int? index}) {
    final nameController = TextEditingController(
      text: index != null ? _projectsList[index].name : '',
    );
    final descController = TextEditingController(
      text: index != null ? _projectsList[index].description ?? '' : '',
    );
    final techController = TextEditingController(
      text: index != null ? _projectsList[index].technologies ?? '' : '',
    );
    final urlController = TextEditingController(
      text: index != null ? _projectsList[index].url ?? '' : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index != null ? 'Edit Project' : 'Add Project'),
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
                final project = Project(
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
                );
                if (index != null) {
                  _projectsList[index] = project;
                } else {
                  _projectsList.add(project);
                }
              });
              Navigator.pop(context);
            },
            child: Text(index != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCertificationDialog() => _showCertificationDialog();
  void _showEditCertificationDialog(int index) => _showCertificationDialog(index: index);

  void _showCertificationDialog({int? index}) {
    final nameController = TextEditingController(
      text: index != null ? _certificationsList[index].name : '',
    );
    final issuerController = TextEditingController(
      text: index != null ? _certificationsList[index].issuer ?? '' : '',
    );
    DateTime? issueDate = index != null ? _certificationsList[index].issueDate : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index != null ? 'Edit Certification' : 'Add Certification'),
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
                        ? AppDateUtils.DateUtils.formatDate(issueDate, format: 'MMM yyyy')
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: issueDate ?? DateTime.now(),
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
                  final certification = Certification(
                    name: nameController.text.trim(),
                    issuer: issuerController.text.trim().isEmpty
                        ? null
                        : issuerController.text.trim(),
                    issueDate: issueDate,
                  );
                  if (index != null) {
                    _certificationsList[index] = certification;
                  } else {
                    _certificationsList.add(certification);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(index != null ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isProfileComplete(UserModel user) {
    return user.displayName != null &&
        user.displayName!.isNotEmpty &&
        user.phone != null &&
        user.phone!.isNotEmpty &&
        user.location != null &&
        user.location!.isNotEmpty;
  }
}
