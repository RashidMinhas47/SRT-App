part of 'pending_bills_bloc.dart';

abstract class PendingBillsState extends Equatable {
  const PendingBillsState();

  @override
  List<Object?> get props => [];
}

class PendingBillsInitial extends PendingBillsState {}

class PendingBillsLoading extends PendingBillsState {}

class PendingBillsLoaded extends PendingBillsState {
  final List<PettyCashModel> bills;

  const PendingBillsLoaded(this.bills);

  @override
  List<Object?> get props => [bills];
}

class PendingBillsError extends PendingBillsState {
  final String message;

  const PendingBillsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdvancePaymentCompleted extends PendingBillsState {
  final PettyCashModel bill;

  const AdvancePaymentCompleted(this.bill);

  @override
  List<Object?> get props => [bill];
}
