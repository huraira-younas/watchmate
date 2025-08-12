class VideoApi {
  static const _name = "video";
  late final String _endpoint;

  VideoApi({required String pre}) {
    _endpoint = '$pre/$_name';
  }

  String get deleteVideo => "$_endpoint/delete_video";
  String get addVideo => "$_endpoint/add_video";
  String get getVideo => "$_endpoint/get_video";
  String get getAll => "$_endpoint/get_all";
}
