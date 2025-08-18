import 'package:dartz/dartz.dart';

import '../../data_layer/models/petty_cash_model.dart';
import '../repositories/base_petty_cash_repository.dart';

class SubmitPettyCashUseCase {
  final BasePettyCashRepository repository;

  SubmitPettyCashUseCase(this.repository);

  Future<Either<Exception, bool>> submit({required PettyCashModel pettyCash}) {
    return repository.submitPettyCash(pettyCash: pettyCash);
  }
}

