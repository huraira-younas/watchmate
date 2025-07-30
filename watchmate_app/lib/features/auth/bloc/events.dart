import 'package:watchmate_app/features/auth/bloc/states.dart';

abstract class AuthEvent {
  final Function(CustomState error)? onError;
  final Function()? onSuccess;

  AuthEvent({required this.onSuccess, required this.onError});
}

class AuthLogin extends AuthEvent {
  final String password;
  final String email;

  AuthLogin({
    required this.password,
    required this.email,
    super.onSuccess,
    super.onError,
  });

  Map<String, dynamic> toJson() => {"email": email, "password": password};
}

class AuthRegister extends AuthEvent {
  final String password;
  final String email;
  final String name;

  AuthRegister({
    required this.password,
    required this.email,
    required this.name,
    super.onSuccess,
    super.onError,
  });

  Map<String, dynamic> toJson() => {
    "password": password,
    "email": email,
    "name": name,
  };
}

class AuthGetCode extends AuthEvent {
  final String email;

  AuthGetCode({required this.email, super.onSuccess, super.onError});
  Map<String, dynamic> toJson() => {"email": email};
}

class AuthVerifyCode extends AuthEvent {
  final String email;
  final String code;

  AuthVerifyCode({
    required this.email,
    required this.code,
    super.onSuccess,
    super.onError,
  });
  Map<String, dynamic> toJson() => {"email": email, "code": code};
}

class AuthUpdatePassword extends AuthEvent {
  final String? oldPassword;
  final String newPassword;
  final String method;
  final String email;

  AuthUpdatePassword({
    required this.newPassword,
    required this.method,
    required this.email,
    this.oldPassword,
    super.onSuccess,
    super.onError,
  });

  Map<String, dynamic> toJson() => {
    "oldPassword": oldPassword,
    "newPassword": newPassword,
    "method": method,
    "email": email,
  };
}

class AuthGetUser extends AuthEvent {
  AuthGetUser({super.onSuccess, super.onError});
}

class AuthLogout extends AuthEvent {
  AuthLogout({super.onSuccess, super.onError});
}
