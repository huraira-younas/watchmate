class AuthApi {
  static const _name = "auth";
  late final String _endpoint;

  AuthApi({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String get getUser => '$_endpoint/get_user';
  String get register => '$_endpoint/sign_up';
  String get login => '$_endpoint/login';
}
