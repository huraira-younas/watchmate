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

class AuthLogout extends AuthEvent {}
