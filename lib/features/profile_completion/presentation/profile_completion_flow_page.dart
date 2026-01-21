import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as AppDateUtils;
import '../../../core/utils/validators.dart';
import '../../../models/resume_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_text_field.dart';
import 'profile_step_controller.dart';

class ProfileCompletionFlowPage extends ConsumerWidget {
  const ProfileCompletionFlowPage({super.key});

  Future<bool> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit app?'),
        content: const Text('Do you want to close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(profileStepControllerProvider);

    final stepNumber = controller.stepId.number;
    final total = controller.totalSteps;

    Future<void> handleBack() async {
      if (controller.isSaving) return;

      if (controller.canGoBack) {
        controller.goBack();
        return;
      }

      // On the first step, a system back would otherwise exit the app.
      // Ask for confirmation before closing.
      final shouldExit = await _confirmExit(context);
      if (shouldExit) {
        SystemNavigator.pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF101322),
        appBar: AppBar(
          title: Text(controller.stepId.pageTitle),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF101322),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.isSaving
                ? null
                : () async {
                    if (controller.canGoBack) {
                      controller.goBack();
                      return;
                    }
                    // If user is on first step, going "back" means leaving onboarding.
                    // We sign out to return to Login (current app behavior).
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Go back to login?'),
                        content: const Text(
                          'You will be signed out so you can sign in with another account. Continue?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sign out'),
                          ),
                        ],
                      ),
                    );
                    if (shouldSignOut == true) {
                      await ref.read(authNotifierProvider.notifier).signOut();
                    }
                  },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: stepNumber / total,
                      backgroundColor: AppTheme.surfaceColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Step $stepNumber of $total',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
            ),
            if (controller.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: _StepBody(
                  key: ValueKey(controller.stepId),
                  controller: controller,
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _BottomBar(controller: controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final ProfileStepController controller;

  @override
  Widget build(BuildContext context) {
    final isLast = controller.stepId == ProfileStepId.certifications;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.isSaving || !controller.canGoBack ? null : controller.goBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.25)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: controller.isSaving || !controller.canGoNext
                ? null
                : () async {
                    if (isLast) {
                      await controller.completeFlow();
                      return;
                    }
                    controller.goNext();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.55),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: controller.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLast ? 'Finish' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({super.key, required this.controller});

  final ProfileStepController controller;

  @override
  Widget build(BuildContext context) {
    final step = controller.stepId;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.prompt,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            step.isRequired ? 'Required' : 'Optional',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 18),
          _buildStepContent(context),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (controller.stepId) {
      case ProfileStepId.fullName:
        final err = Validators.name(controller.fullNameController.text);
        return _OneField(
          controller: controller.fullNameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          prefixIcon: Icons.person,
          errorText: err,
        );
      case ProfileStepId.location:
        final err = Validators.required(controller.locationController.text, fieldName: 'Location');
        return _OneField(
          controller: controller.locationController,
          label: 'Location',
          hint: 'City, State / Country',
          prefixIcon: Icons.location_on,
          errorText: err,
        );
      case ProfileStepId.currentDesignation:
        final err = Validators.required(
          controller.currentDesignationController.text,
          fieldName: 'Current Designation',
        );
        return _OneField(
          controller: controller.currentDesignationController,
          label: 'Current Designation',
          hint: 'e.g., Software Engineer',
          prefixIcon: Icons.badge_outlined,
          errorText: err,
        );
      case ProfileStepId.linkedInUrl:
        final err = Validators.optionalUrl(controller.linkedInController.text);
        return _OneField(
          controller: controller.linkedInController,
          label: 'LinkedIn URL',
          hint: 'https://linkedin.com/in/yourprofile',
          prefixIcon: Icons.business,
          keyboardType: TextInputType.url,
          errorText: err,
        );
      case ProfileStepId.portfolioUrl:
        final err = Validators.optionalUrl(controller.portfolioController.text);
        return _OneField(
          controller: controller.portfolioController,
          label: 'Portfolio URL',
          hint: 'https://yourportfolio.com',
          prefixIcon: Icons.public,
          keyboardType: TextInputType.url,
          errorText: err,
        );
      case ProfileStepId.githubUrl:
        final err = Validators.optionalUrl(controller.githubController.text);
        return _OneField(
          controller: controller.githubController,
          label: 'GitHub URL',
          hint: 'https://github.com/yourusername',
          prefixIcon: Icons.code,
          keyboardType: TextInputType.url,
          errorText: err,
        );
      case ProfileStepId.professionalSummary:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller.summaryController,
              maxLines: 6,
              enabled: !controller.isSaving,
              decoration: InputDecoration(
                labelText: 'Professional Summary',
                hintText: 'Briefly describe your professional background...',
                alignLabelWithHint: true,
                suffixIcon: controller.isGeneratingSummary
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: controller.isSaving
                            ? null
                            : () {
                                controller.generateSummaryWithAI();
                              },
                        icon: const Icon(Icons.auto_awesome),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Use the AI button to generate a summary from your designation.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
          ],
        );
      case ProfileStepId.education:
        return _EducationStep(controller: controller);
      case ProfileStepId.experience:
        return _ExperienceStep(controller: controller);
      case ProfileStepId.skills:
        return _SkillsStep(controller: controller);
      case ProfileStepId.projects:
        return _ProjectsStep(controller: controller);
      case ProfileStepId.certifications:
        return _CertificationsStep(controller: controller);
    }
  }
}

