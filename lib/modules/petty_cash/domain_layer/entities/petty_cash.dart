// import 'package:equatable/equatable.dart';

// enum BillType {
//   materialPurchase,
//   foodMeals,
//   transportFuel,
//   miscellaneous,
//   advanceRequest,
// }

// enum BillStatus {
//   pending,
//   pendingBillSubmission,
//   billPending,
//   approved,
//   rejected,
//   needsClarification
// }

// class PettyCash extends Equatable {
//   final String? id;
//   final String vendorName;
//   final String description;
//   final double amount;
//   final DateTime date;
//   final List<String> billPhotosBase64;
//   final BillType billType;
//   final String? billNumber;
//   final String? customerProjectName;
//   final String location;
//   final String comments;
//   final bool isAdvanceRequest;
//   final String? advancePurpose;
//   final double? expectedAmount;
//   final String? projectCustomerName;
//   final BillStatus status;
//   final String userId;
//   final DateTime createdAt;
//   final DateTime? updatedAt;

//   const PettyCash({
//     this.id,
//     required this.vendorName,
//     required this.description,
//     required this.amount,
//     required this.date,
//     required this.billPhotosBase64,
//     required this.billType,
//     this.billNumber,
//     this.customerProjectName,
//     required this.location,
//     required this.comments,
//     this.isAdvanceRequest = false,
//     this.advancePurpose,
//     this.expectedAmount,
//     this.projectCustomerName,
//     this.status = BillStatus.pending,
//     required this.userId,
//     required this.createdAt,
//     this.updatedAt,
//   });

//   @override
//   List<Object?> get props => [
//         id,
//         vendorName,
//         description,
//         amount,
//         date,
//         billPhotosBase64,
//         billType,
//         billNumber,
//         customerProjectName,
//         location,
//         comments,
//         isAdvanceRequest,
//         advancePurpose,
//         expectedAmount,
//         projectCustomerName,
//         status,
//         userId,
//         createdAt,
//         updatedAt,
//       ];
// }

import 'package:equatable/equatable.dart';

enum BillType {
  materialPurchase,
  foodMeals,
  transportFuel,
  miscellaneous,
  advanceRequest,
}

enum BillStatus {
  pending,
  pendingBillSubmission,
  billPending,
  approved,
  rejected,
  needsClarification
}

class PettyCash extends Equatable {
  final String? id;
  final String vendorName;
  final String description;
  final double amount;
  final DateTime date;
  final List<String> billPhotosBase64;
  final BillType billType;
  final String? billNumber;
  final String? customerProjectName;
  final String location;
  final String comments;
  final bool isAdvanceRequest;
  final String? advancePurpose;
  final double? expectedAmount;
  final String? projectCustomerName;
  final BillStatus status;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PettyCash({
    this.id,
    required this.vendorName,
    required this.description,
    required this.amount,
    required this.date,
    required this.billPhotosBase64,
    required this.billType,
    this.billNumber,
    this.customerProjectName,
    required this.location,
    required this.comments,
    this.isAdvanceRequest = false,
    this.advancePurpose,
    this.expectedAmount,
    this.projectCustomerName,
    this.status = BillStatus.pending,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        vendorName,
        description,
        amount,
        date,
        billPhotosBase64,
        billType,
        billNumber,
        customerProjectName,
        location,
        comments,
        isAdvanceRequest,
        advancePurpose,
        expectedAmount,
        projectCustomerName,
        status,
        userId,
        createdAt,
        updatedAt,
      ];
}
