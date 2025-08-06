class VideoApi {
  static const _name = "video";
  late final String _endpoint;

  VideoApi({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String get getAll => "$_endpoint/get_all";
}
