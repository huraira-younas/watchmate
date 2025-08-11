import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/models/video_model/video_user.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class DownloadedVideo extends BaseVideo {
  final DateTime createdAt;
  final bool deleted;
  final String id;

  const DownloadedVideo({
    required super.height,
    required super.userId,
    required super.width,
    required super.size,
    super.thumbnailURL,
    super.visibility,
    super.videoURL,
    super.duration,
    super.title,
    super.user,
    super.type,

    required this.createdAt,
    this.deleted = false,
    required this.id,
  });

  factory DownloadedVideo.fromJson(Map<String, dynamic> json) {
    return DownloadedVideo(
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      deleted: json['deleted'] == 1 || json['deleted'] == true,
      duration: Duration(seconds: json['duration'] ?? 0),
      height: (json['height'] as num? ?? 0).toDouble(),
      visibility: parseVisibility(json['visibility']),
      width: (json['width'] as num? ?? 0).toDouble(),
      user: VideoUser.fromJson(json['user'] ?? {}),
      thumbnailURL: json['thumbnailURL'] ?? "",
      type: parseType(json['type']),
      videoURL: json['videoURL'],
      size: json['size'] ?? 0,
      userId: json['userId'],
      title: json['title'],
      id: json['id'],
    );
  }

  DownloadedVideo copyWith({
    VideoVisibility? visibility,
    String? thumbnailURL,
    DateTime? createdAt,
    Duration? duration,
    String? videoURL,
    VideoUser? user,
    VideoType? type,
    String? userId,
    double? height,
    String? title,
    bool? deleted,
    double? width,
    String? id,
    int? size,
  }) {
    return DownloadedVideo(
      thumbnailURL: thumbnailURL ?? this.thumbnailURL,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      videoURL: videoURL ?? this.videoURL,
      deleted: deleted ?? this.deleted,
      userId: userId ?? this.userId,
      height: height ?? this.height,
      width: width ?? this.width,
      title: title ?? this.title,
      user: user ?? this.user,
      type: type ?? this.type,
      size: size ?? this.size,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'deleted': deleted,
  };

  bool equalsTo(DownloadedVideo other) =>
      createdAt == other.createdAt &&
      deleted == other.deleted &&
      user == other.user &&
      id == other.id &&
      super == other;

  @override
  List<Object?> get props => [...super.props, createdAt, deleted, id];

  @override
  String toString() => 'DownloadedVideo(${toJson()})';

  String getRelativeTime() {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "yesterday";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()}w ago";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()}mo ago";
    return "${(diff.inDays / 365).floor()}y ago";
  }
}
