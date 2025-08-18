import 'package:dartz/dartz.dart';

import '../entities/petty_cash_entry.dart';

abstract class PettyCashRepository {
  Future<Either<Exception, bool>> submit({required PettyCashEntry entry});
  Future<Either<Exception, bool>> update({required PettyCashEntry entry});
  Future<Either<Exception, bool>> delete({required int id});
  Future<Either<Exception, PettyCashEntry>> getById({required int id});
  Future<Either<Exception, List<PettyCashEntry>>> list({int? offset, int? limit});
}

