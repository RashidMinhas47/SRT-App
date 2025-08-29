import 'package:equatable/equatable.dart';

class AccountModel extends Equatable {
  final int id;
  final String displayName;
  final String? code;

  const AccountModel({
    required this.id,
    required this.displayName,
    this.code,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      if (code != null) 'code': code,
    };
  }

  @override
  List<Object?> get props => [id, displayName, code];
}
