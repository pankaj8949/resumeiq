import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/resume_model.dart';
import '../features/auth/domain/usecases/sign_in_usecase.dart';
import '../features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '../features/auth/domain/usecases/sign_out_usecase.dart';
import '../features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/resume_builder/domain/entities/resume_entity.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Auth state
class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error});

  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    UserModel? user,
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
    this._signInWithEmailUseCase,
    this._signUpWithEmailUseCase,
    this._signOutUseCase,
    this._repository,
  )
    : super(const AuthState()) {
    _init();
  }

  final SignInUseCase _signInUseCase;
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthRepository _repository;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      // Add timeout to prevent indefinite loading (10 seconds)
      final result = await _repository.getCurrentUser().timeout(
        const Duration(seconds: 10),
      );
      result.fold(
        (failure) {
          // On failure, set user to null and stop loading
          // This allows the app to navigate to login page
          state = state.copyWith(user: null, isLoading: false, error: null);
        },
        (user) {
          // Handle null user (new/first-time users who haven't signed in)
          if (user == null) {
            state = state.copyWith(user: null, isLoading: false);
          } else {
            state = state.copyWith(
              user: UserModel.fromEntity(user),
              isLoading: false,
            );
          }
        },
      );
    } on TimeoutException {
      // Handle timeout - treat as no user and navigate to login
      state = state.copyWith(user: null, isLoading: false, error: null);
    } catch (e) {
      // Catch any unexpected errors and ensure loading stops
      // Treat as no user to allow navigation to login page
      state = state.copyWith(user: null, isLoading: false, error: null);
    }
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
        state = state.copyWith(
          user: UserModel.fromEntity(user),
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _signUpWithEmailUseCase(email: email, password: password);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(
          user: UserModel.fromEntity(user),
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _signInWithEmailUseCase(email: email, password: password);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(
          user: UserModel.fromEntity(user),
          isLoading: false,
        );
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

  Future<bool> sendPasswordResetEmail() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      final providers = authUser?.providerData.map((p) => p.providerId).toList() ?? const <String>[];
      if (authUser != null && providers.isNotEmpty && !providers.contains('password')) {
        state = state.copyWith(
          isLoading: false,
          error: 'This account uses ${providers.join(", ")} sign-in. Password reset is only available for Email/Password accounts.',
        );
        return false;
      }

      final email = authUser?.email ?? state.user?.email;
      if (email == null || email.trim().isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Email not available');
        return false;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '${e.message ?? 'Failed to send password reset email'} (code: ${e.code})',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send password reset email',
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
    String? location,
    String? currentDesignation,
    String? linkedInUrl,
    String? portfolioUrl,
    String? githubUrl,
    String? summary,
    bool? profileCompletionDone,
    List<Education>? education,
    List<Experience>? experience,
    List<String>? skills,
    List<Project>? projects,
    List<Certification>? certifications,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    // Convert models to entities for repository
    final result = await _repository.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
      phone: phone,
      location: location,
      currentDesignation: currentDesignation,
      linkedInUrl: linkedInUrl,
      portfolioUrl: portfolioUrl,
      githubUrl: githubUrl,
      summary: summary,
      profileCompletionDone: profileCompletionDone,
      education: education
          ?.map(
            (e) => EducationEntity(
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
      experience: experience
          ?.map(
            (e) => ExperienceEntity(
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
      skills: skills,
      projects: projects
          ?.map(
            (p) => ProjectEntity(
              name: p.name,
              description: p.description,
              technologies: p.technologies,
              url: p.url,
              startDate: p.startDate,
              endDate: p.endDate,
            ),
          )
          .toList(),
      certifications: certifications
          ?.map(
            (c) => CertificationEntity(
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
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(
          user: UserModel.fromEntity(user),
          isLoading: false,
        );
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

final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(repository: ref.watch(authRepositoryProvider));
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return SignUpWithEmailUseCase(repository: ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(repository: ref.watch(authRepositoryProvider));
});

/// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    ref.watch(signInUseCaseProvider),
    ref.watch(signInWithEmailUseCaseProvider),
    ref.watch(signUpWithEmailUseCaseProvider),
    ref.watch(signOutUseCaseProvider),
    ref.watch(authRepositoryProvider),
  );
});
