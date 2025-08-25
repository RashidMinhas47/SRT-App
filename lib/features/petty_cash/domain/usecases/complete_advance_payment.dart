import 'package:dartz/dartz.dart';
import '../entities/petty_cash_bill.dart';
import '../repositories/petty_cash_repository.dart';

class CompleteAdvancePayment {
  final PettyCashRepository repository;

  CompleteAdvancePayment(this.repository);

  Future<Either<Exception, PettyCashBill>> call({
    required String billId,
    required String advanceId,
  }) async {
    // Validate that both bill and advance exist and are valid
    if (billId.trim().isEmpty) {
      return Left(Exception('Bill ID is required'));
    }

    if (advanceId.trim().isEmpty) {
      return Left(Exception('Advance ID is required'));
    }

    return await repository.linkBillToAdvance(billId, advanceId);
  }
}
