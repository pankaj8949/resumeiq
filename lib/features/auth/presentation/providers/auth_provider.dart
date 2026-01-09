import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../resume_builder/domain/entities/resume_entity.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Auth state
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final UserEntity? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._signInUseCase,
    this._signOutUseCase,
    this._repository,
  ) : super(const AuthState()) {
    _init();
  }

  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _repository;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(user: user, isLoading: false),
    );
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _signInUseCase();
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
    );
  }

  Future<bool> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _signOutUseCase();
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = const AuthState();
        return true;
      },
    );
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
    String? location,
    String? linkedInUrl,
    String? portfolioUrl,
    String? githubUrl,
    String? summary,
    List<EducationEntity>? education,
    List<ExperienceEntity>? experience,
    List<String>? skills,
    List<ProjectEntity>? projects,
    List<CertificationEntity>? certifications,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
      phone: phone,
      location: location,
      linkedInUrl: linkedInUrl,
      portfolioUrl: portfolioUrl,
      githubUrl: githubUrl,
      summary: summary,
      education: education,
      experience: experience,
      skills: skills,
      projects: projects,
      certifications: certifications,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
    );
  }
}

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final googleSignIn = GoogleSignIn();
  final remoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
    googleSignIn: googleSignIn,
  );
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Auth use cases providers
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(repository: ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(repository: ref.watch(authRepositoryProvider));
});

/// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(signInUseCaseProvider),
    ref.watch(signOutUseCaseProvider),
    ref.watch(authRepositoryProvider),
  );
});

