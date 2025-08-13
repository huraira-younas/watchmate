import 'package:watchmate_app/utils/network_utils.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static void shareVideoLink(String videoId) {
    final customLink = "${NetworkUtils.baseUrl}/player?id=$videoId";

    SharePlus.instance.share(
      ShareParams(text: 'check out this video $customLink'),
    );
  }

  static void sharePartyLink(String videoId, String partyId) {
    final customLink =
        "${NetworkUtils.baseUrl}/player?id=$videoId&watchId=$partyId";

    SharePlus.instance.share(
      ShareParams(text: 'Join this watch party $customLink'),
    );
  }
}
