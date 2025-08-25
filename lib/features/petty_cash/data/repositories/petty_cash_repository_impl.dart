import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/petty_cash_bill.dart';
import '../../domain/repositories/petty_cash_repository.dart';
import '../datasources/petty_cash_remote_data_source.dart';
import '../models/petty_cash_bill_model.dart';

class PettyCashRepositoryImpl implements PettyCashRepository {
  final PettyCashRemoteDataSource remoteDataSource;

  PettyCashRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Exception, PettyCashBill>> submitBill(
      PettyCashBill bill) async {
    try {
      // Check network connectivity
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      // Convert entity to model
      final billModel = PettyCashBillModel.fromEntity(bill);

      // Submit to remote data source
      final result = await remoteDataSource.submitBill(billModel);

      return result.fold(
        (exception) => Left(exception),
        (model) => Right(model.toEntity()),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, PettyCashBill>> updateBill(
      PettyCashBill bill) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      final billModel = PettyCashBillModel.fromEntity(bill);
      final result = await remoteDataSource.updateBill(billModel);

      return result.fold(
        (exception) => Left(exception),
        (model) => Right(model.toEntity()),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<PettyCashBill>>> getUserBills(
      String userId) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      final result = await remoteDataSource.getUserBills(userId);

      return result.fold(
        (exception) => Left(exception),
        (models) => Right(models.map((model) => model.toEntity()).toList()),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<PettyCashBill>>> getPendingAdvances(
      String userId) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      final result = await remoteDataSource.getPendingAdvances(userId);

      return result.fold(
        (exception) => Left(exception),
        (models) => Right(models.map((model) => model.toEntity()).toList()),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, String>> uploadPhoto(String filePath) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      return await remoteDataSource.uploadPhoto(filePath);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, PettyCashBill>> linkBillToAdvance(
      String billId, String advanceId) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      final result =
          await remoteDataSource.linkBillToAdvance(billId, advanceId);

      return result.fold(
        (exception) => Left(exception),
        (model) => Right(model.toEntity()),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, List<PettyCashBill>>> getFilteredBills({
    String? userId,
    BillStatus? status,
    BillType? billType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      final result = await remoteDataSource.getFilteredBills(
        userId: userId,
        status: status?.name,
        billType: billType?.name,
        startDate: startDate?.toIso8601String().split('T')[0],
        endDate: endDate?.toIso8601String().split('T')[0],
      );

      return result.fold(
        (exception) => Left(exception),
        (models) => Right(models.map((model) => model.toEntity()).toList()),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, PettyCashBill>> updateBillStatus(
      String billId, BillStatus status, String? adminComments) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      final result = await remoteDataSource.updateBillStatus(
          billId, status.name, adminComments);

      return result.fold(
        (exception) => Left(exception),
        (model) => Right(model.toEntity()),
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, String>> exportToExcel({
    String? userId,
    BillStatus? status,
    BillType? billType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasInternet =
          connectivityResults.any((r) => r != ConnectivityResult.none);
      if (!hasInternet) {
        return Left(Exception('No internet connection'));
      }

      return await remoteDataSource.exportToExcel(
        userId: userId,
        status: status?.name,
        billType: billType?.name,
        startDate: startDate?.toIso8601String().split('T')[0],
        endDate: endDate?.toIso8601String().split('T')[0],
      );
    } on Exception catch (e) {
      return Left(e);
    }
  }
}
