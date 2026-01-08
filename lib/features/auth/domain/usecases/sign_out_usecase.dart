import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for signing out
class SignOutUseCase {
  SignOutUseCase({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  Future<Either<Failure, void>> call() async {
    return await _repository.signOut();
  }
}


