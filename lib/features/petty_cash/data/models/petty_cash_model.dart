import '../../domain/entities/petty_cash_entry.dart';

class PettyCashModel extends PettyCashEntry {
  const PettyCashModel({
    required super.type,
    required super.amount,
    required super.date,
    required super.description,
    super.submittedByUserId,
    super.referenceId,
    super.currencyCode,
    super.vendorName,
    super.invoiceNumber,
    super.billPhotosBase64 = const [],
    super.attachmentIds,
    super.expectedSettlementDate,
    super.settlementNotes,
    super.id,
  });

  /// Odoo uses strings or selection values for enums; we map the enum to string.
  static String _typeToString(PettyCashType type) {
    switch (type) {
      case PettyCashType.advancePayment:
        return 'advance';
      case PettyCashType.regularBill:
      default:
        return 'regular';
    }
  }

  static PettyCashType _typeFromString(String? value) {
    switch (value) {
      case 'advance':
        return PettyCashType.advancePayment;
      case 'regular':
      default:
        return PettyCashType.regularBill;
    }
  }

  /// Map model to the payload expected by Odoo "create/write" operations.
  /// Attachments are handled separately; pass [attachmentIds] if already uploaded.
  Map<String, dynamic> toJson() {
    return {
      'type': _typeToString(type),
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
      'description': description,
      if (submittedByUserId != null) 'submitted_by': submittedByUserId,
      if (referenceId != null) 'reference_id': referenceId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (vendorName != null) 'vendor_name': vendorName,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (attachmentIds != null) 'attachment_ids': attachmentIds,
      if (expectedSettlementDate != null)
        'expected_settlement_date':
            expectedSettlementDate!.toIso8601String().split('T').first,
      if (settlementNotes != null) 'settlement_notes': settlementNotes,
    };
  }

  static PettyCashModel fromJson(Map<String, dynamic> json) {
    return PettyCashModel(
      id: json['id'] is int ? json['id'] as int : null,
      type: _typeFromString(json['type'] as String?),
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      description: (json['description'] ?? '').toString(),
      submittedByUserId: json['submitted_by'] is int ? json['submitted_by'] : null,
      referenceId: json['reference_id'] is int ? json['reference_id'] : null,
      currencyCode: json['currency_code']?.toString(),
      vendorName: json['vendor_name']?.toString(),
      invoiceNumber: json['invoice_number']?.toString(),
      billPhotosBase64: const [], // not returned by backend
      attachmentIds: (json['attachment_ids'] is List)
          ? List<int>.from(json['attachment_ids'])
          : null,
      expectedSettlementDate:
          DateTime.tryParse(json['expected_settlement_date']?.toString() ?? ''),
      settlementNotes: json['settlement_notes']?.toString(),
    );
  }
}