class _OneField extends StatelessWidget {
  const _OneField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.errorText,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String? errorText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(prefixIcon),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }
}

class _EducationStep extends StatelessWidget {
  const _EducationStep({required this.controller});
  final ProfileStepController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Education',
          icon: Icons.school,
          onAdd: () => _showEducationDialog(context),
        ),
        const SizedBox(height: 12),
        if (controller.education.isEmpty)
          _EmptyState(message: 'No education entries yet. Tap “Add” to add one.')
        else
          ...controller.education.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.school, color: AppTheme.primaryColor),
                title: Text(e.degree),
                subtitle: Text(
                  '${e.institution}${e.fieldOfStudy != null ? ' - ${e.fieldOfStudy}' : ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => controller.removeEducationAt(index),
                ),
                onTap: () => _showEducationDialog(context, index: index),
              ),
            );
          }),
      ],
    );
  }

  void _showEducationDialog(BuildContext context, {int? index}) {
    final existing = index != null ? controller.education[index] : null;
    final institutionController = TextEditingController(text: existing?.institution ?? '');
    final degreeController = TextEditingController(text: existing?.degree ?? '');
    final fieldController = TextEditingController(text: existing?.fieldOfStudy ?? '');
    final descriptionController = TextEditingController(text: existing?.description ?? '');
    DateTime? startDate = existing?.startDate;
    DateTime? endDate = existing?.endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(index == null ? 'Add Education' : 'Edit Education'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: institutionController, label: 'Institution *'),
                const SizedBox(height: 12),
                CustomTextField(controller: degreeController, label: 'Degree *'),
                const SizedBox(height: 12),
                CustomTextField(controller: fieldController, label: 'Field of Study'),
                const SizedBox(height: 8),
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
                    if (date != null) setState(() => startDate = date);
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
                    if (date != null) setState(() => endDate = date);
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (institutionController.text.trim().isEmpty ||
                    degreeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }
                controller.upsertEducation(
                  Education(
                    institution: institutionController.text.trim(),
                    degree: degreeController.text.trim(),
                    fieldOfStudy: fieldController.text.trim().isEmpty ? null : fieldController.text.trim(),
                    startDate: startDate,
                    endDate: endDate,
                    description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                  ),
                  index: index,
                );
                Navigator.pop(context);
              },
              child: Text(index == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceStep extends StatelessWidget {
  const _ExperienceStep({required this.controller});
  final ProfileStepController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Experience',
          icon: Icons.work,
          onAdd: () => _showExperienceDialog(context),
        ),
        const SizedBox(height: 12),
        if (controller.experience.isEmpty)
          _EmptyState(message: 'No experience entries yet. Tap “Add” to add one.')
        else
          ...controller.experience.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.work, color: AppTheme.primaryColor),
                title: Text(e.position),
                subtitle: Text('${e.company}${e.location != null ? ' - ${e.location}' : ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => controller.removeExperienceAt(index),
                ),
                onTap: () => _showExperienceDialog(context, index: index),
              ),
            );
          }),
      ],
    );
  }

  void _showExperienceDialog(BuildContext context, {int? index}) {
    final existing = index != null ? controller.experience[index] : null;
    final companyController = TextEditingController(text: existing?.company ?? '');
    final positionController = TextEditingController(text: existing?.position ?? '');
    final locationController = TextEditingController(text: existing?.location ?? '');
    final responsibilitiesController =
        TextEditingController(text: (existing?.responsibilities ?? const []).join('\n'));
    final descriptionController = TextEditingController(text: existing?.description ?? '');
    DateTime? startDate = existing?.startDate;
    DateTime? endDate = existing?.endDate;
    bool isCurrent = existing?.isCurrentRole ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(index == null ? 'Add Experience' : 'Edit Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: companyController, label: 'Company *'),
                const SizedBox(height: 12),
                CustomTextField(controller: positionController, label: 'Position *'),
                const SizedBox(height: 12),
                CustomTextField(controller: locationController, label: 'Location'),
                const SizedBox(height: 6),
                CheckboxListTile(
                  title: const Text('Current Role'),
                  value: isCurrent,
                  onChanged: (v) => setState(() => isCurrent = v ?? false),
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
                      if (date != null) setState(() => startDate = date);
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
                      if (date != null) setState(() => endDate = date);
                    },
                  ),
                ],
                const SizedBox(height: 12),
                CustomTextField(
                  controller: responsibilitiesController,
                  label: 'Responsibilities (one per line)',
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (companyController.text.trim().isEmpty ||
                    positionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill required fields')),
                  );
                  return;
                }
                controller.upsertExperience(
                  Experience(
                    company: companyController.text.trim(),
                    position: positionController.text.trim(),
                    location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                    description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                    startDate: startDate,
                    endDate: isCurrent ? null : endDate,
                    isCurrentRole: isCurrent,
                    responsibilities: responsibilitiesController.text
                        .trim()
                        .split('\n')
                        .where((r) => r.trim().isNotEmpty)
                        .toList(),
                  ),
                  index: index,
                );
                Navigator.pop(context);
              },
              child: Text(index == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillsStep extends StatelessWidget {
  const _SkillsStep({required this.controller});
  final ProfileStepController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Skills',
          icon: Icons.star,
          onAdd: () => _showAddSkillDialog(context),
        ),
        const SizedBox(height: 12),
        if (controller.skills.isEmpty)
          _EmptyState(message: 'No skills yet. Tap “Add” to add one.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.skills.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;
              return Chip(
                label: Text(s),
                onDeleted: () => controller.removeSkillAt(idx),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: CustomTextField(controller: c, label: 'Skill', autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.addSkill(c.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ProjectsStep extends StatelessWidget {
  const _ProjectsStep({required this.controller});
  final ProfileStepController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Projects',
          icon: Icons.code,
          onAdd: () => _showProjectDialog(context),
        ),
        const SizedBox(height: 12),
        if (controller.projects.isEmpty)
          _EmptyState(message: 'No projects yet. Tap “Add” to add one.')
        else
          ...controller.projects.asMap().entries.map((entry) {
            final idx = entry.key;
            final p = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.code, color: AppTheme.primaryColor),
                title: Text(p.name),
                subtitle: Text(p.description ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => controller.removeProjectAt(idx),
                ),
                onTap: () => _showProjectDialog(context, index: idx),
              ),
            );
          }),
      ],
    );
  }

  void _showProjectDialog(BuildContext context, {int? index}) {
    final existing = index != null ? controller.projects[index] : null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    final techController = TextEditingController(text: existing?.technologies ?? '');
    final urlController = TextEditingController(text: existing?.url ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add Project' : 'Edit Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: nameController, label: 'Project Name *'),
              const SizedBox(height: 12),
              CustomTextField(controller: descController, label: 'Description', maxLines: 3),
              const SizedBox(height: 12),
              CustomTextField(controller: techController, label: 'Technologies'),
              const SizedBox(height: 12),
              CustomTextField(controller: urlController, label: 'URL', keyboardType: TextInputType.url),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              controller.upsertProject(
                Project(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  technologies: techController.text.trim().isEmpty ? null : techController.text.trim(),
                  url: urlController.text.trim().isEmpty ? null : urlController.text.trim(),
                ),
                index: index,
              );
              Navigator.pop(context);
            },
            child: Text(index == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}

