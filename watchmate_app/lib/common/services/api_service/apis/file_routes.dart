import 'package:watchmate_app/utils/network_utils.dart';

class FileApi {
  static const _name = "file";
  late final String _endpoint;

  FileApi({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String get presignedUrl => "$_endpoint/presigned_url";
  String get upload => "$_endpoint/upload";

  String getFile({required String url, required String userId}) {
    if (url.contains("http")) return url;
    return '${NetworkUtils.baseUrl}$_endpoint/get_file/$userId/$url';
  }
}
