import 'package:equatable/equatable.dart';

class JobCardModel extends Equatable {
  // Job Card states
  static const String STATE_DRAFT = 'draft';
  static const String STATE_IN_PROGRESS = 'in_progress';
  static const String STATE_COMPLETED = 'completed';
  static const String STATE_CANCELLED = 'cancelled';

  // Highlight options
  static const String HIGHLIGHT_YES = 'yes';
  static const String HIGHLIGHT_NO = 'no';

  final String? customerName; // char
  final String? customerMobileNumber; // char
  final String? location; // char
  final int? assignedUserId; // many2one
  final String? customerBuildingName; // char
  final String? customerHouseFlatNumber; // char
  final String? complaintNumber; // char
  final String? workDescription; // text
  final String? highlight; // selection (yes/no)

  // Additional fields
  final int? id;
  final String? state;
  final DateTime? createDate;
  final DateTime? writeDate;

  const JobCardModel({
    this.customerName,
    this.customerMobileNumber,
    this.location,
    this.assignedUserId,
    this.customerBuildingName,
    this.customerHouseFlatNumber,
    this.complaintNumber,
    this.workDescription,
    this.highlight,
    this.id,
    this.state = STATE_DRAFT,
    this.createDate,
    this.writeDate,
  });

  factory JobCardModel.fromJson(Map<String, dynamic> json) {
    return JobCardModel(
      id: json['id'] as int?,
      customerName: json['customer_name'] as String?,
      customerMobileNumber: json['customer_mobile_number'] as String?,
      location: json['location'] as String?,
      assignedUserId: json['assigned_user_id'] != null
          ? json['assigned_user_id'][0] as int
          : null,
      customerBuildingName: json['customer_building_name'] as String?,
      customerHouseFlatNumber: json['customer_house_flat_number'] as String?,
      complaintNumber: json['complaint_number'] as String?,
      workDescription: json['work_description'] as String?,
      highlight: json['highlight'] as String?,
      state: json['state'] as String?,
      createDate: json['create_date'] != null
          ? DateTime.parse(json['create_date'] as String)
          : null,
      writeDate: json['write_date'] != null
          ? DateTime.parse(json['write_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_mobile_number': customerMobileNumber,
      'location': location,
      'assigned_user_id': assignedUserId,
      'customer_building_name': customerBuildingName,
      'customer_house_flat_number': customerHouseFlatNumber,
      'complaint_number': complaintNumber,
      'work_description': workDescription,
      'highlight': highlight,
      'state': state,
    };
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerMobileNumber,
        location,
        assignedUserId,
        customerBuildingName,
        customerHouseFlatNumber,
        complaintNumber,
        workDescription,
        highlight,
        state,
        createDate,
        writeDate,
      ];

  JobCardModel copyWith({
    String? customerName,
    String? customerMobileNumber,
    String? location,
    int? assignedUserId,
    String? customerBuildingName,
    String? customerHouseFlatNumber,
    String? complaintNumber,
    String? workDescription,
    String? highlight,
    int? id,
    String? state,
    DateTime? createDate,
    DateTime? writeDate,
  }) {
    return JobCardModel(
      customerName: customerName ?? this.customerName,
      customerMobileNumber: customerMobileNumber ?? this.customerMobileNumber,
      location: location ?? this.location,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      customerBuildingName: customerBuildingName ?? this.customerBuildingName,
      customerHouseFlatNumber:
          customerHouseFlatNumber ?? this.customerHouseFlatNumber,
      complaintNumber: complaintNumber ?? this.complaintNumber,
      workDescription: workDescription ?? this.workDescription,
      highlight: highlight ?? this.highlight,
      id: id ?? this.id,
      state: state ?? this.state,
      createDate: createDate ?? this.createDate,
      writeDate: writeDate ?? this.writeDate,
    );
  }

  // Helper method to check if job card can be modified
  bool get canModify => state == STATE_DRAFT;

  // Helper method to get highlight display text
  String get highlightDisplayText {
    switch (highlight) {
      case HIGHLIGHT_YES:
        return 'Yes';
      case HIGHLIGHT_NO:
        return 'No';
      default:
        return 'Not Set';
    }
  }
}
