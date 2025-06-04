import '../../domain_layer/entities/service_type.dart';

class ServiceTypeModel extends ServiceType {
  const ServiceTypeModel({
    required super.quantity,
    required super.productId,
    required super.serviceTypeName,
    super.serviceTypeId,
  });

  Map<String, dynamic> toJson({
    required int faultId,
  }) {
    return {"fault_id": faultId, "product_id": productId, "quantity": quantity};
  }

  static ServiceTypeModel fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      quantity: json["quantity"],
      productId: json["product_id"][0],
      serviceTypeName: json["product_id"][1],
      serviceTypeId: json["id"],
    );
  }
}
