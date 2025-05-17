import 'package:equatable/equatable.dart';

// auth_state.dart

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String username;
  final String imageUrl;

  AuthSuccess(this.username, this.imageUrl);

  @override
  List<Object> get props => [username, imageUrl];
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class SignupSuccess extends AuthState {
  final String message;

  SignupSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SignupFailure extends AuthState {
  final String message;

  SignupFailure(this.message);

  @override
  List<Object> get props => [message];
}
