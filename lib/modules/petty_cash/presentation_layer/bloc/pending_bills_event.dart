part of 'pending_bills_bloc.dart';

abstract class PendingBillsEvent extends Equatable {
  const PendingBillsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingBillsEvent extends PendingBillsEvent {
  const LoadPendingBillsEvent();
}

class CompleteAdvancePaymentEvent extends PendingBillsEvent {
  final String advanceId;
  final String vendorName;
  final double actualAmount;
  final List<File> billPhotos;

  const CompleteAdvancePaymentEvent({
    required this.advanceId,
    required this.vendorName,
    required this.actualAmount,
    required this.billPhotos,
  });

  @override
  List<Object?> get props => [advanceId, vendorName, actualAmount, billPhotos];
}
