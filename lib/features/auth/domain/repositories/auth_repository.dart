import '../entities/user_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../../resume_builder/domain/entities/resume_entity.dart';
import 'package:dartz/dartz.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
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
  });

  /// Stream of auth state changes
  Stream<Either<Failure, UserEntity?>> authStateChanges();
}

