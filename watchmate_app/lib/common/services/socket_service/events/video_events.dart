class VideoEvents {
  late final String _namespace;
  VideoEvents({required String namespace}) {
    _namespace = namespace;
  }

  String get partyMessage => '$_namespace:party_message';
  String get reactMessage => '$_namespace:react_message';
  String get createParty => '$_namespace:create_party';
  String get videoState => '$_namespace:video_action';
  String get closeParty => '$_namespace:close_party';
  String get leaveParty => '$_namespace:leave_party';
  String get joinParty => '$_namespace:join_party';
}
