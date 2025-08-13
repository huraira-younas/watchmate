import 'package:watchmate_app/common/services/socket_service/events/exports.dart';

class SocketEvents {
  static final stream = StreamEvents(namespace: "stream");
  static final video = VideoEvents(namespace: "video");
}
