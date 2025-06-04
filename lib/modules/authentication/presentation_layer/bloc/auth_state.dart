part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}
class ChangeVisibilityState extends AuthState {
  final bool isVisible;
  const ChangeVisibilityState({required this.isVisible});
  @override
  List<Object> get props => [isVisible];
}
class LoginLoadingAuthState extends AuthState {
  const LoginLoadingAuthState();
  @override
  List<Object?> get props => [];
}
class LoginSuccessfulAuthState extends AuthState {
  final BuildContext context;
  const LoginSuccessfulAuthState({required this.context});
  @override
  List<Object?> get props => [context];
}
class LoginErrorAuthState extends AuthState {
  const LoginErrorAuthState();
  @override
  List<Object?> get props => [];
}