class _CertificationsStep extends StatelessWidget {
  const _CertificationsStep({required this.controller});
  final ProfileStepController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Certifications',
          icon: Icons.verified,
          onAdd: () => _showCertificationDialog(context),
        ),
        const SizedBox(height: 12),
        if (controller.certifications.isEmpty)
          _EmptyState(message: 'No certifications yet. Tap “Add” to add one.')
        else
          ...controller.certifications.asMap().entries.map((entry) {
            final idx = entry.key;
            final c = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.verified, color: AppTheme.primaryColor),
                title: Text(c.name),
                subtitle: Text(c.issuer ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => controller.removeCertificationAt(idx),
                ),
                onTap: () => _showCertificationDialog(context, index: idx),
              ),
            );
          }),
      ],
    );
  }

  void _showCertificationDialog(BuildContext context, {int? index}) {
    final existing = index != null ? controller.certifications[index] : null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final issuerController = TextEditingController(text: existing?.issuer ?? '');
    DateTime? issueDate = existing?.issueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(index == null ? 'Add Certification' : 'Edit Certification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(controller: nameController, label: 'Certification Name *'),
                const SizedBox(height: 12),
                CustomTextField(controller: issuerController, label: 'Issuing Organization'),
                const SizedBox(height: 8),
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
                    if (date != null) setState(() => issueDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                controller.upsertCertification(
                  Certification(
                    name: nameController.text.trim(),
                    issuer: issuerController.text.trim().isEmpty ? null : issuerController.text.trim(),
                    issueDate: issueDate,
                  ),
                  index: index,
                );
                Navigator.pop(context);
              },
              child: Text(index == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.onAdd,
  });

  final String title;
  final IconData icon;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

