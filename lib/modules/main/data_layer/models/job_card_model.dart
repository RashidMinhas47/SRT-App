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
    try {
      // Safe handling of fault_ids
      List<int> faultIds = [];
      if (json["fault_ids"] != false && json["fault_ids"] != null) {
        if (json["fault_ids"] is List) {
          try {
            faultIds = List<int>.from(json["fault_ids"]);
          } catch (e) {
            print(
                '⚠️ Warning: Could not parse fault_ids: ${json["fault_ids"]}');
            faultIds = [];
          }
        }
      }

      // Safe handling of assigned_user_id
      int assignedUserId = -1;
      if (json["assigned_user_id"] != false &&
          json["assigned_user_id"] != null) {
        if (json["assigned_user_id"] is List &&
            (json["assigned_user_id"] as List).isNotEmpty) {
          assignedUserId = json["assigned_user_id"][0];
        } else if (json["assigned_user_id"] is int) {
          assignedUserId = json["assigned_user_id"];
        }
      }

      // Safe handling of customer_name
      List customerName = [0, ''];
      if (json['customer_name'] != false && json['customer_name'] != null) {
        if (json['customer_name'] is List) {
          customerName = json['customer_name'];
        } else {
          customerName = [0, json['customer_name'].toString()];
        }
      }

      return JobCard(
        faultIds: faultIds,
        assignedUserId: assignedUserId,
        description: _safeString(json, 'work_description'),
        location: _safeString(json, 'location'),
        revisit: _safeBool(json, 'revisit'),
        startWork: _safeBool(json, 'start_work'),
        faultFile: _safeString(json, 'Attending_Technician'),
        action: _safeString(json, 'action'),
        amcFile: _safeString(json, 'amc_file'),
        userName: _safeString(json, 'User_name'),
        id: _safeInt(json, 'id'),
        comment: _safeString(json, 'comments'),
        quotationStatus: _safeString(json, 'quotation_status'),
        writeDate: _safeString(json, 'write_date'),
        brand: _safeString(json, 'brand'),
        phoneNumber: _safeString(json, 'customer_mobile_number'),
        reportType: _safeString(json, 'report_type'),
        buildingNumber: _safeString(json, 'customer_building_number'),
        complaintNumber: _safeString(json, 'complaint_number'),
        jobCardNumber: _safeString(json, 'job_card_number'),
        flatNumber: _safeString(json, 'customer_house_flat_number'),
        customerName: customerName,
      );
    } catch (e) {
      print('❌ Error parsing job card: $e');
      print('❌ JSON data: ${json.toString()}');
      rethrow;
    }
  }

  // Helper methods for safe parsing
  static String _safeString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == false || value == null) return '';
    return value.toString();
  }

  static int _safeInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == false || value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _safeBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == false || value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }
}
