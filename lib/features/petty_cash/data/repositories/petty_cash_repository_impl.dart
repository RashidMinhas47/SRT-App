import 'package:dartz/dartz.dart';

import '../../domain/entities/petty_cash_entry.dart';
import '../../domain/repositories/petty_cash_repository.dart';
import '../datasources/petty_cash_remote_datasource.dart';
import '../models/petty_cash_model.dart';

class PettyCashRepositoryImpl implements PettyCashRepository {
  final PettyCashRemoteDataSource remote;
  PettyCashRepositoryImpl(this.remote);

  @override
  Future<Either<Exception, bool>> submit({required PettyCashEntry entry}) async {
    try {
      // Upload images first and map to attachment IDs
      final attachmentIds = <int>[];
      for (final img in entry.billPhotosBase64) {
        final res = await remote.uploadAttachment(img);
        res.fold((l) => null, (r) => attachmentIds.add(r));
      }

      final model = PettyCashModel(
        id: entry.id,
        type: entry.type,
        amount: entry.amount,
        date: entry.date,
        description: entry.description,
        submittedByUserId: entry.submittedByUserId,
        referenceId: entry.referenceId,
        currencyCode: entry.currencyCode,
        vendorName: entry.vendorName,
        invoiceNumber: entry.invoiceNumber,
        billPhotosBase64: const [],
        attachmentIds: [...(entry.attachmentIds ?? []), ...attachmentIds],
        expectedSettlementDate: entry.expectedSettlementDate,
        settlementNotes: entry.settlementNotes,
      );

      return await remote.submit(model);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, bool>> update({required PettyCashEntry entry}) async {
    try {
      if (entry.id == null) return Left(Exception('Missing id'));

      final attachmentIds = <int>[];
      for (final img in entry.billPhotosBase64) {
        final res = await remote.uploadAttachment(img);
        res.fold((l) => null, (r) => attachmentIds.add(r));
      }

      final model = PettyCashModel(
        id: entry.id,
        type: entry.type,
        amount: entry.amount,
        date: entry.date,
        description: entry.description,
        submittedByUserId: entry.submittedByUserId,
        referenceId: entry.referenceId,
        currencyCode: entry.currencyCode,
        vendorName: entry.vendorName,
        invoiceNumber: entry.invoiceNumber,
        billPhotosBase64: const [],
        attachmentIds: [...(entry.attachmentIds ?? []), ...attachmentIds],
        expectedSettlementDate: entry.expectedSettlementDate,
        settlementNotes: entry.settlementNotes,
      );

      return await remote.update(model);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Exception, bool>> delete({required int id}) {
    return remote.delete(id);
  }

  @override
  Future<Either<Exception, PettyCashEntry>> getById({required int id}) async {
    final res = await remote.getById(id);
    return res.map((r) => r);
  }

  @override
  Future<Either<Exception, List<PettyCashEntry>>> list({int? offset, int? limit}) async {
    final res = await remote.list(offset: offset, limit: limit);
    return res.map((r) => r);
  }
}

