import 'package:dartz/dartz.dart';

import '../repositories/petty_cash_repository.dart';

class DeletePettyCash {
  final PettyCashRepository repository;
  DeletePettyCash(this.repository);

  Future<Either<Exception, bool>> call(int id) {
    return repository.delete(id: id);
  }
}

