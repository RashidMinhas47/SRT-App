import 'package:equatable/equatable.dart';

class HrExpenseModel extends Equatable {
  // Add enum for expense states
  static const String STATE_DRAFT = 'draft';
  static const String STATE_SUBMITTED = 'submitted';
  static const String STATE_APPROVED = 'approved';
  static const String STATE_REFUSED = 'refused';
  static const String STATE_DONE = 'done';

  final String? name; // description (char)
  final int? productId; // Category (many2one)
  final List<int>? taxIds; // Included tax (many2many)
  final int? employeeId; // Employee (many2one)
  final int? empId; // Employee ID for payment (many2one)
  final String? paymentMode; // 'company' or 'employee'
  final String? reference; // Bill Reference (char)
  final int? accountId; // Account (many2one)

  // Additional useful fields
  final int? id;
  final double? amount;
  final DateTime? date;
  final String? state;
  final String? companyId;

  const HrExpenseModel({
    this.name,
    this.productId,
    this.taxIds,
    this.employeeId,
    this.empId,
    this.paymentMode = 'company_account',
    this.reference,
    this.accountId,
    this.id,
    this.amount,
    this.date,
    this.state = STATE_DRAFT, // Default to draft
    this.companyId,
  });

  factory HrExpenseModel.fromJson(Map<String, dynamic> json) {
    return HrExpenseModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      productId:
          json['product_id'] != null ? json['product_id'][0] as int : null,
      taxIds:
          (json['tax_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
      employeeId:
          json['employee_id'] != null ? json['employee_id'][0] as int : null,
      empId: json['emp_id'] != null ? json['emp_id'][0] as int : null,
      paymentMode: json['payment_mode'] as String?,
      reference: json['reference'] as String?,
      accountId:
          json['account_id'] != null ? json['account_id'][0] as int : null,
      amount: (json['total_amount'] as num?)?.toDouble(),
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      state: json['state'] as String?,
      companyId:
          json['company_id'] != null ? json['company_id'][0] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'product_id': productId,
      'tax_ids': taxIds != null ? [taxIds] : [], // Odoo format for many2many
      'employee_id': employeeId,
      'emp_id': empId,
      'payment_mode': paymentMode?.toLowerCase() == 'company'
          ? 'company_account'
          : 'employee',
      'reference': reference,
      'account_id': accountId,
      'date': date?.toIso8601String(),
      'total_amount': amount,
      'company_id': companyId,
      'state': state,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        productId,
        taxIds,
        employeeId,
        empId,
        paymentMode,
        reference,
        accountId,
        amount,
        date,
        state,
        companyId,
      ];

  HrExpenseModel copyWith({
    String? name,
    int? productId,
    List<int>? taxIds,
    int? employeeId,
    int? empId,
    String? paymentMode,
    String? reference,
    int? accountId,
    int? id,
    double? amount,
    DateTime? date,
    String? state,
    String? companyId,
  }) {
    return HrExpenseModel(
      name: name ?? this.name,
      productId: productId ?? this.productId,
      taxIds: taxIds ?? this.taxIds,
      employeeId: employeeId ?? this.employeeId,
      empId: empId ?? this.empId,
      paymentMode: paymentMode ?? this.paymentMode,
      reference: reference ?? this.reference,
      accountId: accountId ?? this.accountId,
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      state: state ?? this.state,
      companyId: companyId ?? this.companyId,
    );
  }

  // Add helper method to archive instead of delete
  // HrExpenseModel archive() {
  //   return copyWith(active: false);
  // }

  // Add helper method to check if expense can be modified
  bool get canModify => state == STATE_DRAFT;
}
