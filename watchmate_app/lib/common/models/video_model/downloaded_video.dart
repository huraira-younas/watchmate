import 'package:watchmate_app/common/models/video_model/base_video.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class DownloadedVideo extends BaseVideo {
  final DateTime createdAt;
  final bool deleted;
  final String id;

  const DownloadedVideo({
    required super.thumbnailURL,
    required super.visibility,
    required this.createdAt,
    required super.videoURL,
    required this.deleted,
    required super.userId,
    required super.title,
    required super.type,
    required this.id,
  });

  factory DownloadedVideo.fromJson(Map<String, dynamic> json) {
    return DownloadedVideo(
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      visibility: parseVisibility(json['visibility']),
      thumbnailURL: json['thumbnailURL'],
      deleted: json['deleted'] == 1,
      type: parseType(json['type']),
      videoURL: json['videoURL'],
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
      id == other.id &&
      createdAt == other.createdAt &&
      deleted == other.deleted &&
      super == other;

  @override
  List<Object?> get props => [...super.props, createdAt, deleted, id];

  @override
  String toString() => 'DownloadedVideo(${toJson()})';
}
