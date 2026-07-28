import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/user_session.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object> get props => [];
}

class AuthSuccess extends AuthState {
  final UserSession session;
  const AuthSuccess(this.session);
  @override
  List<Object> get props => [session];
}

class AuthGuest extends AuthState {
  const AuthGuest();
  @override
  List<Object> get props => [];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}