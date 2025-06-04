import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data_layer/models/service_type_model.dart';
//ignore: must_be_immutable
class FaultForm extends Equatable {
  String description;
  String model;
  String subCategory;
  String category;
  String technician;
  String technician1;
  String technician2;
  String make;
  List<ServiceTypeModel>? serviceTypes;
  List<dynamic>? serviceTypesIds;
  String serialNumber;
  List<String>? beforePhotos;
  List<String>? beforePhotosMemory = [];
  List<String>? afterPhotos;
  List<String>? afterPhotosMemory = [];
  List<File>? afterPhotosFile;
  List<File>? purchaseBillPhotoFile;
  List<int>? beforePhotosIds;
  List<int>? afterPhotosIds;
  String location;
  String? comment;
  String? faultFile;
  int? faultId;
  List<String> ?purchaseBillPhoto;
  List<String>? purchaseBillPhotoMemory = [];
  List<int>? purchaseBillPhotoIds;
  String? reportType;
  String signaturePhoto;
  FaultForm({
    required this.signaturePhoto,
    this.purchaseBillPhotoIds,
    this.beforePhotosIds,
    this.faultId,
    this.afterPhotosIds,
    this.purchaseBillPhotoFile,
    this.afterPhotosFile,
    this.faultFile,
    this.serviceTypes,
    required this.comment,
    required this.model,
    required this.technician,
    required this.technician1,
    required this.technician2,
    required this.description,
    this.serviceTypesIds,
    required this.location,
    this.afterPhotos,
    this.afterPhotosMemory,
    this.beforePhotos,
    this.beforePhotosMemory,
    required this.make,
    this.purchaseBillPhoto,
    this.purchaseBillPhotoMemory,
    required this.serialNumber,
    required this.subCategory,
    required this.category,
    this.reportType,
  });

  @override
  List<Object?> get props =>
      [comment, reportType, category, model,serviceTypesIds, description, location];
}
