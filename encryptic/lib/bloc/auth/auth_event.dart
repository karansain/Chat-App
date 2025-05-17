// auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String imageUrl;

  SignupRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.imageUrl,
  });

  @override
  List<Object> get props => [username, email, password, imageUrl];
}
