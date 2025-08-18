import 'package:dartz/dartz.dart';

import '../entities/petty_cash_entry.dart';
import '../repositories/petty_cash_repository.dart';

class SubmitPettyCashUseCase {
  final PettyCashRepository repository;

  SubmitPettyCashUseCase(this.repository);

  Future<Either<Exception, bool>> call(PettyCashEntry entry) {
    return repository.submit(entry: entry);
  }
}

