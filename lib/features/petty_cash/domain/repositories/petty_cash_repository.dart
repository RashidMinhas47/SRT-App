import 'package:dartz/dartz.dart';
import '../entities/petty_cash_bill.dart';

abstract class PettyCashRepository {
  /// Submit a new petty cash bill
  Future<Either<Exception, PettyCashBill>> submitBill(PettyCashBill bill);

  /// Update an existing bill
  Future<Either<Exception, PettyCashBill>> updateBill(PettyCashBill bill);

  /// Get all bills for the current user
  Future<Either<Exception, List<PettyCashBill>>> getUserBills(String userId);

  /// Get pending advance payments for the current user
  Future<Either<Exception, List<PettyCashBill>>> getPendingAdvances(
      String userId);

  /// Upload photo and return the URL
  Future<Either<Exception, String>> uploadPhoto(String filePath);

  /// Link a final bill to an advance request
  Future<Either<Exception, PettyCashBill>> linkBillToAdvance(
      String billId, String advanceId);

  /// Get filtered bills based on criteria
  Future<Either<Exception, List<PettyCashBill>>> getFilteredBills({
    String? userId,
    BillStatus? status,
    BillType? billType,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Update bill status (for admin approval/rejection)
  Future<Either<Exception, PettyCashBill>> updateBillStatus(
      String billId, BillStatus status, String? adminComments);

  /// Export bills to Excel format
  Future<Either<Exception, String>> exportToExcel({
    String? userId,
    BillStatus? status,
    BillType? billType,
    DateTime? startDate,
    DateTime? endDate,
  });
}
