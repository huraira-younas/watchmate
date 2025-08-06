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
  final VideoType type;
  final String userId;
  final String title;
  final int size;

  const BaseVideo({
    required this.thumbnailURL,
    required this.visibility,
    required this.duration,
    required this.videoURL,
    required this.userId,
    required this.title,
    required this.type,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
    'duration': duration.inSeconds,
    'visibility': visibility.name,
    'thumbnailURL': thumbnailURL,
    'videoURL': videoURL,
    'type': type.name,
    'userId': userId,
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
    title,
    type,
    size,
  ];
}
