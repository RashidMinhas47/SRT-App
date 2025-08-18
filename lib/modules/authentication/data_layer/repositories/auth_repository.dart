

import 'package:dartz/dartz.dart';

import '../../domain_layer/repsitories/base_auth_repository.dart';
import '../data_sources/auth_remote_data_sources.dart';

class AuthRepository extends BaseAuthRepository {
  BaseAuthRemoteDataSource baseAuthRemoteDataSource;
  AuthRepository(this.baseAuthRemoteDataSource);

  @override
  Future<Either<Exception, bool>> loginWithEmailAndPass(
      {required String email, required String password}) async {
    return baseAuthRemoteDataSource.loginWithEmailAndPass(
        email: email, password: password);
  }
}
