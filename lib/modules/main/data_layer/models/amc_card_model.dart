import 'package:bayanat/modules/main/domain_layer/entities/amc_card.dart';

class AmcCardModel extends AmcCard {
  const AmcCardModel({
    required super.companyName,
    required super.property,
    required super.amcFile,
    required super.id,
    required super.totalAc,
  });
  static AmcCardModel fromJson(Map<String, dynamic> json) {
    return AmcCardModel(
      companyName: json['company_name']!= false ? json['company_name'] : '',
      amcFile: json['amc_file_c']!= false ? json['amc_file_c'] : '',
      id: json['id']!= false ? json['id'] : 0,
      property: json['Property_Site_a']!= false ? json['Property_Site_a'] : '',
      totalAc: json['total_ac']!= false ? json['total_ac'] : '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
