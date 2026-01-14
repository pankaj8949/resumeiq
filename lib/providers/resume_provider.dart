import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resume_model.dart';
import '../features/resume_builder/domain/entities/resume_entity.dart';
import '../features/resume_builder/domain/repositories/resume_repository.dart';
import '../features/resume_builder/domain/usecases/create_resume_usecase.dart';
import '../features/resume_builder/domain/usecases/get_user_resumes_usecase.dart';
import '../features/resume_builder/domain/usecases/get_resume_usecase.dart';
import '../features/resume_builder/domain/usecases/update_resume_usecase.dart';
import '../features/resume_builder/domain/usecases/generate_summary_usecase.dart';
import '../features/resume_builder/domain/usecases/delete_resume_usecase.dart';
import '../features/resume_builder/data/repositories/resume_repository_impl.dart';
import '../features/resume_builder/data/datasources/resume_remote_datasource.dart';
import '../services/firebase_ai_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Resume state
class ResumeState {
  const ResumeState({
    this.resumes = const [],
    this.currentResume,
    this.isLoading = false,
    this.error,
  });

  final List<ResumeModel> resumes;
  final ResumeModel? currentResume;
  final bool isLoading;
  final String? error;

  ResumeState copyWith({
    List<ResumeModel>? resumes,
    ResumeModel? currentResume,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ResumeState(
      resumes: resumes ?? this.resumes,
      currentResume: currentResume ?? this.currentResume,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Resume notifier
class ResumeNotifier extends StateNotifier<ResumeState> {
  ResumeNotifier(
    this._createUseCase,
    this._getResumesUseCase,
    this._getResumeUseCase,
    this._updateResumeUseCase,
    this._generateSummaryUseCase,
    this._deleteResumeUseCase,
  ) : super(const ResumeState());

  final CreateResumeUseCase _createUseCase;
  final GetUserResumesUseCase _getResumesUseCase;
  final GetResumeUseCase _getResumeUseCase;
  final UpdateResumeUseCase _updateResumeUseCase;
  final GenerateSummaryUseCase _generateSummaryUseCase;
  final DeleteResumeUseCase _deleteResumeUseCase;

  // Helper to convert ResumeModel to ResumeEntity
  ResumeEntity _modelToEntity(ResumeModel model) {
    return ResumeEntity(
      id: model.id,
      userId: model.userId,
      title: model.title,
      personalInfo: model.personalInfo != null
          ? PersonalInfoEntity(
              fullName: model.personalInfo!.fullName,
              email: model.personalInfo!.email,
              phone: model.personalInfo!.phone,
              location: model.personalInfo!.location,
              linkedInUrl: model.personalInfo!.linkedInUrl,
              portfolioUrl: model.personalInfo!.portfolioUrl,
              githubUrl: model.personalInfo!.githubUrl,
            )
          : null,
      summary: model.summary,
      education: model.education
          .map((e) => EducationEntity(
                institution: e.institution,
                degree: e.degree,
                fieldOfStudy: e.fieldOfStudy,
                startDate: e.startDate,
                endDate: e.endDate,
                description: e.description,
                gpa: e.gpa,
              ))
          .toList(),
      experience: model.experience
          .map((e) => ExperienceEntity(
                company: e.company,
                position: e.position,
                startDate: e.startDate,
                endDate: e.endDate,
                responsibilities: e.responsibilities,
                location: e.location,
                isCurrentRole: e.isCurrentRole,
                description: e.description,
              ))
          .toList(),
      skills: model.skills,
      projects: model.projects
          .map((p) => ProjectEntity(
                name: p.name,
                description: p.description,
                technologies: p.technologies,
                url: p.url,
                startDate: p.startDate,
                endDate: p.endDate,
              ))
          .toList(),
      certifications: model.certifications
          .map((c) => CertificationEntity(
                name: c.name,
                issuer: c.issuer,
                issueDate: c.issueDate,
                expiryDate: c.expiryDate,
                credentialId: c.credentialId,
                url: c.url,
              ))
          .toList(),
      theme: model.theme,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      score: model.score,
      fileUrl: model.fileUrl,
    );
  }

  // Helper to convert ResumeEntity to ResumeModel
  ResumeModel _entityToModel(ResumeEntity entity) {
    return ResumeModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      personalInfo: entity.personalInfo != null
          ? PersonalInfo(
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
          .map((e) => Education(
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
          .map((e) => Experience(
                company: e.company,
                position: e.position,
                startDate: e.startDate,
                endDate: e.endDate,
                responsibilities: e.responsibilities,
                location: e.location,
                isCurrentRole: e.isCurrentRole,
                description: e.description,
              ))
          .toList(),
      skills: entity.skills,
      projects: entity.projects
          .map((p) => Project(
                name: p.name,
                description: p.description,
                technologies: p.technologies,
                url: p.url,
                startDate: p.startDate,
                endDate: p.endDate,
              ))
          .toList(),
      certifications: entity.certifications
          .map((c) => Certification(
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

  Future<bool> createResume(ResumeModel resume) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final entity = _modelToEntity(resume);
    final result = await _createUseCase(entity);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (created) {
        final model = _entityToModel(created);
        state = state.copyWith(
          isLoading: false,
          resumes: [model, ...state.resumes],
          currentResume: model,
        );
        return true;
      },
    );
  }

  Future<void> loadUserResumes(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getResumesUseCase(userId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (resumes) => state = state.copyWith(
        isLoading: false,
        resumes: resumes.map(_entityToModel).toList(),
      ),
    );
  }

  /// Load a single resume by ID
  Future<ResumeModel?> loadResume(String resumeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getResumeUseCase(resumeId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (resume) {
        final model = _entityToModel(resume);
        state = state.copyWith(isLoading: false, currentResume: model);
        return model;
      },
    );
  }

  /// Update an existing resume
  Future<bool> updateResume(ResumeModel resume) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final entity = _modelToEntity(resume);
    final result = await _updateResumeUseCase(entity);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updated) {
        final model = _entityToModel(updated);
        // Update the resume in the list
        final updatedResumes = state.resumes.map((r) {
          return r.id == model.id ? model : r;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          resumes: updatedResumes,
          currentResume: model,
        );
        return true;
      },
    );
  }

  Future<String?> generateSummary({
    required PersonalInfo personalInfo,
    required List<Experience> experience,
    required List<Education> education,
    required List<String> skills,
  }) async {
    // Convert models to entities for use case
    final personalInfoEntity = PersonalInfoEntity(
      fullName: personalInfo.fullName,
      email: personalInfo.email,
      phone: personalInfo.phone,
      location: personalInfo.location,
      linkedInUrl: personalInfo.linkedInUrl,
      portfolioUrl: personalInfo.portfolioUrl,
      githubUrl: personalInfo.githubUrl,
    );
    final experienceEntities = experience
        .map((e) => ExperienceEntity(
              company: e.company,
              position: e.position,
              startDate: e.startDate,
              endDate: e.endDate,
              responsibilities: e.responsibilities,
              location: e.location,
              isCurrentRole: e.isCurrentRole,
              description: e.description,
            ))
        .toList();
    final educationEntities = education
        .map((e) => EducationEntity(
              institution: e.institution,
              degree: e.degree,
              fieldOfStudy: e.fieldOfStudy,
              startDate: e.startDate,
              endDate: e.endDate,
              description: e.description,
              gpa: e.gpa,
            ))
        .toList();

    final result = await _generateSummaryUseCase(
      personalInfo: personalInfoEntity,
      experience: experienceEntities,
      education: educationEntities,
      skills: skills,
    );
    return result.fold((failure) {
      state = state.copyWith(error: failure.message);
      return null;
    }, (summary) => summary);
  }

  /// Delete a resume
  Future<bool> deleteResume(String resumeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _deleteResumeUseCase(resumeId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        // Remove the deleted resume from the list
        state = state.copyWith(
          isLoading: false,
          resumes: state.resumes.where((r) => r.id != resumeId).toList(),
        );
        return true;
      },
    );
  }
}

/// Providers
final firebaseAIServiceProvider = Provider<FirebaseAIService?>((ref) {
  // Firebase AI service uses Firebase authentication
  try {
    return FirebaseAIService();
  } catch (e) {
    // Log the error but don't crash the app
    // The service will be null if Firebase is not configured
    // Features that require AI will show appropriate error messages
    return null;
  }
});

final resumeRemoteDataSourceProvider = Provider<ResumeRemoteDataSource>((ref) {
  return ResumeRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  return ResumeRepositoryImpl(
    remoteDataSource: ref.watch(resumeRemoteDataSourceProvider),
    firebaseAIService: ref.watch(firebaseAIServiceProvider),
  );
});

final createResumeUseCaseProvider = Provider<CreateResumeUseCase>((ref) {
  return CreateResumeUseCase(ref.watch(resumeRepositoryProvider));
});

final getUserResumesUseCaseProvider = Provider<GetUserResumesUseCase>((ref) {
  return GetUserResumesUseCase(ref.watch(resumeRepositoryProvider));
});

final getResumeUseCaseProvider = Provider<GetResumeUseCase>((ref) {
  return GetResumeUseCase(ref.watch(resumeRepositoryProvider));
});

final updateResumeUseCaseProvider = Provider<UpdateResumeUseCase>((ref) {
  return UpdateResumeUseCase(ref.watch(resumeRepositoryProvider));
});

final generateSummaryUseCaseProvider = Provider<GenerateSummaryUseCase>((ref) {
  return GenerateSummaryUseCase(ref.watch(resumeRepositoryProvider));
});

final deleteResumeUseCaseProvider = Provider<DeleteResumeUseCase>((ref) {
  return DeleteResumeUseCase(ref.watch(resumeRepositoryProvider));
});

final resumeNotifierProvider =
    StateNotifierProvider<ResumeNotifier, ResumeState>((ref) {
      return ResumeNotifier(
        ref.watch(createResumeUseCaseProvider),
        ref.watch(getUserResumesUseCaseProvider),
        ref.watch(getResumeUseCaseProvider),
        ref.watch(updateResumeUseCaseProvider),
        ref.watch(generateSummaryUseCaseProvider),
        ref.watch(deleteResumeUseCaseProvider),
      );
    });
