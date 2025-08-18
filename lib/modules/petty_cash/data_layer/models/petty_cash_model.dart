import '../../domain_layer/entities/petty_cash.dart';

class PettyCashModel extends PettyCash {
  const PettyCashModel({
    required super.vendorName,
    required super.description,
    required super.amount,
    required super.date,
    required super.billPhotosBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      "vendor_name": vendorName,
      "description": description,
      "amount": amount,
      "date": date.toIso8601String().split('T').first,
      // attachments handled separately, send IDs here if needed
    };
  }
}

