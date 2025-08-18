import 'package:dartz/dartz.dart';

import '../entities/petty_cash_entry.dart';
import '../repositories/petty_cash_repository.dart';

class GetPettyCashEntriesUseCase {
  final PettyCashRepository repository;
  GetPettyCashEntriesUseCase(this.repository);

  Future<Either<Exception, List<PettyCashEntry>>> call({int? offset, int? limit}) {
    return repository.list(offset: offset, limit: limit);
  }
}

import 'package:dartz/dartz.dart';

import '../entities/petty_cash_entry.dart';
import '../repositories/petty_cash_repository.dart';

class GetPettyCashEntriesUseCase {
  final PettyCashRepository repository;
  GetPettyCashEntriesUseCase(this.repository);

  Future<Either<Exception, List<PettyCashEntry>>> call({int? offset, int? limit}) {
    return repository.list(offset: offset, limit: limit);
  }
}