import 'package:watchmate_app/services/api_service/routes/exports.dart';

class ApiRoutes {
  static const _prefix = "/v1/api";

  static final auth = AuthRoutes(pre: _prefix);
}
