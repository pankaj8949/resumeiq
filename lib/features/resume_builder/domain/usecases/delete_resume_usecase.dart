import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/resume_repository.dart';

/// Use case for deleting a resume
class DeleteResumeUseCase {
  DeleteResumeUseCase(this._repository);

  final ResumeRepository _repository;

  /// Delete a resume by ID
  Future<Either<Failure, void>> call(String resumeId) async {
    return await _repository.deleteResume(resumeId);
  }
}

