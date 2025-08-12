import 'package:share_plus/share_plus.dart';

class ShareService {
  static void shareVideoLink(String videoId) {
    final customLink = "myapp://player?id=$videoId";

    SharePlus.instance.share(
      ShareParams(text: 'check out this video $customLink'),
    );
  }

  static void shareRoomLink(String roomId) {
    final customLink = "myapp://player?id=$roomId";

    SharePlus.instance.share(
      ShareParams(text: 'Join this watch party $customLink'),
    );
  }
}
