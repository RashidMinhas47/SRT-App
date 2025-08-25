import '../../domain_layer/entities/petty_cash.dart';

class PettyCashModel extends PettyCash {
  const PettyCashModel({
    super.id,
    required super.vendorName,
    required super.description,
    required super.amount,
    required super.date,
    required super.billPhotosBase64,
    required super.billType,
    super.billNumber,
    super.customerProjectName,
    required super.location,
    required super.comments,
    super.isAdvanceRequest = false,
    super.advancePurpose,
    super.expectedAmount,
    super.projectCustomerName,
    super.status = BillStatus.pending,
    required super.userId,
    required super.createdAt,
    super.updatedAt,
  });

  factory PettyCashModel.fromJson(Map<String, dynamic> json) {
    return PettyCashModel(
      id: json['id']?.toString(),
      vendorName: json['x_vendor_name'] ?? '',
      description: json['x_description'] ?? '',
      amount: (json['x_amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['x_date']),
      billPhotosBase64: [], // Will be handled separately
      billType: _parseBillType(json['x_bill_type']),
      billNumber: json['x_bill_number'],
      customerProjectName: json['x_customer_project_name'],
      location: json['x_location'] ?? '',
      comments: json['x_comments'] ?? '',
      isAdvanceRequest: json['x_is_advance_request'] ?? false,
      advancePurpose: json['x_advance_purpose'],
      expectedAmount: json['x_expected_amount']?.toDouble(),
      projectCustomerName: json['x_project_customer_name'],
      status: _parseBillStatus(json['x_status']),
      userId: json['x_user_id'] ?? '',
      createdAt: DateTime.parse(json['create_date']),
      updatedAt: json['write_date'] != null
          ? DateTime.parse(json['write_date'])
          : null,
    );
  }

  static BillType _parseBillType(String? type) {
    switch (type) {
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

  static BillStatus _parseBillStatus(String? status) {
    switch (status) {
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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "vendor_name": vendorName,
      "description": description,
      "amount": amount,
      "date": date.toIso8601String().split('T').first,
      "bill_type": billType.name,
      "bill_number": billNumber,
      "customer_project_name": customerProjectName,
      "location": location,
      "comments": comments,
      "is_advance_request": isAdvanceRequest,
      "advance_purpose": advancePurpose,
      "expected_amount": expectedAmount,
      "project_customer_name": projectCustomerName,
      "status": status.name,
      "user_id": userId,
      "create_date": createdAt.toIso8601String(),
      "write_date": updatedAt?.toIso8601String(),
      // attachments handled separately, send IDs here if needed
    };
  }
}
