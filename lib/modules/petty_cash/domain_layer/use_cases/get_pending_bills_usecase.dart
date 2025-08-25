import 'package:dartz/dartz.dart';
import '../entities/petty_cash.dart';
import '../repositories/petty_cash_repository.dart';

class GetPendingBillsUseCase {
  final PettyCashRepository repository;

  GetPendingBillsUseCase(this.repository);

  Future<Either<Exception, List<PettyCash>>> call() async {
    return await repository.getBillsByStatus(BillStatus.pendingBillSubmission);
  }
}
