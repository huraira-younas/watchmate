import 'package:watchmate_app/services/api_service/apis/exports.dart';

class ApiRoutes {
  static const _prefix = "/v1/api";

  static final stream = StreamApi(pre: _prefix);
  static final auth = AuthApi(pre: _prefix);
}
