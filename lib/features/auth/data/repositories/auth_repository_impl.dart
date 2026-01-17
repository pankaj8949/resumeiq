import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../resume_builder/domain/entities/resume_entity.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }


  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phone,
    String? location,
    String? currentDesignation,
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
    try {
      final user = await _remoteDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        phone: phone,
        location: location,
        currentDesignation: currentDesignation,
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
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.mapExceptionToFailure(e));
    }
  }

  @override
  Stream<Either<Failure, UserEntity?>> authStateChanges() {
    return _remoteDataSource.authStateChanges().map((user) {
      return Right<Failure, UserEntity?>(user);
    }).handleError((error) {
      return Left<Failure, UserEntity?>(ErrorHandler.mapExceptionToFailure(error));
    });
  }
}

