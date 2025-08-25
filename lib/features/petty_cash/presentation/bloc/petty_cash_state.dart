import 'package:equatable/equatable.dart';
import 'dart:io';

import '../../domain/entities/petty_cash_bill.dart';

abstract class PettyCashState extends Equatable {
  const PettyCashState();

  @override
  List<Object?> get props => [];
}

class PettyCashInitial extends PettyCashState {
  const PettyCashInitial();
}

class PettyCashLoading extends PettyCashState {
  const PettyCashLoading();
}

class BillTypeSelected extends PettyCashState {
  final BillType selectedBillType;

  const BillTypeSelected(this.selectedBillType);

  @override
  List<Object?> get props => [selectedBillType];
}

class PhotoUploaded extends PettyCashState {
  final File photoFile;
  final String photoUrl;

  const PhotoUploaded({
    required this.photoFile,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [photoFile, photoUrl];
}

class PhotoCleared extends PettyCashState {
  const PhotoCleared();
}

class BillSubmittedSuccess extends PettyCashState {
  final PettyCashBill submittedBill;

  const BillSubmittedSuccess(this.submittedBill);

  @override
  List<Object?> get props => [submittedBill];
}

class PettyCashError extends PettyCashState {
  final String message;

  const PettyCashError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserBillsLoaded extends PettyCashState {
  final List<PettyCashBill> bills;

  const UserBillsLoaded(this.bills);

  @override
  List<Object?> get props => [bills];
}

class PendingAdvancesLoaded extends PettyCashState {
  final List<PettyCashBill> advances;

  const PendingAdvancesLoaded(this.advances);

  @override
  List<Object?> get props => [advances];
}

class AdvanceCompleted extends PettyCashState {
  final PettyCashBill completedBill;

  const AdvanceCompleted(this.completedBill);

  @override
  List<Object?> get props => [completedBill];
}

class BillStatusUpdated extends PettyCashState {
  final PettyCashBill updatedBill;

  const BillStatusUpdated(this.updatedBill);

  @override
  List<Object?> get props => [updatedBill];
}

class ExcelExported extends PettyCashState {
  final String filePath;

  const ExcelExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class FormReset extends PettyCashState {
  const FormReset();
}
