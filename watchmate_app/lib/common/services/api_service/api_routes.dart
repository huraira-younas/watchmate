import 'package:watchmate_app/common/services/api_service/apis/exports.dart';

class ApiRoutes {
  static const _prefix = "/v1/api";

  static final stream = StreamApi(pre: _prefix);
  static final video = VideoApi(pre: _prefix);
  static final auth = AuthApi(pre: _prefix);
  static final file = FileApi(pre: _prefix);
}
