import '../../domain_layer/entities/amc_ac_checklist.dart';
//ignore: must_be_immutable
class AmcAcCheckListModel extends AmcAcCheckList {
  AmcAcCheckListModel({
    required super.acType,
    required super.id,
    required super.location,
    required super.modelNumber,
    required super.numServices,
    required super.acSerialNumber,
    required super.list,
    required super.attendingTechnician,
    required super.signature,
    required super.flatNumber,
    required super.tenantRepresentative,
    required super.writeDate,
    required super.property,
    super.amcFile,
    required super.comments,
  });

  Map<String, dynamic> toJson({required int amcCardId}) {
    Map<String, dynamic> jsonMap = {
      'ac_serial_number': acSerialNumber,
      'amc_card_id': amcCardId,
      'ac_type': handleSubCategory(acType),
      'building_name_': property,
      'Attending_Technician_1': attendingTechnician,
      'flat_number_b': flatNumber,
      'write_date': writeDate,
      //'Tenant_Representative_1': tenantRepresentative,
      'signature_c': signature,
      'comments_c': comments,
      "location": location,
      "amc_file_": amcFile,
      'model_number': modelNumber,
    };
    for (int i = 0; i < super.list.length; i++) {
      jsonMap['q${list[i]}'] = true;
    }
    return jsonMap;
  }
  static String handleSubCategory(String sub) {
    switch (sub) {
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
}
