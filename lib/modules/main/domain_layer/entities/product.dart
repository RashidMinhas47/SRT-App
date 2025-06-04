import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String serviceName;
  const Product({
    required this.id,
    required this.serviceName,
  });

  @override
  List<Object?> get props => [id, serviceName];
}
