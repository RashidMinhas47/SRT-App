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

class PettyCashModel extends Equatable {
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

  const PettyCashModel({
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
  static String _billTypeToString(BillType type) {
    return type.toString().split('.').last;
  }

  // Convert string to BillType enum
  static BillType _stringToBillType(String type) {
    return BillType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => BillType.miscellaneous,
    );
  }

  // Convert BillStatus enum to string
  static String _billStatusToString(BillStatus status) {
    return status.toString().split('.').last;
  }

  // Convert string to BillStatus enum
  static BillStatus _stringToBillStatus(String status) {
    return BillStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => BillStatus.pending,
    );
  }

  // Factory constructor to create PettyCash from JSON
  factory PettyCashModel.fromJson(Map<String, dynamic> json) {
    return PettyCashModel(
      id: json['id']?.toString(),
      vendorName: json['vendor_name'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      billPhotosBase64: List<String>.from(json['bill_photos_base64'] as List),
      billType: _stringToBillType(json['bill_type'] as String),
      billNumber: json['bill_number']?.toString(),
      customerProjectName: json['customer_project_name']?.toString(),
      location: json['location'] as String,
      comments: json['comments'] as String,
      isAdvanceRequest: json['is_advance_request'] as bool? ?? false,
      advancePurpose: json['advance_purpose']?.toString(),
      expectedAmount: json['expected_amount']?.toDouble(),
      projectCustomerName: json['project_customer_name']?.toString(),
      status: _stringToBillStatus(json['status'] as String),
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert PettyCash to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_name': vendorName,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'bill_photos_base64': billPhotosBase64,
      'bill_type': _billTypeToString(billType),
      'bill_number': billNumber,
      'customer_project_name': customerProjectName,
      'location': location,
      'comments': comments,
      'is_advance_request': isAdvanceRequest,
      'advance_purpose': advancePurpose,
      'expected_amount': expectedAmount,
      'project_customer_name': projectCustomerName,
      'status': _billStatusToString(status),
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Copy with method for immutable updates
  PettyCashModel copyWith({
    String? id,
    String? vendorName,
    String? description,
    double? amount,
    DateTime? date,
    List<String>? billPhotosBase64,
    BillType? billType,
    String? billNumber,
    String? customerProjectName,
    String? location,
    String? comments,
    bool? isAdvanceRequest,
    String? advancePurpose,
    double? expectedAmount,
    String? projectCustomerName,
    BillStatus? status,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PettyCashModel(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      billPhotosBase64: billPhotosBase64 ?? this.billPhotosBase64,
      billType: billType ?? this.billType,
      billNumber: billNumber ?? this.billNumber,
      customerProjectName: customerProjectName ?? this.customerProjectName,
      location: location ?? this.location,
      comments: comments ?? this.comments,
      isAdvanceRequest: isAdvanceRequest ?? this.isAdvanceRequest,
      advancePurpose: advancePurpose ?? this.advancePurpose,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      projectCustomerName: projectCustomerName ?? this.projectCustomerName,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
