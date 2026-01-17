import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for signing in with email/password
class SignInWithEmailUseCase {
  SignInWithEmailUseCase({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

