import 'package:dartz/dartz.dart';
import '../entities/petty_cash_bill.dart';
import '../repositories/petty_cash_repository.dart';

class UpdateBillStatus {
  final PettyCashRepository repository;

  UpdateBillStatus(this.repository);

  Future<Either<Exception, PettyCashBill>> call({
    required String billId,
    required BillStatus status,
    String? adminComments,
  }) async {
    if (billId.trim().isEmpty) {
      return Left(Exception('Bill ID is required'));
    }

    // Validate status transitions
    if (!_isValidStatusTransition(status)) {
      return Left(Exception('Invalid status transition'));
    }

    return await repository.updateBillStatus(billId, status, adminComments);
  }

  bool _isValidStatusTransition(BillStatus newStatus) {
    // Define valid status transitions
    // This can be expanded based on business rules
    return [
      BillStatus.pending,
      BillStatus.approved,
      BillStatus.rejected,
      BillStatus.needsClarification,
      BillStatus.pendingBillSubmission,
      BillStatus.billPending,
    ].contains(newStatus);
  }
}
