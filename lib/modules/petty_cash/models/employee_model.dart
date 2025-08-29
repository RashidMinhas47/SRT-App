import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final int id;
  final String name;
  final int? userId;

  const EmployeeModel({
    required this.id,
    required this.name,
    this.userId,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      userId: json['user_id'] != null && json['user_id'] is List && (json['user_id'] as List).isNotEmpty
          ? json['user_id'][0] as int
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, userId];
}

// class EmployeeModel {
//   final bool? active;
//   final int? activityCalendarEventId;
//   final String? activityDateDeadline;
//   final String? activityExceptionDecoration;
//   final String? activityExceptionIcon;
//   final List<int>? activityIds;
//   final String? activityState;
//   final String? activitySummary;
//   final String? activityTypeIcon;
//   final int? activityTypeId;
//   final int? activityUserId;
//   final String? additionalNote;
//   final int? addressHomeId;
//   final int? addressId;
//   final int? allocationCount;
//   final String? allocationDisplay;
//   final String? allocationRemainingDisplay;
//   final int? allocationsCount;
//   final int? applicantId;
//   final String? avatar1024;
//   final String? avatar128;
//   final String? avatar1920;
//   final String? avatar256;
//   final String? avatar512;
//   final List<int>? badgeIds;
//   final int? bankAccountId;
//   final String? barcode;
//   final String? birthday;
//   final bool? calendarMismatch;
//   final List<int>? carIds;
//   final List<int>? categoryIds;
//   final String? certificate;
//   final int? childAllCount;
//   final List<int>? childIds;
//   final List<int>? children;
//   final int? coachId;
//   final String? color;
//   final String? companyCountryCode;
//   final int? companyCountryId;
//   final int? companyId;

//   EmployeeModel({
//     this.active,
//     this.activityCalendarEventId,
//     this.activityDateDeadline,
//     this.activityExceptionDecoration,
//     this.activityExceptionIcon,
//     this.activityIds,
//     this.activityState,
//     this.activitySummary,
//     this.activityTypeIcon,
//     this.activityTypeId,
//     this.activityUserId,
//     this.additionalNote,
//     this.addressHomeId,
//     this.addressId,
//     this.allocationCount,
//     this.allocationDisplay,
//     this.allocationRemainingDisplay,
//     this.allocationsCount,
//     this.applicantId,
//     this.avatar1024,
//     this.avatar128,
//     this.avatar1920,
//     this.avatar256,
//     this.avatar512,
//     this.badgeIds,
//     this.bankAccountId,
//     this.barcode,
//     this.birthday,
//     this.calendarMismatch,
//     this.carIds,
//     this.categoryIds,
//     this.certificate,
//     this.childAllCount,
//     this.childIds,
//     this.children,
//     this.coachId,
//     this.color,
//     this.companyCountryCode,
//     this.companyCountryId,
//     this.companyId,
//   });

//   factory EmployeeModel.fromJson(Map<String, dynamic> json) {
//     return EmployeeModel(
//       active: json['active'] as bool?,
//       activityCalendarEventId: json['activity_calendar_event_id'] as int?,
//       activityDateDeadline: json['activity_date_deadline'] as String?,
//       activityExceptionDecoration:
//           json['activity_exception_decoration'] as String?,
//       activityExceptionIcon: json['activity_exception_icon'] as String?,
//       activityIds: (json['activity_ids'] as List<dynamic>?)
//           ?.map((e) => e as int)
//           .toList(),
//       activityState: json['activity_state'] as String?,
//       activitySummary: json['activity_summary'] as String?,
//       activityTypeIcon: json['activity_type_icon'] as String?,
//       activityTypeId: json['activity_type_id'] as int?,
//       activityUserId: json['activity_user_id'] as int?,
//       additionalNote: json['additional_note'] as String?,
//       addressHomeId: json['address_home_id'] as int?,
//       addressId: json['address_id'] as int?,
//       allocationCount: json['allocation_count'] as int?,
//       allocationDisplay: json['allocation_display'] as String?,
//       allocationRemainingDisplay:
//           json['allocation_remaining_display'] as String?,
//       allocationsCount: json['allocations_count'] as int?,
//       applicantId: json['applicant_id'] as int?,
//       avatar1024: json['avatar_1024'] as String?,
//       avatar128: json['avatar_128'] as String?,
//       avatar1920: json['avatar_1920'] as String?,
//       avatar256: json['avatar_256'] as String?,
//       avatar512: json['avatar_512'] as String?,
//       badgeIds:
//           (json['badge_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
//       bankAccountId: json['bank_account_id'] as int?,
//       barcode: json['barcode'] as String?,
//       birthday: json['birthday'] as String?,
//       calendarMismatch: json['calendar_mismatch'] as bool?,
//       carIds:
//           (json['car_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
//       categoryIds: (json['category_ids'] as List<dynamic>?)
//           ?.map((e) => e as int)
//           .toList(),
//       certificate: json['certificate'] as String?,
//       childAllCount: json['child_all_count'] as int?,
//       childIds:
//           (json['child_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
//       children:
//           (json['children'] as List<dynamic>?)?.map((e) => e as int).toList(),
//       coachId: json['coach_id'] as int?,
//       color: json['color'] as String?,
//       companyCountryCode: json['company_country_code'] as String?,
//       companyCountryId: json['company_country_id'] as int?,
//       companyId: json['company_id'] as int?,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'active': active,
//       'activity_calendar_event_id': activityCalendarEventId,
//       'activity_date_deadline': activityDateDeadline,
//       'activity_exception_decoration': activityExceptionDecoration,
//       'activity_exception_icon': activityExceptionIcon,
//       'activity_ids': activityIds,
//       'activity_state': activityState,
//       'activity_summary': activitySummary,
//       'activity_type_icon': activityTypeIcon,
//       'activity_type_id': activityTypeId,
//       'activity_user_id': activityUserId,
//       'additional_note': additionalNote,
//       'address_home_id': addressHomeId,
//       'address_id': addressId,
//       'allocation_count': allocationCount,
//       'allocation_display': allocationDisplay,
//       'allocation_remaining_display': allocationRemainingDisplay,
//       'allocations_count': allocationsCount,
//       'applicant_id': applicantId,
//       'avatar_1024': avatar1024,
//       'avatar_128': avatar128,
//       'avatar_1920': avatar1920,
//       'avatar_256': avatar256,
//       'avatar_512': avatar512,
//       'badge_ids': badgeIds,
//       'bank_account_id': bankAccountId,
//       'barcode': barcode,
//       'birthday': birthday,
//       'calendar_mismatch': calendarMismatch,
//       'car_ids': carIds,
//       'category_ids': categoryIds,
//       'certificate': certificate,
//       'child_all_count': childAllCount,
//       'child_ids': childIds,
//       'children': children,
//       'coach_id': coachId,
//       'color': color,
//       'company_country_code': companyCountryCode,
//       'company_country_id': companyCountryId,
//       'company_id': companyId,
//     };
//   }
// }
