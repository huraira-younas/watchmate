class StreamEvents {
  late final String _namespace;
  StreamEvents({required String namespace}) {
    _namespace = namespace;
  }

  String get downloadYT => '$_namespace:download_yt';
  String get getAll => '$_namespace:get_all';
}
