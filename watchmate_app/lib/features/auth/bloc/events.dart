abstract class AuthEvent {}

class AuthLogin extends AuthEvent {
  final String password;
  final String email;

  AuthLogin({required this.email, required this.password});
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
  });

  Map<String, dynamic> toJson() => {
    "password": password,
    "email": email,
    "name": name,
  };
}

class AuthGetCode extends AuthEvent {
  final String email;

  AuthGetCode({required this.email});
  Map<String, dynamic> toJson() => {"email": email};
}

class AuthVerifyCode extends AuthEvent {
  final String email;
  final String code;

  AuthVerifyCode({required this.email, required this.code});
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
  });

  Map<String, dynamic> toJson() => {
    "oldPassword": oldPassword,
    "newPassword": newPassword,
    "method": method,
    "email": email,
  };
}

class AuthLogout extends AuthEvent {}
