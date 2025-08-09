import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:watchmate_app/common/models/video_model/video_user.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class DownloadedVideo extends BaseVideo {
  final DateTime createdAt;
  final bool deleted;
  final String id;

  const DownloadedVideo({
    required super.thumbnailURL,
    required super.visibility,
    required super.duration,
    required super.videoURL,
    required super.userId,
    required super.title,
    required super.type,
    required super.size,
    required super.user,

    required this.createdAt,
    required this.deleted,
    required this.id,
  });

  factory DownloadedVideo.fromJson(Map<String, dynamic> json) {
    return DownloadedVideo(
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      deleted: json['deleted'] == 1 || json['deleted'] == true,
      duration: Duration(seconds: json['duration'] ?? 0),
      visibility: parseVisibility(json['visibility']),
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

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'deleted': deleted,
    'id': id,
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
