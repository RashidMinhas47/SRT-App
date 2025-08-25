import '../../domain/entities/petty_cash_bill.dart';

class PettyCashBillModel extends PettyCashBill {
  const PettyCashBillModel({
    super.id,
    required super.billType,
    super.billNumber,
    super.vendorName,
    super.customerProjectName,
    required super.location,
    required super.amount,
    required super.expenseDate,
    required super.comments,
    required super.photoUrl,
    required super.status,
    required super.userId,
    required super.createdAt,
    super.updatedAt,
    super.isAdvancePayment = false,
    super.advancePurpose,
    super.expectedAmount,
    super.parentAdvanceId,
  });

  factory PettyCashBillModel.fromJson(Map<String, dynamic> json) {
    return PettyCashBillModel(
      id: json['id']?.toString(),
      billType: _parseBillType(json['x_bill_type']),
      billNumber: json['x_bill_number'],
      vendorName: json['x_vendor_name'],
      customerProjectName: json['x_customer_project_name'],
      location: json['x_location'] ?? '',
      amount: (json['x_amount'] ?? 0.0).toDouble(),
      expenseDate: DateTime.parse(json['x_expense_date']),
      comments: json['x_comments'] ?? '',
      photoUrl: json['x_photo_url'] ?? '',
      status: _parseBillStatus(json['x_status']),
      userId: json['x_user_id'] ?? '',
      createdAt: DateTime.parse(json['create_date']),
      updatedAt: json['write_date'] != null
          ? DateTime.parse(json['write_date'])
          : null,
      isAdvancePayment: json['x_is_advance_payment'] ?? false,
      advancePurpose: json['x_advance_purpose'],
      expectedAmount: json['x_expected_amount']?.toDouble(),
      parentAdvanceId: json['x_parent_advance_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x_bill_type': billType.name,
      'x_bill_number': billNumber,
      'x_vendor_name': vendorName,
      'x_customer_project_name': customerProjectName,
      'x_location': location,
      'x_amount': amount,
      'x_expense_date': expenseDate.toIso8601String(),
      'x_comments': comments,
      'x_photo_url': photoUrl,
      'x_status': status.name,
      'x_user_id': userId,
      'create_date': createdAt.toIso8601String(),
      'write_date': updatedAt?.toIso8601String(),
      'x_is_advance_payment': isAdvancePayment,
      'x_advance_purpose': advancePurpose,
      'x_expected_amount': expectedAmount,
      'x_parent_advance_id': parentAdvanceId,
    };
  }

  Map<String, dynamic> toOdooJson() {
    final Map<String, dynamic> odooData = {
      'x_bill_type': billType.name,
      'x_bill_number': billNumber,
      'x_vendor_name': vendorName,
      'x_customer_project_name': customerProjectName,
      'x_location': location,
      'x_amount': amount,
      'x_expense_date': expenseDate.toIso8601String().split('T')[0],
      'x_comments': comments,
      'x_photo_url': photoUrl,
      'x_status': status.name,
      'x_user_id': userId,
      'x_is_advance_payment': isAdvancePayment,
      'x_advance_purpose': advancePurpose,
      'x_expected_amount': expectedAmount,
      'x_parent_advance_id': parentAdvanceId,
    };

    odooData.removeWhere((key, value) => value == null);
    return odooData;
  }

  factory PettyCashBillModel.fromEntity(PettyCashBill entity) {
    return PettyCashBillModel(
      id: entity.id,
      billType: entity.billType,
      billNumber: entity.billNumber,
      vendorName: entity.vendorName,
      customerProjectName: entity.customerProjectName,
      location: entity.location,
      amount: entity.amount,
      expenseDate: entity.expenseDate,
      comments: entity.comments,
      photoUrl: entity.photoUrl,
      status: entity.status,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isAdvancePayment: entity.isAdvancePayment,
      advancePurpose: entity.advancePurpose,
      expectedAmount: entity.expectedAmount,
      parentAdvanceId: entity.parentAdvanceId,
    );
  }

  PettyCashBill toEntity() {
    return PettyCashBill(
      id: id,
      billType: billType,
      billNumber: billNumber,
      vendorName: vendorName,
      customerProjectName: customerProjectName,
      location: location,
      amount: amount,
      expenseDate: expenseDate,
      comments: comments,
      photoUrl: photoUrl,
      status: status,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isAdvancePayment: isAdvancePayment,
      advancePurpose: advancePurpose,
      expectedAmount: expectedAmount,
      parentAdvanceId: parentAdvanceId,
    );
  }

  static BillType _parseBillType(String? value) {
    switch (value) {
      case 'materialPurchase':
        return BillType.materialPurchase;
      case 'foodMeals':
        return BillType.foodMeals;
      case 'transportFuel':
        return BillType.transportFuel;
      case 'miscellaneous':
        return BillType.miscellaneous;
      case 'advanceRequest':
        return BillType.advanceRequest;
      default:
        return BillType.miscellaneous;
    }
  }

  static BillStatus _parseBillStatus(String? value) {
    switch (value) {
      case 'pending':
        return BillStatus.pending;
      case 'pendingBillSubmission':
        return BillStatus.pendingBillSubmission;
      case 'billPending':
        return BillStatus.billPending;
      case 'approved':
        return BillStatus.approved;
      case 'rejected':
        return BillStatus.rejected;
      case 'needsClarification':
        return BillStatus.needsClarification;
      default:
        return BillStatus.pending;
    }
  }
}
