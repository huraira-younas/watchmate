import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class DownloadingVideo extends BaseVideo {
  final double downloaded;
  final double percent;
  final double total;

  const DownloadingVideo({
    required super.thumbnailURL,
    required super.visibility,
    required super.duration,
    required super.videoURL,
    required super.userId,
    required super.title,
    required super.type,
    required super.size,    

    required this.downloaded,
    required this.percent,
    required this.total,
  });

  factory DownloadingVideo.fromJson(Map<String, dynamic> json) {
    return DownloadingVideo(
      duration: Duration(seconds: json['duration'] ?? 0),
      downloaded: (json['downloaded'] ?? 0).toDouble(),
      visibility: parseVisibility(json['visibility']),
      percent: (json['percent'] ?? 0).toDouble(),
      thumbnailURL: json['thumbnailURL'] ?? "",
      total: (json['total'] ?? 0).toDouble(),
      type: parseType(json['type']),
      videoURL: json['videoURL'],
      size: json['size'] ?? 0,
      userId: json['userId'],
      title: json['title'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'downloaded': downloaded,
        'percent': percent,
        'total': total,
      };

  bool equalsTo(DownloadingVideo other) =>
      downloaded == other.downloaded &&
      percent == other.percent &&
      total == other.total &&
      super == other;

  @override
  List<Object?> get props => [...super.props, downloaded, percent, total];

  @override
  String toString() => 'DownloadingVideo(${toJson()})';
}
