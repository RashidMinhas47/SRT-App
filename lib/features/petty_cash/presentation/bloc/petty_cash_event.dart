part of 'petty_cash_bloc.dart';

abstract class PettyCashEvent extends Equatable {
  const PettyCashEvent();
}

class BillTypeChangedEvent extends PettyCashEvent {
  final String? billType;
  const BillTypeChangedEvent(this.billType);
  @override
  List<Object?> get props => [billType];
}

class UploadImageEvent extends PettyCashEvent {
  final List<File> photos;
  const UploadImageEvent(this.photos);
  @override
  List<Object?> get props => [photos];
}

class SubmitPettyCashEvent extends PettyCashEvent {
  final String billType;
  final double amount;
  final DateTime date;
  final List<File> photos;
  final String? comments;
  final String? billNumber;
  final String? vendorName;
  final String? customerProjectName;
  final String? location;

  const SubmitPettyCashEvent({
    required this.billType,
    required this.amount,
    required this.date,
    required this.photos,
    this.comments,
    this.billNumber,
    this.vendorName,
    this.customerProjectName,
    this.location,
  });

  @override
  List<Object?> get props => [
        billType,
        amount,
        date,
        photos,
        comments,
        billNumber,
        vendorName,
        customerProjectName,
        location,
      ];
}

