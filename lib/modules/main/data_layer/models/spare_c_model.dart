import 'package:bayanat/modules/main/domain_layer/entities/spare_c.dart';

class SpareCModel extends SpareC {
  const SpareCModel({
    required super.quantity,
    required super.spareName,
  });

  Map<String, dynamic> toJson({required int id}) {
    return {
      'quantity': quantity,
      'name': spareName,
      'amc_report_id': id,
    };
  }
}