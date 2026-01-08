import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume_entity.dart';
import '../repositories/resume_repository.dart';

/// Use case for getting a resume by ID
class GetResumeUseCase {
  GetResumeUseCase(this._repository);

  final ResumeRepository _repository;

  /// Get a resume by ID
  Future<Either<Failure, ResumeEntity>> call(String resumeId) async {
    return await _repository.getResume(resumeId);
  }
}

