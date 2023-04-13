import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';

import '../auth_user.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventSendEmailVerifaction extends AuthEvent {
  const AuthEventSendEmailVerifaction();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn(this.email, this.password);
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventCreateOrUpdateNote extends AuthEvent {
  const AuthEventCreateOrUpdateNote();
}

class AuthEventAccountRemove extends AuthEvent {
  final AuthUser? user;
  const AuthEventAccountRemove({required this.user});
}
