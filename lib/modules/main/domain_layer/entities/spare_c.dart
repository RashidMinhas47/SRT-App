import 'package:equatable/equatable.dart';

class SpareC extends Equatable {
  final int quantity;
  final String spareName;
  const SpareC({
    required this.quantity,
    required this.spareName,
  });

  @override
  List<Object?> get props => [quantity, spareName];
}
