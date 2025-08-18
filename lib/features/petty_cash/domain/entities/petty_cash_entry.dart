import 'package:equatable/equatable.dart';

/// Indicates whether the petty cash request is a regular bill reimbursement
/// or an advance payment request.
enum PettyCashType {
  regularBill,
  advancePayment,
}

/// Domain entity for a petty cash entry. Designed to support both regular
/// bill reimbursements and advance payments while remaining extensible.
class PettyCashEntry extends Equatable {
  /// What kind of petty cash entry this is.
  final PettyCashType type;

  /// Amount requested or claimed.
  final double amount;

  /// Transaction or request date (yyyy-MM-dd).
  final DateTime date;

  /// High-level description/purpose for the entry.
  final String description;

  /// User submitting the entry (repository can map to the current user if null).
  final int? submittedByUserId;

  /// Optional linkage to a project/job/task if applicable.
  final int? referenceId;

  /// Currency code (e.g. "USD"). If null, the backend default will be used.
  final String? currencyCode;

  /// Optional vendor/supplier name for regular bills.
  final String? vendorName;

  /// Optional invoice/receipt number for regular bills.
  final String? invoiceNumber;

  /// When submitting, you may include bill images as base64.
  /// Repository layer can convert these into attachment IDs.
  final List<String> billPhotosBase64;

  /// Existing attachment IDs (if editing or augmenting an existing entry).
  final List<int>? attachmentIds;

  /// For advance payments: expected date to settle the advance.
  final DateTime? expectedSettlementDate;

  /// For advance payments: additional remarks about settlement.
  final String? settlementNotes;

  /// Optional backend identifier (when reading/updating existing entries).
  final int? id;

  const PettyCashEntry({
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.submittedByUserId,
    this.referenceId,
    this.currencyCode,
    this.vendorName,
    this.invoiceNumber,
    this.billPhotosBase64 = const [],
    this.attachmentIds,
    this.expectedSettlementDate,
    this.settlementNotes,
    this.id,
  });

  /// Convenience guards for UI/domain validation
  bool get isRegularBill => type == PettyCashType.regularBill;
  bool get isAdvancePayment => type == PettyCashType.advancePayment;

  PettyCashEntry copyWith({
    PettyCashType? type,
    double? amount,
    DateTime? date,
    String? description,
    int? submittedByUserId,
    int? referenceId,
    String? currencyCode,
    String? vendorName,
    String? invoiceNumber,
    List<String>? billPhotosBase64,
    List<int>? attachmentIds,
    DateTime? expectedSettlementDate,
    String? settlementNotes,
    int? id,
  }) {
    return PettyCashEntry(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      submittedByUserId: submittedByUserId ?? this.submittedByUserId,
      referenceId: referenceId ?? this.referenceId,
      currencyCode: currencyCode ?? this.currencyCode,
      vendorName: vendorName ?? this.vendorName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      billPhotosBase64: billPhotosBase64 ?? this.billPhotosBase64,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      expectedSettlementDate:
          expectedSettlementDate ?? this.expectedSettlementDate,
      settlementNotes: settlementNotes ?? this.settlementNotes,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        type,
        amount,
        date,
        description,
        submittedByUserId,
        referenceId,
        currencyCode,
        vendorName,
        invoiceNumber,
        billPhotosBase64,
        attachmentIds,
        expectedSettlementDate,
        settlementNotes,
        id,
      ];
}

