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
  final BillType billType;
  final String? billNumber;
  final String? customerProjectName;
  final String location;
  final String comments;
  final bool isAdvanceRequest;
  final String? advancePurpose;
  final double? expectedAmount;
  final String? projectCustomerName;
  final String userId;

  const SubmitPettyCashEvent({
    required this.vendorName,
    required this.description,
    required this.amount,
    required this.date,
    required this.billType,
    this.billNumber,
    this.customerProjectName,
    required this.location,
    required this.comments,
    this.isAdvanceRequest = false,
    this.advancePurpose,
    this.expectedAmount,
    this.projectCustomerName,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        vendorName,
        description,
        amount,
        date,
        billType,
        billNumber,
        customerProjectName,
        location,
        comments,
        isAdvanceRequest,
        advancePurpose,
        expectedAmount,
        projectCustomerName,
        userId,
      ];
}
