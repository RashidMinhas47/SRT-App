import 'package:equatable/equatable.dart';
//ignore: must_be_immutable
class AmcAcCheckList extends Equatable {
  final String acType;
  final int id;
  final String location;
  final String property;
  final String flatNumber;
  final String modelNumber;
  final String numServices;
  String? amcFile;
  final String attendingTechnician;
  final String acSerialNumber;
  final String tenantRepresentative;
  final String writeDate;
  final String comments;
  final String signature;
  final List<int> list;
  AmcAcCheckList({
    required this.acType,
    required this.property,
    required this.attendingTechnician,
    required this.id,
    required this.writeDate,
    required this.numServices,
    required this.signature,
    this.amcFile,
    required this.location,
    required this.flatNumber,
    required this.modelNumber,
    required this.tenantRepresentative,
    required this.comments,
    required this.acSerialNumber,
    required this.list,
  });
  @override
  List<Object?> get props => [
    numServices,
        acType,
        id,
        flatNumber,
    writeDate,
        signature,amcFile,
        comments,
        attendingTechnician,
        tenantRepresentative,
        location,
        modelNumber,
        acSerialNumber,
        list,
      ];
}
