import 'package:equatable/equatable.dart';

class AmcCard extends Equatable {
  final String companyName;
  final int id;
  final int totalAc;
  final String amcFile;
  final String property;
  const AmcCard({
    required this.companyName,
    required this.amcFile,
    required this.id,
    required this.totalAc,
    required this.property,
  });
  @override
  List<Object?> get props => [
        companyName,
        amcFile,
        property,
        totalAc,
        id,
      ];
}
