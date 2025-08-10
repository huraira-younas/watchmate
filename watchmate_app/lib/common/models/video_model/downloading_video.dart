import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/models/video_model/video_user.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class DownloadingVideo extends BaseVideo {
  final double percent;

  const DownloadingVideo({
    required super.thumbnailURL,
    required super.visibility,
    required super.duration,
    required super.videoURL,
    required super.userId,
    required super.title,
    required super.type,
    required super.size,
    required super.user,

    required this.percent,
  });

  factory DownloadingVideo.fromJson(Map<String, dynamic> json) {
    return DownloadingVideo(
      duration: Duration(seconds: json['duration'] ?? 0),
      visibility: parseVisibility(json['visibility']),
      user: VideoUser.fromJson(json['user'] ?? {}),
      percent: (json['percent'] ?? 0).toDouble(),
      thumbnailURL: json['thumbnailURL'] ?? "",
      type: parseType(json['type']),
      videoURL: json['videoURL'],
      size: json['size'] ?? 0,
      userId: json['userId'],
      title: json['title'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'percent': percent};

  bool equalsTo(DownloadingVideo other) =>
      percent == other.percent && super == other;

  @override
  List<Object?> get props => [...super.props, percent];

  @override
  String toString() => 'DownloadingVideo(${toJson()})';
}
