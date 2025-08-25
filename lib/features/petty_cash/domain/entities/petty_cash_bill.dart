import 'package:equatable/equatable.dart';

enum BillType {
  materialPurchase,
  foodMeals,
  transportFuel,
  miscellaneous,
  advanceRequest
}

enum BillStatus {
  pending,
  pendingBillSubmission,
  billPending,
  approved,
  rejected,
  needsClarification
}

class PettyCashBill extends Equatable {
  final String? id;
  final BillType billType;
  final String? billNumber;
  final String? vendorName;
  final String? customerProjectName;
  final String location;
  final double amount;
  final DateTime expenseDate;
  final String comments;
  final String photoUrl;
  final BillStatus status;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Special fields for advance payments
  final bool isAdvancePayment;
  final String? advancePurpose;
  final double? expectedAmount;
  final String? parentAdvanceId; // Links final bill to advance request

  const PettyCashBill({
    this.id,
    required this.billType,
    this.billNumber,
    this.vendorName,
    this.customerProjectName,
    required this.location,
    required this.amount,
    required this.expenseDate,
    required this.comments,
    required this.photoUrl,
    required this.status,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.isAdvancePayment = false,
    this.advancePurpose,
    this.expectedAmount,
    this.parentAdvanceId,
  });

  @override
  List<Object?> get props => [
        id,
        billType,
        billNumber,
        vendorName,
        customerProjectName,
        location,
        amount,
        expenseDate,
        comments,
        photoUrl,
        status,
        userId,
        createdAt,
        updatedAt,
        isAdvancePayment,
        advancePurpose,
        expectedAmount,
        parentAdvanceId,
      ];

  PettyCashBill copyWith({
    String? id,
    BillType? billType,
    String? billNumber,
    String? vendorName,
    String? customerProjectName,
    String? location,
    double? amount,
    DateTime? expenseDate,
    String? comments,
    String? photoUrl,
    BillStatus? status,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAdvancePayment,
    String? advancePurpose,
    double? expectedAmount,
    String? parentAdvanceId,
  }) {
    return PettyCashBill(
      id: id ?? this.id,
      billType: billType ?? this.billType,
      billNumber: billNumber ?? this.billNumber,
      vendorName: vendorName ?? this.vendorName,
      customerProjectName: customerProjectName ?? this.customerProjectName,
      location: location ?? this.location,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      comments: comments ?? this.comments,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAdvancePayment: isAdvancePayment ?? this.isAdvancePayment,
      advancePurpose: advancePurpose ?? this.advancePurpose,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      parentAdvanceId: parentAdvanceId ?? this.parentAdvanceId,
    );
  }
}
