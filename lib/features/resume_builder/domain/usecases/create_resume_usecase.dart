import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume_entity.dart';
import '../repositories/resume_repository.dart';

class CreateResumeUseCase {
  CreateResumeUseCase(this._repository);
  final ResumeRepository _repository;

  Future<Either<Failure, ResumeEntity>> call(ResumeEntity resume) async {
    return await _repository.createResume(resume);
  }
}


