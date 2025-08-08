class FileApi {
  static const _name = "file";
  late final String _endpoint;

  FileApi({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String get upload => "$_endpoint/upload";
}
