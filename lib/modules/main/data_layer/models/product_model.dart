import '../../domain_layer/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.serviceName,
  });

  static ProductModel fromJson(Map<String, dynamic> json) {
    return ProductModel(
      serviceName: json['partner_ref'],
      id: json['id'],
    );
  }
}
