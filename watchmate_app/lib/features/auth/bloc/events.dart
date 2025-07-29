abstract class AuthEvent {}

class AuthLogin extends AuthEvent {
  final String password;
  final String email;

  AuthLogin(this.email, this.password);
}

class AuthLogout extends AuthEvent {}
