import 'package:dartz/dartz.dart';

import '../entities/petty_cash_entry.dart';
import '../repositories/petty_cash_repository.dart';

class GetPettyCashById {
  final PettyCashRepository repository;
  GetPettyCashById(this.repository);

  Future<Either<Exception, PettyCashEntry>> call(int id) {
    return repository.getById(id: id);
  }
}

class ListPettyCash {
  final PettyCashRepository repository;
  ListPettyCash(this.repository);

  Future<Either<Exception, List<PettyCashEntry>>> call({int? offset, int? limit}) {
    return repository.list(offset: offset, limit: limit);
  }
}

