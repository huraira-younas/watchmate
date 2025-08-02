import 'package:watchmate_app/services/api_service/api_routes.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:watchmate_app/utils/network_utils.dart';

enum HlsResolution { f_320, f_480, f_720, f_1080 }

@immutable
class HlsModel {
  final HlsResolution resolution;
  final String filename;
  final String folder;

  const HlsModel({
    this.filename = "index.m3u8",
    required this.resolution,
    required this.folder,
  });

  String get url {
    return "${NetworkUtils.baseUrl}${ApiRoutes.stream.getStreamVideo(resolution: _parseReolution(), filename: filename, folder: folder)}";
  }

  String _parseReolution() {
    switch (resolution) {
      case HlsResolution.f_1080:
        return "f_1080";
      case HlsResolution.f_720:
        return "f_720";
      case HlsResolution.f_480:
        return "f_480";
      case HlsResolution.f_320:
        return "f_320";
    }
  }
}
