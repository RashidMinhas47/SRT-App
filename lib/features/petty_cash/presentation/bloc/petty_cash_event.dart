import 'package:equatable/equatable.dart';
import 'dart:io';

import '../../domain/entities/petty_cash_bill.dart';

abstract class PettyCashEvent extends Equatable {
  const PettyCashEvent();

  @override
  List<Object?> get props => [];
}

class SubmitBillEvent extends PettyCashEvent {
  final PettyCashBill bill;

  const SubmitBillEvent(this.bill);

  @override
  List<Object?> get props => [bill];
}

class SelectBillTypeEvent extends PettyCashEvent {
  final BillType billType;

  const SelectBillTypeEvent(this.billType);

  @override
  List<Object?> get props => [billType];
}

class UploadPhotoEvent extends PettyCashEvent {
  final File photoFile;

  const UploadPhotoEvent(this.photoFile);

  @override
  List<Object?> get props => [photoFile];
}

class LoadUserBillsEvent extends PettyCashEvent {
  final String userId;

  const LoadUserBillsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadPendingAdvancesEvent extends PettyCashEvent {
  final String userId;

  const LoadPendingAdvancesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CompleteAdvanceEvent extends PettyCashEvent {
  final String billId;
  final String advanceId;

  const CompleteAdvanceEvent({
    required this.billId,
    required this.advanceId,
  });

  @override
  List<Object?> get props => [billId, advanceId];
}

class UpdateBillStatusEvent extends PettyCashEvent {
  final String billId;
  final BillStatus status;
  final String? adminComments;

  const UpdateBillStatusEvent({
    required this.billId,
    required this.status,
    this.adminComments,
  });

  @override
  List<Object?> get props => [billId, status, adminComments];
}

class ExportToExcelEvent extends PettyCashEvent {
  final String? userId;
  final BillStatus? status;
  final BillType? billType;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExportToExcelEvent({
    this.userId,
    this.status,
    this.billType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, status, billType, startDate, endDate];
}

class ClearPhotoEvent extends PettyCashEvent {
  const ClearPhotoEvent();
}

class ResetFormEvent extends PettyCashEvent {
  const ResetFormEvent();
}
