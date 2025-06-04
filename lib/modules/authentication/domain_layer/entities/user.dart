import 'package:equatable/equatable.dart';

//ignore: must_be_immutable
class AppUser extends Equatable {
  final String name;
  final String email;
  final String studentPhone;
  final String parentPhone;
  final int grade;

  List<String>? ongoing;
  List<String>? cart;

  List<String>? savedVideos;

  List<String>? savedFiles;

  AppUser(
      {this.ongoing,
      this.savedFiles,
      this.savedVideos,
      required this.name,
      required this.email,
      required this.parentPhone,
      required this.studentPhone,
      required this.grade,
      this.cart});

  @override
  List<Object?> get props => [
        name,
        email,
        parentPhone,
        studentPhone,
        grade,
        ongoing,
        savedVideos,
        savedFiles
      ];
}
