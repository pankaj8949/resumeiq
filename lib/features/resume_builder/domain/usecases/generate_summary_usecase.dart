import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume_entity.dart';
import '../repositories/resume_repository.dart';

class GenerateSummaryUseCase {
  GenerateSummaryUseCase(this._repository);
  final ResumeRepository _repository;

  Future<Either<Failure, String>> call({
    required PersonalInfoEntity personalInfo,
    required List<ExperienceEntity> experience,
    required List<EducationEntity> education,
    required List<String> skills,
  }) async {
    return await _repository.generateResumeSummary(
      personalInfo: personalInfo,
      experience: experience,
      education: education,
      skills: skills,
    );
  }
}

