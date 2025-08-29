import 'package:equatable/equatable.dart';

class TaxModel extends Equatable {
  final int id;
  final String name;
  final double? amount;

  const TaxModel({
    required this.id,
    required this.name,
    this.amount,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'] as int,
      name: json['name'] as String,
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (amount != null) 'amount': amount,
    };
  }

  @override
  List<Object?> get props => [id, name, amount];
}
