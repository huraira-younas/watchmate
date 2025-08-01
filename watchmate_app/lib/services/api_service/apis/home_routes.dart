class StreamApi {
  static const _name = "stream";
  late final String _endpoint;

  StreamApi({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String getStreamVideo({
    required String resolution,
    required String filename,
    required String folder,
  }) {
    return '$_endpoint/video/$folder/$resolution/$filename';
  }
}
