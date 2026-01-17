import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/validators.dart';
import '../../../models/resume_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firebase_ai_service.dart';
import 'complete_profile_model.dart';

/// Step IDs in the exact order required by the spec.
enum ProfileStepId {
  fullName,
  location,
  currentDesignation,
  linkedInUrl,
  portfolioUrl,
  githubUrl,
  professionalSummary,
  education,
  experience,
  skills,
  projects,
  certifications,
}

extension ProfileStepIdX on ProfileStepId {
  int get number => index + 1;

  bool get isRequired =>
      this == ProfileStepId.fullName ||
      this == ProfileStepId.location ||
      this == ProfileStepId.currentDesignation;

  String get pageTitle {
    if (number <= 7) return 'Complete Your Profile';
    if (number <= 12) return 'Professional Details';
    return 'Professional Details';
  }

  String get prompt {
    switch (this) {
      case ProfileStepId.fullName:
        return 'What’s your full name?';
      case ProfileStepId.location:
        return 'Where are you based?';
      case ProfileStepId.currentDesignation:
        return 'What’s your current designation?';
      case ProfileStepId.linkedInUrl:
        return 'Add your LinkedIn URL (optional)';
      case ProfileStepId.portfolioUrl:
        return 'Add your Portfolio URL (optional)';
      case ProfileStepId.githubUrl:
        return 'Add your GitHub URL (optional)';
      case ProfileStepId.professionalSummary:
        return 'Write a professional summary (optional)';
      case ProfileStepId.education:
        return 'Add your education (optional)';
      case ProfileStepId.experience:
        return 'Add your experience (optional)';
      case ProfileStepId.skills:
        return 'Add your skills (optional)';
      case ProfileStepId.projects:
        return 'Add your projects (optional)';
      case ProfileStepId.certifications:
        return 'Add your certifications (optional)';
    }
  }
}

/// Single controller managing all steps, validation, and incremental persistence.
class ProfileStepController extends ChangeNotifier {
  ProfileStepController(this._ref) {
    _hydrateFromUser(_ref.read(authNotifierProvider).user);
    // Recompute validation / button enabled state as the user types.
    fullNameController.addListener(notifyListeners);
    locationController.addListener(notifyListeners);
    currentDesignationController.addListener(notifyListeners);
    linkedInController.addListener(notifyListeners);
    portfolioController.addListener(notifyListeners);
    githubController.addListener(notifyListeners);
    summaryController.addListener(notifyListeners);
  }

  final Ref _ref;
  final FirebaseAIService _aiService = FirebaseAIService();

  int _stepIndex = 0;
  bool _isSaving = false;
  bool _isGeneratingSummary = false;
  String? _error;

  // Track whether list steps were touched so we can intentionally persist clears.
  bool _educationTouched = false;
  bool _experienceTouched = false;
  bool _skillsTouched = false;
  bool _projectsTouched = false;
  bool _certificationsTouched = false;

  CompleteProfileModel _model = const CompleteProfileModel();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController currentDesignationController =
      TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController portfolioController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();

  int get stepIndex => _stepIndex;
  int get totalSteps => ProfileStepId.values.length;
  ProfileStepId get stepId => ProfileStepId.values[_stepIndex];

  bool get isSaving => _isSaving;
  bool get isGeneratingSummary => _isGeneratingSummary;
  String? get error => _error;

  CompleteProfileModel get model => _model;

  // Collections are edited via controller methods to keep UI "dumb".
  List<Education> get education => List.unmodifiable(_model.education);
  List<Experience> get experience => List.unmodifiable(_model.experience);
  List<String> get skills => List.unmodifiable(_model.skills);
  List<Project> get projects => List.unmodifiable(_model.projects);
  List<Certification> get certifications => List.unmodifiable(_model.certifications);

