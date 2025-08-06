class AuthApi {
  static const _name = "auth";
  late final String _endpoint;

  AuthApi({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String get resetPassword => '$_endpoint/reset_password';
  String get verifyCode => '$_endpoint/verify_code';
  String get sendCode => '$_endpoint/send_code';
  String get register => '$_endpoint/sign_up';
  String get getUser => '$_endpoint/get';
  String get login => '$_endpoint/login';
}
