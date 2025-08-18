import 'package:dartz/dartz.dart';

import '../../domain_layer/repositories/base_petty_cash_repository.dart';
import '../data_sources/petty_cash_remote_data_source.dart';
import '../models/petty_cash_model.dart';

class PettyCashRepository extends BasePettyCashRepository {
  final BasePettyCashRemoteDataSource remote;

  PettyCashRepository(this.remote);

  @override
  Future<Either<Exception, bool>> submitPettyCash({
    required PettyCashModel pettyCash,
  }) {
    return remote.submitPettyCash(pettyCash: pettyCash);
  }
}

