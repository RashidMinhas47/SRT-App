import 'package:dartz/dartz.dart';
import '../entities/petty_cash_bill.dart';
import '../repositories/petty_cash_repository.dart';

class ExportToExcel {
  final PettyCashRepository repository;

  ExportToExcel(this.repository);

  Future<Either<Exception, String>> call({
    String? userId,
    BillStatus? status,
    BillType? billType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Validate date range if provided
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        return Left(Exception('Start date cannot be after end date'));
      }
    }

    return await repository.exportToExcel(
      userId: userId,
      status: status,
      billType: billType,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
