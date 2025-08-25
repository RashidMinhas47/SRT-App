import 'package:dartz/dartz.dart';
import '../entities/petty_cash_bill.dart';
import '../repositories/petty_cash_repository.dart';

class GetUserBills {
  final PettyCashRepository repository;

  GetUserBills(this.repository);

  Future<Either<Exception, List<PettyCashBill>>> call(String userId) async {
    if (userId.trim().isEmpty) {
      return Left(Exception('User ID is required'));
    }

    return await repository.getUserBills(userId);
  }
}
