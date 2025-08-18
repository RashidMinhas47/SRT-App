import 'package:bayanat/modules/main/data_layer/models/spare_c_model.dart';
import 'package:equatable/equatable.dart';

//ignore: must_be_immutable
class AmcForm extends Equatable {
  final String propertySite; //
  final String acType; //
  final double tonnage;
  final String brand;
  String? workStatus;
  final String modelNumber;
  final String flatNumber;
  final String location;
  final String acSerialNumber;
  String? signature;
  String? download;
  final String compressorNumber;
  final String comments;
  String? writeDate;
  final String attendingTechnician;
  final String tenantRepresentative;
  String? completeDate;
  final List<int> list;
  List<int>? sparesCIds;
  List<SpareCModel>? sparesC;
  AmcForm({
    required this.list,
    required this.signature,
    required this.location,
    this.sparesCIds,
    this.workStatus,
    this.sparesC,
    required this.flatNumber,
    required this.propertySite,
    required this.acSerialNumber,
    required this.acType,
    required this.attendingTechnician,
    required this.tenantRepresentative,
    required this.brand,
    this.writeDate,
    this.completeDate,
    required this.compressorNumber,
    required this.comments,
    this.download,
    required this.tonnage,
    required this.modelNumber,
    //required this.dateTime,
  });
  @override
  List<Object?> get props => [flatNumber,list,acSerialNumber,acType,brand,compressorNumber,tonnage,modelNumber];
}
