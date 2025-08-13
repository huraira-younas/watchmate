class VideoEvents {
  late final String _namespace;
  VideoEvents({required String namespace}) {
    _namespace = namespace;
  }

  String get createParty => '$_namespace:create_party';
  String get leaveParty => '$_namespace:leave_party';
  String get joinParty => '$_namespace:join_party';
}
