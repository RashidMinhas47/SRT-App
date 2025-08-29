import 'package:equatable/equatable.dart';

class TaxType extends Equatable {
  final int id;
  final String name;

  const TaxType({required this.id, required this.name});

  factory TaxType.fromJson(Map<String, dynamic> json) {
    return TaxType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