  void _hydrateFromUser(UserModel? user) {
    if (user == null) return;

    fullNameController.text = user.displayName ?? '';
    locationController.text = user.location ?? '';
    currentDesignationController.text = user.currentDesignation ?? '';
    linkedInController.text = user.linkedInUrl ?? '';
    portfolioController.text = user.portfolioUrl ?? '';
    githubController.text = user.githubUrl ?? '';
    summaryController.text = user.summary ?? '';

    _model = _model.copyWith(
      fullName: fullNameController.text,
      location: locationController.text,
      currentDesignation: currentDesignationController.text,
      linkedInUrl: user.linkedInUrl,
      portfolioUrl: user.portfolioUrl,
      githubUrl: user.githubUrl,
      summary: user.summary,
      education: (user.education)
          .map(
            (e) => Education(
              institution: e.institution,
              degree: e.degree,
              fieldOfStudy: e.fieldOfStudy,
              startDate: e.startDate,
              endDate: e.endDate,
              description: e.description,
              gpa: e.gpa,
            ),
          )
          .toList(),
      experience: (user.experience)
          .map(
            (e) => Experience(
              company: e.company,
              position: e.position,
              startDate: e.startDate,
              endDate: e.endDate,
              responsibilities: e.responsibilities,
              location: e.location,
              isCurrentRole: e.isCurrentRole,
              description: e.description,
            ),
          )
          .toList(),
      skills: List<String>.from(user.skills),
      projects: (user.projects)
          .map(
            (p) => Project(
              name: p.name,
              description: p.description,
              technologies: p.technologies,
              url: p.url,
              startDate: p.startDate,
              endDate: p.endDate,
            ),
          )
          .toList(),
      certifications: (user.certifications)
          .map(
            (c) => Certification(
              name: c.name,
              issuer: c.issuer,
              issueDate: c.issueDate,
              expiryDate: c.expiryDate,
              credentialId: c.credentialId,
              url: c.url,
            ),
          )
          .toList(),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get canGoBack => _stepIndex > 0;

  bool get canGoNext {
    final id = stepId;
    switch (id) {
      case ProfileStepId.fullName:
        return Validators.name(fullNameController.text) == null;
      case ProfileStepId.location:
        return Validators.required(locationController.text, fieldName: 'Location') == null;
      case ProfileStepId.currentDesignation:
        return Validators.required(
              currentDesignationController.text,
              fieldName: 'Current Designation',
            ) ==
            null;
      case ProfileStepId.linkedInUrl:
        return Validators.optionalUrl(linkedInController.text) == null;
      case ProfileStepId.portfolioUrl:
        return Validators.optionalUrl(portfolioController.text) == null;
      case ProfileStepId.githubUrl:
        return Validators.optionalUrl(githubController.text) == null;
      case ProfileStepId.professionalSummary:
        // Optional: allow empty; no strict validation beyond being a string.
        return true;
      case ProfileStepId.education:
      case ProfileStepId.experience:
      case ProfileStepId.skills:
      case ProfileStepId.projects:
      case ProfileStepId.certifications:
        // Optional steps must not block Next.
        return true;
    }
  }

  void goBack() {
    if (!canGoBack) return;
    _stepIndex -= 1;
    _error = null;
    notifyListeners();
  }

  Future<void> goNext() async {
    if (!canGoNext || _isSaving) return;
    _error = null;
    notifyListeners();

    await _persistCurrentStep();

    if (_error != null) return;
    if (_stepIndex >= totalSteps - 1) return;

    _stepIndex += 1;
    notifyListeners();
  }

  Future<void> _persistCurrentStep() async {
    final notifier = _ref.read(authNotifierProvider.notifier);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _error = 'You must be signed in.';
      notifyListeners();
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final id = stepId;

      bool ok = true;
      switch (id) {
        case ProfileStepId.fullName:
          final fullName = fullNameController.text.trim();
          _model = _model.copyWith(fullName: fullName);
          ok = await notifier.updateProfile(displayName: fullName);
          break;

        case ProfileStepId.location:
          final location = locationController.text.trim();
          _model = _model.copyWith(location: location);
          ok = await notifier.updateProfile(location: location);
          break;

        case ProfileStepId.currentDesignation:
          final designation = currentDesignationController.text.trim();
          _model = _model.copyWith(currentDesignation: designation);
          ok = await notifier.updateProfile(currentDesignation: designation);
          break;

        case ProfileStepId.linkedInUrl:
          final v = linkedInController.text.trim();
          if (v.isNotEmpty && Validators.optionalUrl(v) == null) {
            _model = _model.copyWith(linkedInUrl: v);
            ok = await notifier.updateProfile(linkedInUrl: v);
          }
          break;

        case ProfileStepId.portfolioUrl:
          final v = portfolioController.text.trim();
          if (v.isNotEmpty && Validators.optionalUrl(v) == null) {
            _model = _model.copyWith(portfolioUrl: v);
            ok = await notifier.updateProfile(portfolioUrl: v);
          }
          break;

        case ProfileStepId.githubUrl:
          final v = githubController.text.trim();
          if (v.isNotEmpty && Validators.optionalUrl(v) == null) {
            _model = _model.copyWith(githubUrl: v);
            ok = await notifier.updateProfile(githubUrl: v);
          }
          break;

        case ProfileStepId.professionalSummary:
          final v = summaryController.text.trim();
          if (v.isNotEmpty) {
            _model = _model.copyWith(summary: v);
            ok = await notifier.updateProfile(summary: v);
          }
          break;

        case ProfileStepId.education:
          _model = _model.copyWith(education: List<Education>.from(_model.education));
          if (_educationTouched) {
            ok = await notifier.updateProfile(education: List<Education>.from(_model.education));
          }
          break;

        case ProfileStepId.experience:
          _model = _model.copyWith(experience: List<Experience>.from(_model.experience));
          if (_experienceTouched) {
            ok = await notifier.updateProfile(experience: List<Experience>.from(_model.experience));
          }
          break;

        case ProfileStepId.skills:
          _model = _model.copyWith(skills: List<String>.from(_model.skills));
          if (_skillsTouched) {
            ok = await notifier.updateProfile(skills: List<String>.from(_model.skills));
          }
          break;

        case ProfileStepId.projects:
          _model = _model.copyWith(projects: List<Project>.from(_model.projects));
          if (_projectsTouched) {
            ok = await notifier.updateProfile(projects: List<Project>.from(_model.projects));
          }
          break;

        case ProfileStepId.certifications:
          _model = _model.copyWith(
            certifications: List<Certification>.from(_model.certifications),
          );
          if (_certificationsTouched) {
            ok = await notifier.updateProfile(
              certifications: List<Certification>.from(_model.certifications),
            );
          }
          break;

      }

      if (!ok) {
        _error = _ref.read(authNotifierProvider).error ?? 'Failed to save.';
      }
    } catch (e) {
      _error = 'Failed to save.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Step 7 AI assist (already exists in the app).
  Future<void> generateSummaryWithAI() async {
    if (_isSaving || _isGeneratingSummary) return;
    _error = null;
    notifyListeners();

    final designation = currentDesignationController.text.trim();
    if (designation.isEmpty) {
      _error = 'Please enter your current designation first.';
      notifyListeners();
      return;
    }

    _isGeneratingSummary = true;
    notifyListeners();
    try {
      final prompt = '''
You are an expert resume writer.

Write a professional resume summary for the following role:
Current designation: "$designation"

Requirements:
- 2 to 3 sentences
- 50 to 80 words
- Professional tone, ATS-friendly keywords
- No bullet points, no emojis, no markdown, no quotes
- Do not invent specific numbers/metrics

Return only the summary text.
''';

      final generated = await _aiService.generateText(
        prompt: prompt,
        temperature: 0.6,
        maxOutputTokens: 220,
      );

      var text = generated.trim();
      if (text.startsWith('```')) {
        text = text.replaceAll(RegExp(r'^```[a-zA-Z]*\s*'), '');
        text = text.replaceAll(RegExp(r'```$'), '');
        text = text.trim();
      }
      if ((text.startsWith('"') && text.endsWith('"')) ||
          (text.startsWith("'") && text.endsWith("'"))) {
        text = text.substring(1, text.length - 1).trim();
      }

      summaryController.text = text;
      summaryController.selection = TextSelection.fromPosition(
        TextPosition(offset: summaryController.text.length),
      );
      _model = _model.copyWith(summary: text);
    } catch (e) {
      _error = 'AI summary failed.';
    } finally {
      _isGeneratingSummary = false;
      notifyListeners();
    }
  }

  // ---- Education / Experience / Skills / Projects / Certifications mutations ----

  void upsertEducation(Education value, {int? index}) {
    final list = List<Education>.from(_model.education);
    if (index != null && index >= 0 && index < list.length) {
      list[index] = value;
    } else {
      list.add(value);
    }
    _educationTouched = true;
    _model = _model.copyWith(education: list);
    notifyListeners();
  }

  void removeEducationAt(int index) {
    final list = List<Education>.from(_model.education);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _educationTouched = true;
    _model = _model.copyWith(education: list);
    notifyListeners();
  }

  void upsertExperience(Experience value, {int? index}) {
    final list = List<Experience>.from(_model.experience);
    if (index != null && index >= 0 && index < list.length) {
      list[index] = value;
    } else {
      list.add(value);
    }
    _experienceTouched = true;
    _model = _model.copyWith(experience: list);
    notifyListeners();
  }

  void removeExperienceAt(int index) {
    final list = List<Experience>.from(_model.experience);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _experienceTouched = true;
    _model = _model.copyWith(experience: list);
    notifyListeners();
  }

  void addSkill(String skill) {
    final s = skill.trim();
    if (s.isEmpty) return;
    final list = List<String>.from(_model.skills);
    list.add(s);
    _skillsTouched = true;
    _model = _model.copyWith(skills: list);
    notifyListeners();
  }

  void removeSkillAt(int index) {
    final list = List<String>.from(_model.skills);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _skillsTouched = true;
    _model = _model.copyWith(skills: list);
    notifyListeners();
  }

  void upsertProject(Project value, {int? index}) {
    final list = List<Project>.from(_model.projects);
    if (index != null && index >= 0 && index < list.length) {
      list[index] = value;
    } else {
      list.add(value);
    }
    _projectsTouched = true;
    _model = _model.copyWith(projects: list);
    notifyListeners();
  }

  void removeProjectAt(int index) {
    final list = List<Project>.from(_model.projects);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _projectsTouched = true;
    _model = _model.copyWith(projects: list);
    notifyListeners();
  }

  void upsertCertification(Certification value, {int? index}) {
    final list = List<Certification>.from(_model.certifications);
    if (index != null && index >= 0 && index < list.length) {
      list[index] = value;
    } else {
      list.add(value);
    }
    _certificationsTouched = true;
    _model = _model.copyWith(certifications: list);
    notifyListeners();
  }

  void removeCertificationAt(int index) {
    final list = List<Certification>.from(_model.certifications);
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _certificationsTouched = true;
    _model = _model.copyWith(certifications: list);
    notifyListeners();
  }

  // ---- Final step: image upload (optional) ----

  Future<bool> completeFlow() async {
    if (_isSaving) return false;
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final ok = await _ref
          .read(authNotifierProvider.notifier)
          .updateProfile(profileCompletionDone: true);
      if (!ok) {
        _error = _ref.read(authNotifierProvider).error ?? 'Failed to complete.';
      }
      return ok;
    } catch (_) {
      _error = 'Failed to complete.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.removeListener(notifyListeners);
    locationController.removeListener(notifyListeners);
    currentDesignationController.removeListener(notifyListeners);
    linkedInController.removeListener(notifyListeners);
    portfolioController.removeListener(notifyListeners);
    githubController.removeListener(notifyListeners);
    summaryController.removeListener(notifyListeners);
    fullNameController.dispose();
    locationController.dispose();
    currentDesignationController.dispose();
    linkedInController.dispose();
    portfolioController.dispose();
    githubController.dispose();
    summaryController.dispose();
    super.dispose();
  }
}

/// Riverpod provider for the step controller.
final profileStepControllerProvider =
    ChangeNotifierProvider<ProfileStepController>((ref) {
  return ProfileStepController(ref);
});

