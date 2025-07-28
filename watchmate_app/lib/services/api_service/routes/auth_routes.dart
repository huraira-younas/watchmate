class AuthRoutes {
  static const _name = "auth";
  late final String _endpoint;

  AuthRoutes({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String get getUser => '$_endpoint/get_user';
}
