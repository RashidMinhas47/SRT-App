part of 'petty_cash_bloc.dart';

abstract class PettyCashEvent extends Equatable {
  const PettyCashEvent();
}

class AddBillPhotoEvent extends PettyCashEvent {
  final List<File> photos;
  const AddBillPhotoEvent(this.photos);
  @override
  List<Object?> get props => [photos];
}

class RemoveBillPhotoEvent extends PettyCashEvent {
  final int index;
  const RemoveBillPhotoEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class SubmitPettyCashEvent extends PettyCashEvent {
  final String vendorName;
  final String description;
  final double amount;
  final DateTime date;
  const SubmitPettyCashEvent({
    required this.vendorName,
    required this.description,
    required this.amount,
    required this.date,
  });
  @override
  List<Object?> get props => [vendorName, description, amount, date];
}

