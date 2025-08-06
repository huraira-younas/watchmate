import 'package:watchmate_app/utils/network_utils.dart';

class StreamApi {
  static const _name = "stream";
  late final String _endpoint;

  StreamApi({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String getStreamVideo({required String url}) {
    return '${NetworkUtils.baseUrl}$_endpoint/video/$url';
  }
}
