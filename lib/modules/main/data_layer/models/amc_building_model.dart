import '../../domain_layer/entities/amc_building.dart';
//ignore: must_be_immutable
class AmcBuildingModel extends AmcBuilding {
  AmcBuildingModel({
    required super.property,
    required super.acTypesIds,
    required super.acTypes,
    required super.acTotals,
    required super.numDryServices,
    required super.numWetServices,
    required super.totalAc,
    required super.id,
    required super.flatNumbers,
    required super.amcCardId, required super.acTypeId,
  });

  static AmcBuilding fromJson(Map<String, dynamic> json) {
    AmcBuilding building = AmcBuilding(
      totalAc: json["total_ac"] != false ? json["total_ac"]:0,
      id: json["id"],
      numDryServices: json["num_dry_services"] != false ? json["num_dry_services"]:0,
      numWetServices: json["num_wet_services"],
      amcCardId: json["amc_card_id"] != false ? json["amc_card_id"][0] : 1,
      property: json['building_name'] != false ? json['building_name'] : '',
      acTypesIds: List<int>.from(json['ac_types']),
      acTypes: _getAcTypes(json["ac_types_str"]),
      acTotals: _countACTypes(json["ac_types_str"]),
      acTypeId: const {},
      flatNumbers:json['flat_building'] != false ? _parseStringToList(json['flat_building']):[],
    );
    building.acTypeId = _acTypesIds(acTypes: building.acTypesIds, acTypesStr: building.acTypes);
    return building;
  }

  static List<String> _getAcTypes(String typesString) {
    List<String> acTypes = [];
    List<String> acList = typesString.trim().split(",");
    for (String ac in acList) {
      List<String> acInfo = ac.trim().split(":");
      String acType = acInfo[0].trim();
      acTypes.add(handleSubCategory(acType));
    }
    return acTypes;
  }

  static String handleSubCategory(String sub) {
    switch (sub) {
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

  static Map<String, int> _countACTypes(String acString) {
    Map<String, int> acTypeCount = {};
    List<String> acList = acString.trim().split(",");
    for (String ac in acList) {
      List<String> acInfo = ac.trim().split(":");
      String acType = acInfo[0].trim();
      int count = int.parse(acInfo.length >1?  acInfo[1].trim() :"0");
      acTypeCount[acType] = count;
    }
    return acTypeCount;
  }

  static Map<String, int> _acTypesIds({required List<int> acTypes,required List<String> acTypesStr}) {
    Map<String, int> acTypeId = {};
    int i = 0;
    for (var element in acTypesStr) {
      acTypeId.addAll({element: acTypes[i++]});
    }
    return acTypeId;
  }

  static List<int> _parseStringToList(String input) {
    List<String> parts = input.replaceAll('[', '').replaceAll(']', '').split(',');
    List<int> numbers = [];
    for (String part in parts) {
      int number = int.parse(part.trim());
      numbers.add(number);
    }

    return numbers;
  }
}
