import 'package:equatable/equatable.dart';

//ignore: must_be_immutable
class JobCard extends Equatable {
  final List customerName;
  final String location;
  final String userName;
  final String brand;
  final int assignedUserId;
  final String quotationStatus;
  String? comment;
  final String flatNumber;
  String? faultFile;
  String? amcFile;
  final String action;
  final String phoneNumber;
  final String writeDate;
  final List<int> faultIds;
  final int id;
  final bool revisit;
  final bool startWork;
  final String buildingNumber;
  final String complaintNumber;
  final String jobCardNumber;
  final String description;
  String reportType;

  JobCard({
    required this.phoneNumber,
    required this.buildingNumber,
    required this.startWork,
    required this.revisit,
    required this.userName,
    required this.assignedUserId,
    required this.faultIds,
    required this.brand,
    this.faultFile,
    required this.quotationStatus,
    this.amcFile,
    required this.action,
    required this.complaintNumber,
    required this.jobCardNumber,
    required this.description,
    required this.writeDate,
    required this.reportType,
    required this.id,
    this.comment,
    required this.customerName,
    required this.location,
    required this.flatNumber,
  });
  @override
  List<Object?> get props => [
        action,
        id,
        writeDate,
        assignedUserId,
        description,
        comment,
        jobCardNumber,
        complaintNumber,
        buildingNumber,
        phoneNumber,
        customerName,
        location,
        flatNumber
      ];
}
