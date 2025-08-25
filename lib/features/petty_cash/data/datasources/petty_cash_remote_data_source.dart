import 'package:dartz/dartz.dart';
import '../models/petty_cash_bill_model.dart';

abstract class PettyCashRemoteDataSource {
  Future<Either<Exception, PettyCashBillModel>> submitBill(
      PettyCashBillModel bill);
  Future<Either<Exception, PettyCashBillModel>> updateBill(
      PettyCashBillModel bill);
  Future<Either<Exception, List<PettyCashBillModel>>> getUserBills(
      String userId);
  Future<Either<Exception, List<PettyCashBillModel>>> getPendingAdvances(
      String userId);
  Future<Either<Exception, String>> uploadPhoto(String filePath);
  Future<Either<Exception, PettyCashBillModel>> linkBillToAdvance(
      String billId, String advanceId);
  Future<Either<Exception, List<PettyCashBillModel>>> getFilteredBills({
    String? userId,
    String? status,
    String? billType,
    String? startDate,
    String? endDate,
  });
  Future<Either<Exception, PettyCashBillModel>> updateBillStatus(
      String billId, String status, String? adminComments);
  Future<Either<Exception, String>> exportToExcel({
    String? userId,
    String? status,
    String? billType,
    String? startDate,
    String? endDate,
  });
}

// TODO: Implement this with actual Odoo API calls
class PettyCashRemoteDataSourceImpl implements PettyCashRemoteDataSource {
  @override
  Future<Either<Exception, PettyCashBillModel>> submitBill(
      PettyCashBillModel bill) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, PettyCashBillModel>> updateBill(
      PettyCashBillModel bill) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, List<PettyCashBillModel>>> getUserBills(
      String userId) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, List<PettyCashBillModel>>> getPendingAdvances(
      String userId) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, String>> uploadPhoto(String filePath) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, PettyCashBillModel>> linkBillToAdvance(
      String billId, String advanceId) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, List<PettyCashBillModel>>> getFilteredBills({
    String? userId,
    String? status,
    String? billType,
    String? startDate,
    String? endDate,
  }) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, PettyCashBillModel>> updateBillStatus(
      String billId, String status, String? adminComments) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }

  @override
  Future<Either<Exception, String>> exportToExcel({
    String? userId,
    String? status,
    String? billType,
    String? startDate,
    String? endDate,
  }) async {
    // TODO: Implement Odoo API call
    return Left(Exception('Not implemented yet'));
  }
}
