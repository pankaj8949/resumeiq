import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/resume_entity.dart';
import '../../domain/repositories/resume_repository.dart';
import '../../domain/usecases/create_resume_usecase.dart';
import '../../domain/usecases/get_user_resumes_usecase.dart';
import '../../domain/usecases/get_resume_usecase.dart';
import '../../domain/usecases/update_resume_usecase.dart';
import '../../domain/usecases/generate_summary_usecase.dart';
import '../../domain/usecases/delete_resume_usecase.dart';
import '../../data/repositories/resume_repository_impl.dart';
import '../../data/datasources/resume_remote_datasource.dart';
import '../../../../shared/services/gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Resume state
class ResumeState {
  const ResumeState({
    this.resumes = const [],
    this.currentResume,
    this.isLoading = false,
    this.error,
  });

  final List<ResumeEntity> resumes;
  final ResumeEntity? currentResume;
  final bool isLoading;
  final String? error;

  ResumeState copyWith({
    List<ResumeEntity>? resumes,
    ResumeEntity? currentResume,
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

  Future<bool> createResume(ResumeEntity resume) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _createUseCase(resume);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (created) {
        state = state.copyWith(
          isLoading: false,
          resumes: [created, ...state.resumes],
          currentResume: created,
        );
        return true;
      },
    );
  }

  Future<void> loadUserResumes(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getResumesUseCase(userId);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (resumes) => state = state.copyWith(isLoading: false, resumes: resumes),
    );
  }

  /// Load a single resume by ID
  Future<ResumeEntity?> loadResume(String resumeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getResumeUseCase(resumeId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (resume) {
        state = state.copyWith(
          isLoading: false,
          currentResume: resume,
        );
        return resume;
      },
    );
  }

  /// Update an existing resume
  Future<bool> updateResume(ResumeEntity resume) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _updateResumeUseCase(resume);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updated) {
        // Update the resume in the list
        final updatedResumes = state.resumes.map((r) {
          return r.id == updated.id ? updated : r;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          resumes: updatedResumes,
          currentResume: updated,
        );
        return true;
      },
    );
  }

  Future<String?> generateSummary({
    required PersonalInfoEntity personalInfo,
    required List<ExperienceEntity> experience,
    required List<EducationEntity> education,
    required List<String> skills,
  }) async {
    final result = await _generateSummaryUseCase(
      personalInfo: personalInfo,
      experience: experience,
      education: education,
      skills: skills,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (summary) => summary,
    );
  }

  /// Delete a resume
  Future<bool> deleteResume(String resumeId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _deleteResumeUseCase(resumeId);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
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
final geminiServiceProvider = Provider<GeminiService?>((ref) {
  // API key is handled by GeminiService constructor via GeminiConfig
  try {
    return GeminiService();
  } catch (e) {
    // Log the error but don't crash the app
    // The service will be null if API key is not configured
    // Features that require Gemini will show appropriate error messages
    return null;
  }
});

final resumeRemoteDataSourceProvider = Provider<ResumeRemoteDataSource>((ref) {
  return ResumeRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  return ResumeRepositoryImpl(
    remoteDataSource: ref.watch(resumeRemoteDataSourceProvider),
    geminiService: ref.watch(geminiServiceProvider),
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

final resumeNotifierProvider = StateNotifierProvider<ResumeNotifier, ResumeState>((ref) {
  return ResumeNotifier(
    ref.watch(createResumeUseCaseProvider),
    ref.watch(getUserResumesUseCaseProvider),
    ref.watch(getResumeUseCaseProvider),
    ref.watch(updateResumeUseCaseProvider),
    ref.watch(generateSummaryUseCaseProvider),
    ref.watch(deleteResumeUseCaseProvider),
  );
});


