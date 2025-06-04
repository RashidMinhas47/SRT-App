import 'package:equatable/equatable.dart';

//ignore: must_be_immutable
class AmcBuilding extends Equatable {
  final int id;
  final int amcCardId;
  int totalAc;
  final List<int> flatNumbers;
  final String property;
  final int numWetServices;
  final int numDryServices;
  final List<int> acTypesIds;
  final List<String> acTypes;
  final Map<String, int> acTotals;
  Map<String, int> acTypeId;
  AmcBuilding({
    required this.totalAc,
    required this.flatNumbers,
    required this.numWetServices,
    required this.numDryServices,
    required this.acTotals,
    required this.id,
    required this.amcCardId,
    required this.acTypes,
    required this.acTypeId,
    required this.property,
    required this.acTypesIds,
  });
  @override
  List<Object?> get props => [
        acTypesIds,
        flatNumbers,
        numWetServices,
        numDryServices,
        acTotals,
        property,
        totalAc,
        acTypeId,
        amcCardId,
        id
      ];
}
