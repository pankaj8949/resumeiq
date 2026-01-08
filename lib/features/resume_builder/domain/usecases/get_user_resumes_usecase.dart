import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/resume_entity.dart';
import '../repositories/resume_repository.dart';

class GetUserResumesUseCase {
  GetUserResumesUseCase(this._repository);
  final ResumeRepository _repository;

  Future<Either<Failure, List<ResumeEntity>>> call(String userId) async {
    return await _repository.getUserResumes(userId);
  }
}


