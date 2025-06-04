import 'package:equatable/equatable.dart';
//ignore: must_be_immutable
class Auth extends Equatable {
  String uid;
  String token;

  Auth({
    required this.uid,
    required this.token,
  });

  @override
  List<Object?> get props => [token, uid];
}
