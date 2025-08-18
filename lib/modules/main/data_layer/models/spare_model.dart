import '../../domain_layer/entities/spare.dart';

class SpareModel extends Spare {
  const SpareModel({
    required super.id,
    required super.spareName,
  });

  static SpareModel fromJson(Map<String, dynamic> json) {
    return SpareModel(
      spareName: json['name'],
      id: json['id'],
    );
  }
}
