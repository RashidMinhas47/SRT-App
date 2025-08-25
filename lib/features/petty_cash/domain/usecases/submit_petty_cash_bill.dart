import 'package:dartz/dartz.dart';
import '../entities/petty_cash_bill.dart';
import '../repositories/petty_cash_repository.dart';

class SubmitPettyCashBill {
  final PettyCashRepository repository;

  SubmitPettyCashBill(this.repository);

  Future<Either<Exception, PettyCashBill>> call(PettyCashBill bill) async {
    // Validate the bill before submission
    final validationResult = _validateBill(bill);
    if (validationResult.isLeft()) {
      return validationResult;
    }

    return await repository.submitBill(bill);
  }

  Either<Exception, PettyCashBill> _validateBill(PettyCashBill bill) {
    // Validate required fields
    if (bill.location.trim().isEmpty) {
      return Left(Exception('Location is required'));
    }

    if (bill.amount <= 0) {
      return Left(Exception('Amount must be greater than 0'));
    }

    if (bill.comments.trim().isEmpty) {
      return Left(Exception('Comments are required'));
    }

    if (bill.photoUrl.trim().isEmpty) {
      return Left(Exception('Photo is required'));
    }

    // Validate advance payment specific fields
    if (bill.isAdvancePayment) {
      if (bill.advancePurpose?.trim().isEmpty ?? true) {
        return Left(
            Exception('Advance purpose is required for advance payments'));
      }

      if (bill.expectedAmount == null || bill.expectedAmount! <= 0) {
        return Left(
            Exception('Expected amount is required for advance payments'));
      }
    }

    // Validate date
    if (bill.expenseDate.isAfter(DateTime.now())) {
      return Left(Exception('Expense date cannot be in the future'));
    }

    return Right(bill);
  }
}
