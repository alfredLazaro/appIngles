import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class ToggleAuthMode extends AuthEvent {
  const ToggleAuthMode();
  @override
  List<Object> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  const LoginSubmitted(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  const RegisterSubmitted(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class ContinueAsGuest extends AuthEvent {
  const ContinueAsGuest();
  @override
  List<Object> get props => [];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
  @override
  List<Object> get props => [];
}

class CheckAuth extends AuthEvent {
  const CheckAuth();
  @override
  List<Object> get props => [];
}