import '../../domain_layer/entities/fault_form.dart';

//ignore: must_be_immutable
class FaultFormModel extends FaultForm {
  FaultFormModel({
    super.beforePhotos,
    super.afterPhotos,
    super.afterPhotosFile,
    super.purchaseBillPhotoFile,
    required super.model,
    required super.description,
    required super.technician,
    required super.technician1,
    required super.technician2,
    required super.location,
    required super.signaturePhoto,
    required super.make,
    super.purchaseBillPhoto,
    required super.serialNumber,
    required super.category,
    required super.subCategory,
    super.serviceTypesIds,
    required super.comment,
    super.reportType,
    super.faultId,
    super.serviceTypes,
    super.faultFile,
    super.purchaseBillPhotoIds,
    super.beforePhotosIds,
    super.afterPhotosIds,
  });
  static FaultFormModel fromJson(Map<String, dynamic> json) {
    return FaultFormModel(
        beforePhotosIds:
            json['before_photos_ids'] != false ? List<int>.from(json['before_photos_ids']) : [],
        afterPhotosIds:
            json['after_photos_ids'] != false ? List<int>.from(json['after_photos_ids']) : [],
        model: json['Model'] != false ? json['Model'] : '',
        faultId: json['id'],
        description:
            json['Description_F'] != false ? json['Description_F'] : '',
        technician: json['technician'] != false ? json['technician'] : '',
        technician1: json['technician_1'] != false ? json['technician_1'] : '',
        technician2: json['technician_2'] != false ? json['technician_2'] : '',
        location: json['Location_F'] != false ? json['Location_F'] : '',
        serviceTypesIds:
            json['service_line_ids'] != false ? json['service_line_ids'] : [],
        signaturePhoto: json['signature_f'] != false ? json['signature_f'] : '',
        make: json['Make'] != false ? json['Make'] : '',
        // reportType: json['report_type'] != false ? json['report_type'] : '',
        purchaseBillPhotoIds: json['material_bill_photo_ids'] != false
            ? List<int>.from(json['material_bill_photo_ids'])
            : [],
        serialNumber:
            json['Serial_Number'] != false ? json['Serial_Number'] : '',
        category: json['Category'] != false
            ? _smallToCapitalCategory(json['Category'])
            : '',
        subCategory: json['Sub_Category'] != false
            ? _smallToCapitalSubCategory(json['Sub_Category'])
            : '',
        comment: json['F_comments'] != false ? json['F_comments'] : '');
  }

  Map<String, dynamic> toJson({required int id}) {
    return {
      'Model': model,
      'Description_F': description,
      'Location_F': location,
      'after_photos_ids': afterPhotosIds,
      'before_photos_ids': beforePhotosIds,
      'Make': make,
      'material_bill_photo_ids': purchaseBillPhotoIds,
      'Serial_Number': serialNumber,
      "job_card_id": id,
      'Category': _capitalToSmallCategory(category),
      'Sub_Category': _capitalToSmallSubCategory(subCategory),
      'F_comments': comment,
      "report_type": reportType,
      "signature_f": signaturePhoto,
      'technician': technician,
      "technician_1": technician1,
      "technician_2": technician2,
      "fault_file": faultFile,
    };
  }

  String _capitalToSmallSubCategory(String sub) {
    switch (sub) {
      case "Plumbing":
        {
          return "plumbing";
        }
      case "Carpentry":
        {
          return "carpentry";
        }
      case "Civil Work":
        {
          return "civil_work";
        }
      case "Electrical":
        {
          return "electrical";
        }
      case "Mason":
        {
          return "mason";
        }
      case "Painting":
        {
          return "painting";
        }
      case "Window AC":
        {
          return "window_ac";
        }
      case "Split AC":
        {
          return "split_ac";
        }
      case "Cassette AC":
        {
          return "cassette_ac";
        }
      case "Duct AC":
        {
          return "duct_ac";
        }
      case "Chiller Unit":
        {
          return "chiller_unit";
        }
      case "VRF":
        {
          return "vrf";
        }
      case "Portable AC":
        {
          return "portable_ac";
        }
      case "Floor Stand AC":
        {
          return "floor_stand_ac";
        }
      case "Ceiling Mounted AC":
        {
          return "ceiling_mounted_ac";
        }
      case "Central AC":
        {
          return "central_ac";
        }
      case "AHU Unit":
        {
          return "ahu_unit";
        }
      default:
        return "";
    }
  }

  static String _smallToCapitalSubCategory(String sub) {
    switch (sub) {
      case "plumbing":
        {
          return "Plumbing";
        }
      case "carpentry":
        {
          return "Carpentry";
        }
      case "civil_work":
        {
          return "Civil Work";
        }
      case "electrical":
        {
          return "Electrical";
        }
      case "mason":
        {
          return "Mason";
        }
      case "painting":
        {
          return "Painting";
        }
      case "window_ac":
        {
          return "Window AC";
        }
      case "split_ac":
        {
          return "Split AC";
        }
      case "cassette_ac":
        {
          return "Cassette AC";
        }
      case "duct_ac":
        {
          return "Duct AC";
        }
      case "chiller_unit":
        {
          return "Chiller Unit";
        }
      case "vrf":
        {
          return "VRF";
        }
      case "portable_ac":
        {
          return "Portable AC";
        }
      case "floor_stand_ac":
        {
          return "Floor Stand AC";
        }
      case "ceiling_mounted_ac":
        {
          return "Ceiling Mounted AC";
        }
      case "central_ac":
        {
          return "Central AC";
        }
      case "ahu_unit":
        {
          return "AHU Unit";
        }
      default:
        return "";
    }
  }

  String _capitalToSmallCategory(String category) {
    switch (category) {
      case "MEP":
        return "mep";
      case "Air Condition":
        return "air_condition";
      default:
        return "";
    }
  }

  static String _smallToCapitalCategory(String category) {
    switch (category) {
      case "mep":
        return "MEP";
      case "air_condition":
        return "Air Condition";
      default:
        return "";
    }
  }
}
