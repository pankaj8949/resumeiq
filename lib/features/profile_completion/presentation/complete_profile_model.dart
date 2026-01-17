import '../../../models/resume_model.dart';

/// Single model holding all data for the step-based profile completion flow.
///
/// Note: This is intentionally independent from Firestore / entities to keep the
/// controller and UI clean and testable. Persistence is handled by the controller
/// via `AuthNotifier.updateProfile(...)`.
class CompleteProfileModel {
  const CompleteProfileModel({
    this.fullName = '',
    this.location = '',
    this.currentDesignation = '',
    this.linkedInUrl,
    this.portfolioUrl,
    this.githubUrl,
    this.summary,
    this.education = const <Education>[],
    this.experience = const <Experience>[],
    this.skills = const <String>[],
    this.projects = const <Project>[],
    this.certifications = const <Certification>[],
  });

  final String fullName;
  final String location;
  final String currentDesignation;

  final String? linkedInUrl;
  final String? portfolioUrl;
  final String? githubUrl;
  final String? summary;

  final List<Education> education;
  final List<Experience> experience;
  final List<String> skills;
  final List<Project> projects;
  final List<Certification> certifications;

  CompleteProfileModel copyWith({
    String? fullName,
    String? location,
    String? currentDesignation,
    String? linkedInUrl,
    bool clearLinkedInUrl = false,
    String? portfolioUrl,
    bool clearPortfolioUrl = false,
    String? githubUrl,
    bool clearGithubUrl = false,
    String? summary,
    bool clearSummary = false,
    List<Education>? education,
    List<Experience>? experience,
    List<String>? skills,
    List<Project>? projects,
    List<Certification>? certifications,
  }) {
    return CompleteProfileModel(
      fullName: fullName ?? this.fullName,
      location: location ?? this.location,
      currentDesignation: currentDesignation ?? this.currentDesignation,
      linkedInUrl: clearLinkedInUrl ? null : (linkedInUrl ?? this.linkedInUrl),
      portfolioUrl:
          clearPortfolioUrl ? null : (portfolioUrl ?? this.portfolioUrl),
      githubUrl: clearGithubUrl ? null : (githubUrl ?? this.githubUrl),
      summary: clearSummary ? null : (summary ?? this.summary),
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
    );
  }
}

