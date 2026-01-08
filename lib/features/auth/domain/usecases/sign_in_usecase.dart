import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for signing in with Google
class SignInUseCase {
  SignInUseCase({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call() async {
    return await _repository.signInWithGoogle();
  }
}

