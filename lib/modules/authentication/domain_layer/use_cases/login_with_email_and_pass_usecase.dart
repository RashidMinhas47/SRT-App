import 'package:dartz/dartz.dart';
import '../repsitories/base_auth_repository.dart';

class LoginWithEmailAndPassUseCase {
  final BaseAuthRepository baseAuthRepository;

  LoginWithEmailAndPassUseCase(this.baseAuthRepository);
  Future<Either<Exception, bool>>
  call({required String email, required String password}) async {
    return await baseAuthRepository.loginWithEmailAndPass(
        email: email, password: password);
  }
}
