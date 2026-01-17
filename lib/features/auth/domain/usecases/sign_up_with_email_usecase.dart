import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for signing up with email/password
class SignUpWithEmailUseCase {
  SignUpWithEmailUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

