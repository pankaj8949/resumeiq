import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume_entity.dart';
import '../repositories/resume_repository.dart';

/// Use case for updating a resume
class UpdateResumeUseCase {
  UpdateResumeUseCase(this._repository);

  final ResumeRepository _repository;

  /// Update an existing resume
  Future<Either<Failure, ResumeEntity>> call(ResumeEntity resume) async {
    return await _repository.updateResume(resume);
  }
}

