import '../../domain_layer/entities/amc_form.dart';

//ignore: must_be_immutable
class AmcFormModel extends AmcForm {
  AmcFormModel(
      {required super.list,
      required super.propertySite,
      required super.flatNumber,
      required super.acSerialNumber,
      required super.acType,
      super.workStatus,
      required super.brand,
      super.sparesCIds,
      super.sparesC,
      required super.compressorNumber,
      required super.tonnage,
      required super.comments,
      required super.modelNumber,
      required super.signature,
      required super.location,
      super.download,
      super.writeDate,
      required super.attendingTechnician,
      required super.tenantRepresentative,
      super.completeDate});
  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = {
      'ac_serial_number': acSerialNumber,
      'amc_flat_number': flatNumber,
      'location_amc': location,
      "amc_type_of_ac": _getAcType(acType),
      'brand': brand,
      'comments': comments,
      'Spares_c': sparesCIds,
      'compressor_number': compressorNumber,
      'tonnage': tonnage,
      'Attending_Technician': attendingTechnician,
      //'Tenant_Representative': tenantRepresentative,
      'amc_model_number': modelNumber,
      'signature': signature,
      'amc_file': download,
    };
    for (int i = 0; i < list.length; i++) {
      jsonMap['checkbox_${list[i]}'] = true;
    }
    return jsonMap;
  }

  String _getAcType(String acType) {
    switch (acType) {
      case "Split AC":
        {
          return "split";
        }
      case "Window AC":
        {
          return "window";
        }
      case "Cassette AC":
        {
          return "cassette";
        }
      case "Duct AC":
        {
          return "duct";
        }
      case "Central AC":
        {
          return "central";
        }
      case "VRF":
        {
          return "vrf";
        }
      case "Protable AC":
        {
          return "protable";
        }
      case "Floor Stand AC":
        {
          return "floor";
        }
      case "Ceiling Mounted AC":
        {
          return "ceiling";
        }
      case "AHU Unit":
        {
          return "ahu";
        }
      default:
        return "";
    }
  }
}
