import 'package:dartz/dartz.dart';

import '../../data_layer/models/petty_cash_model.dart';

abstract class BasePettyCashRepository {
  Future<Either<Exception, bool>> submitPettyCash({
    required PettyCashModel pettyCash,
  });
}

