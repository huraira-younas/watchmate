import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/models/video_model/video_user.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class DownloadingVideo extends BaseVideo {
  final double percent;

  const DownloadingVideo({
    required super.userId,
    required super.height,
    required super.width,
    required super.size,

    super.thumbnailURL,
    super.visibility,
    super.videoURL,
    super.duration,
    super.title,
    super.user,
    super.type,

    required this.percent,
  });

  DownloadingVideo copyWith({
    VideoVisibility? visibility,
    String? thumbnailURL,
    Duration? duration,
    String? videoURL,
    VideoUser? user,
    VideoType? type,
    double? percent,
    String? userId,
    double? height,
    double? width,
    String? title,
    int? size,
  }) {
    return DownloadingVideo(
      thumbnailURL: thumbnailURL ?? this.thumbnailURL,
      visibility: visibility ?? this.visibility,
      duration: duration ?? this.duration,
      videoURL: videoURL ?? this.videoURL,
      percent: percent ?? this.percent,
      userId: userId ?? this.userId,
      height: height ?? this.height,
      width: width ?? this.width,
      title: title ?? this.title,
      size: size ?? this.size,
      user: user ?? this.user,
      type: type ?? this.type,
    );
  }

  factory DownloadingVideo.fromJson(Map<String, dynamic> json) {
    return DownloadingVideo(
      duration: Duration(seconds: json['duration'] ?? 0),
      height: (json['height'] as num? ?? 0).toDouble(),
      width: (json['width'] as num? ?? 0).toDouble(),
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
