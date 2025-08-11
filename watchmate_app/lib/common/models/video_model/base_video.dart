import 'package:watchmate_app/common/models/video_model/video_user.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';

enum VideoVisibility { public, private }

enum VideoType { youtube, direct }

VideoVisibility parseVisibility(String value) {
  return VideoVisibility.values.firstWhere((v) => v.name == value);
}

VideoType parseType(String value) {
  return VideoType.values.firstWhere((v) => v.name == value);
}

@immutable
abstract class BaseVideo extends Equatable {
  final VideoVisibility visibility;
  final String thumbnailURL;
  final Duration duration;
  final String videoURL;
  final VideoUser? user;
  final VideoType type;
  final String userId;
  final double height;
  final String title;
  final double width;
  final int size;

  const BaseVideo({
    this.visibility = VideoVisibility.public,
    this.duration = Duration.zero,
    this.type = VideoType.direct,
    this.thumbnailURL = "",
    required this.userId,
    required this.height,
    required this.width,
    this.videoURL = "",
    required this.size,
    this.title = "",
    this.user,
  });

  Map<String, dynamic> toJson() => {
    'duration': duration.inSeconds,
    'visibility': visibility.name,
    'thumbnailURL': thumbnailURL,
    'videoURL': videoURL,
    'type': type.name,
    'userId': userId,
    'height': height,
    'width': width,
    'title': title,
    'size': size,
  };

  @override
  List<Object?> get props => [
    thumbnailURL,
    visibility,
    duration,
    videoURL,
    userId,
    height,
    width,
    title,
    user,
    type,
    size,
  ];

  String get sizeFormat {
    if (size >= 1 << 30) {
      return "${(size / (1 << 30)).toStringAsFixed(1)} GB";
    } else if (size >= 1 << 20) {
      return "${(size / (1 << 20)).toStringAsFixed(1)} MB";
    } else if (size >= 1 << 10) {
      return "${(size / (1 << 10)).toStringAsFixed(1)} KB";
    } else {
      return "$size B";
    }
  }
}
