import 'package:equatable/equatable.dart';

class ServiceType extends Equatable {
  final double quantity;
  final String serviceTypeName;
  final int? serviceTypeId;
  final int productId;
  const ServiceType({
    required this.quantity,
    required this.serviceTypeName,
    required this.serviceTypeId,
    required this.productId,
  });

  @override
  List<Object?> get props => [quantity,productId, serviceTypeName];
}
