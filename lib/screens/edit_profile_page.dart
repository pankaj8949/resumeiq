import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../widgets/common/custom_text_field.dart';
import '../core/utils/validators.dart';
import '../core/utils/date_utils.dart' as AppDateUtils;
import '../providers/auth_provider.dart';
import '../models/resume_model.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _currentDesignationController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _portfolioController;
  late final TextEditingController _githubController;
  late final TextEditingController _summaryController;

  final List<Education> _educationList = [];
  final List<Experience> _experienceList = [];
  final List<String> _skillsList = [];
  final List<Project> _projectsList = [];
  final List<Certification> _certificationsList = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _displayNameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _currentDesignationController =
        TextEditingController(text: user?.currentDesignation ?? '');
    _linkedInController = TextEditingController(text: user?.linkedInUrl ?? '');
    _portfolioController = TextEditingController(text: user?.portfolioUrl ?? '');
    _githubController = TextEditingController(text: user?.githubUrl ?? '');
    _summaryController = TextEditingController(text: user?.summary ?? '');
    
    // Convert entities to models
    _educationList.addAll((user?.education ?? []).map((e) => Education(
      institution: e.institution,
      degree: e.degree,
      fieldOfStudy: e.fieldOfStudy,
      startDate: e.startDate,
      endDate: e.endDate,
      description: e.description,
      gpa: e.gpa,
    )));
    _experienceList.addAll((user?.experience ?? []).map((e) => Experience(
      company: e.company,
      position: e.position,
      startDate: e.startDate,
      endDate: e.endDate,
      responsibilities: e.responsibilities,
      location: e.location,
      isCurrentRole: e.isCurrentRole,
    )));
    _skillsList.addAll(user?.skills ?? []);
    _projectsList.addAll((user?.projects ?? []).map((p) => Project(
      name: p.name,
      description: p.description,
      technologies: p.technologies,
      url: p.url,
      startDate: p.startDate,
      endDate: p.endDate,
    )));
    _certificationsList.addAll((user?.certifications ?? []).map((c) => Certification(
      name: c.name,
      issuer: c.issuer,
      issueDate: c.issueDate,
      expiryDate: c.expiryDate,
      credentialId: c.credentialId,
      url: c.url,
    )));
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _currentDesignationController.dispose();
    _linkedInController.dispose();
    _portfolioController.dispose();
    _githubController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ref.read(authNotifierProvider.notifier).updateProfile(
          displayName: _displayNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          currentDesignation: _currentDesignationController.text.trim().isEmpty
              ? null
              : _currentDesignationController.text.trim(),
          linkedInUrl: _linkedInController.text.trim().isEmpty
              ? null
              : _linkedInController.text.trim(),
          portfolioUrl: _portfolioController.text.trim().isEmpty
              ? null
              : _portfolioController.text.trim(),
          githubUrl: _githubController.text.trim().isEmpty
              ? null
              : _githubController.text.trim(),
          summary: _summaryController.text.trim().isEmpty
              ? null
              : _summaryController.text.trim(),
          education: _educationList,
          experience: _experienceList,
          skills: _skillsList,
          projects: _projectsList,
          certifications: _certificationsList,
        );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        final error = ref.read(authNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update profile'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          bottom: TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: 'Basic Info'),
              Tab(text: 'Education'),
              Tab(text: 'Experience'),
              Tab(text: 'Skills'),
              Tab(text: 'Projects & Certifications'),
            ],
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              _buildBasicInfoTab(),
              _buildEducationTab(),
              _buildExperienceTab(),
              _buildSkillsTab(),
              _buildProjectsCertificationsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _displayNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: const Icon(Icons.person),
            validator: Validators.name,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            validator: Validators.optionalPhone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'Enter your location',
            prefixIcon: const Icon(Icons.location_on),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _currentDesignationController,
            label: 'Current Designation',
            hint: 'e.g., Software Engineer',
            prefixIcon: const Icon(Icons.badge_outlined),
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _linkedInController,
            label: 'LinkedIn URL',
            hint: 'https://linkedin.com/in/yourprofile',
            prefixIcon: const Icon(Icons.business),
            keyboardType: TextInputType.url,
            validator: Validators.optionalUrl,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _portfolioController,
            label: 'Portfolio URL',
            hint: 'https://yourportfolio.com',
            prefixIcon: const Icon(Icons.public),
            keyboardType: TextInputType.url,
            validator: Validators.optionalUrl,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _githubController,
            label: 'GitHub URL',
            hint: 'https://github.com/yourusername',
            prefixIcon: const Icon(Icons.code),
            keyboardType: TextInputType.url,
            validator: Validators.optionalUrl,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _summaryController,
            label: 'Professional Summary',
            hint: 'Write a brief summary about yourself',
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildEducationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Education',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: _showAddEducationDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Education'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_educationList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No education entries yet. Tap "Add Education" to add one.'),
              ),
            )
          else
            ..._educationList.asMap().entries.map((entry) {
              final index = entry.key;
              final education = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(education.degree),
                  subtitle: Text('${education.institution}${education.fieldOfStudy != null ? ' - ${education.fieldOfStudy}' : ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => setState(() => _educationList.removeAt(index)),
                  ),
                  onTap: () => _showEditEducationDialog(index),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildExperienceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Experience',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: _showAddExperienceDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Experience'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_experienceList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No experience entries yet. Tap "Add Experience" to add one.'),
              ),
            )
          else
            ..._experienceList.asMap().entries.map((entry) {
              final index = entry.key;
              final experience = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(experience.position),
                  subtitle: Text('${experience.company}${experience.location != null ? ' - ${experience.location}' : ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => setState(() => _experienceList.removeAt(index)),
                  ),
                  onTap: () => _showEditExperienceDialog(index),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Skills',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skillsList.map((skill) {
              return Chip(
                label: Text(skill),
                onDeleted: () {
                  setState(() {
                    _skillsList.remove(skill);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddSkillDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Skill'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsCertificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _showAddProjectDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Project'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_projectsList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No projects yet. Tap "Add Project" to add one.'),
              ),
            )
          else
            ..._projectsList.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(project.name),
                  subtitle: Text(project.description ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => setState(() => _projectsList.removeAt(index)),
                  ),
                  onTap: () => _showEditProjectDialog(index),
                ),
              );
            }),
          const SizedBox(height: 32),
          Text(
            'Certifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _showAddCertificationDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Certification'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_certificationsList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No certifications yet. Tap "Add Certification" to add one.'),
              ),
            )
          else
            ..._certificationsList.asMap().entries.map((entry) {
              final index = entry.key;
              final certification = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(certification.name),
                  subtitle: Text(certification.issuer ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => setState(() => _certificationsList.removeAt(index)),
                  ),
                  onTap: () => _showEditCertificationDialog(index),
                ),
              );
            }),
        ],
      ),
    );
  }

  // Dialog methods - similar to resume builder page
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
    final descriptionController = TextEditingController(
      text: index != null ? _educationList[index].description ?? '' : '',
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
                const SizedBox(height: 16),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
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
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
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
    final descriptionController = TextEditingController(
      text: index != null ? _experienceList[index].description ?? '' : '',
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
                const SizedBox(height: 16),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
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
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
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
}
