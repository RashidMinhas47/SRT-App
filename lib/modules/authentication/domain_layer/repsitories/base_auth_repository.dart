

import 'package:dartz/dartz.dart';

abstract class BaseAuthRepository {
  Future<Either<Exception, bool>> loginWithEmailAndPass(
      {required String email, required String password});
}
