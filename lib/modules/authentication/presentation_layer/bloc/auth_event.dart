part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginEvent extends AuthEvent {
  final String userName;
  final String password;
  final BuildContext context;
  const LoginEvent({required this.userName, required this.password, required this.context});
  @override
  List<Object?> get props => [userName, password, context];
}

class ChangeVisibilityEvent extends AuthEvent {
  const ChangeVisibilityEvent();
  @override
  List<Object?> get props => [];
}
