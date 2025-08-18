import 'package:dartz/dartz.dart';

import '../entities/petty_cash_entry.dart';
import '../repositories/petty_cash_repository.dart';

class SubmitPettyCash {
  final PettyCashRepository repository;
  SubmitPettyCash(this.repository);

  Future<Either<Exception, bool>> call(PettyCashEntry entry) {
    return repository.submit(entry: entry);
  }
}

