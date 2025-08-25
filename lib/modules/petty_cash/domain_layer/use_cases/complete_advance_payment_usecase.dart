import 'package:dartz/dartz.dart';
import '../entities/petty_cash.dart';
import '../repositories/petty_cash_repository.dart';

class CompleteAdvancePaymentUseCase {
  final PettyCashRepository repository;

  CompleteAdvancePaymentUseCase(this.repository);

  Future<Either<Exception, PettyCash>> call({
    required String advanceId,
    required String vendorName,
    required double actualAmount,
    required List<String> billPhotos,
  }) async {
    return await repository.completeAdvancePayment(
      advanceId,
      vendorName,
      actualAmount,
      billPhotos,
    );
  }
}
