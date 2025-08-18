import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';

//ignore: must_be_immutable
class JobCardModel extends JobCard {
  JobCardModel({
    required super.description,
    required super.action,
    required super.location,
    required super.phoneNumber,
    required super.assignedUserId,
    required super.quotationStatus,
    required super.brand,
    required super.id,
    super.comment,
    required super.buildingNumber,
    required super.complaintNumber,
    required super.jobCardNumber,
    required super.customerName,
    required super.flatNumber,
    required super.faultIds,
    required super.reportType,
    required super.userName,
    required super.writeDate,
    required super.startWork,
    required super.revisit,
    super.faultFile,
    super.amcFile,
  });

//fault_file
  static JobCard fromJson(Map<String, dynamic> json) {
    return JobCard(
      faultIds: List<int>.from(json["fault_ids"]),
      assignedUserId:
          json["assigned_user_id"] != false ? json["assigned_user_id"][0] : -1,
      description:
          json['work_description'] != false ? json['work_description'] : '',
      location: json['location'] != false ? json['location'] : '',
      revisit: json['revisit'],
      startWork: json['start_work'],
      faultFile: json['Attending_Technician'] != false
          ? json['Attending_Technician']
          : '',
      action: json['action'] != false ? json['action'] : '',
      amcFile: json['amc_file'] != false ? json['amc_file'] : '',
      userName: json['User_name'] != false ? json['User_name'] : '',
      id: json['id'] != false ? json['id'] : 0,
      comment: json['comments'] != false ? json['comments'] : '',
      quotationStatus:
          json['quotation_status'] != false ? json['quotation_status'] : '',
      writeDate: json['write_date'] != false ? json['write_date'] : '',
      brand: json['brand'] != false ? json['brand'] : '',
      phoneNumber: json['customer_mobile_number'] != false
          ? json['customer_mobile_number']
          : '',
      reportType: json['report_type'] != false ? json['report_type'] : '',
      buildingNumber: json['customer_building_number'] != false
          ? json['customer_building_number']
          : '',
      complaintNumber:
          json['complaint_number'] != false ? json['complaint_number'] : '',
      jobCardNumber:
          json['job_card_number'] != false ? json['job_card_number'] : '',
      flatNumber: json['customer_house_flat_number'] != false
          ? json['customer_house_flat_number']
          : '',
      customerName:
          json['customer_name'] != false ? json['customer_name'] : [0, ''],
    );
  }
}
