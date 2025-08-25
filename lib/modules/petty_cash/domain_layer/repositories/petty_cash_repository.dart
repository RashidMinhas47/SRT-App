import 'package:dartz/dartz.dart';
import '../entities/petty_cash.dart';

abstract class PettyCashRepository {
  /// Submit a new petty cash bill
  Future<Either<Exception, PettyCash>> submitBill(PettyCash bill);

  /// Get all bills for the current user
  Future<Either<Exception, List<PettyCash>>> getUserBills(String userId);

  /// Get pending advance payments for the current user
  Future<Either<Exception, List<PettyCash>>> getPendingAdvances(String userId);

  /// Get bills with specific status
  Future<Either<Exception, List<PettyCash>>> getBillsByStatus(
      BillStatus status);

  /// Update bill status
  Future<Either<Exception, PettyCash>> updateBillStatus(
      String billId, BillStatus status);

  /// Complete advance payment with final bill details
  Future<Either<Exception, PettyCash>> completeAdvancePayment(String advanceId,
      String vendorName, double actualAmount, List<String> billPhotos);
}
