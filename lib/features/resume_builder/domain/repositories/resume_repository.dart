import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume_entity.dart';

/// Resume repository interface
abstract class ResumeRepository {
  /// Create a new resume
  Future<Either<Failure, ResumeEntity>> createResume(ResumeEntity resume);

  /// Update an existing resume
  Future<Either<Failure, ResumeEntity>> updateResume(ResumeEntity resume);

  /// Get resume by ID
  Future<Either<Failure, ResumeEntity>> getResume(String resumeId);

  /// Get all resumes for a user
  Future<Either<Failure, List<ResumeEntity>>> getUserResumes(String userId);

  /// Delete a resume
  Future<Either<Failure, void>> deleteResume(String resumeId);

  /// Generate resume content with AI
  Future<Either<Failure, String>> generateResumeSummary({
    required PersonalInfoEntity personalInfo,
    required List<ExperienceEntity> experience,
    required List<EducationEntity> education,
    required List<String> skills,
  });

  /// Generate PDF from resume
  Future<Either<Failure, String>> generatePDF(ResumeEntity resume);
}


