import 'package:watchmate_app/common/models/video_model/downloaded_video.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';

@immutable
class PaginatedVideos extends Equatable {
  final List<DownloadedVideo> videos;
  final String? cursor;
  final bool hasMore;

  const PaginatedVideos({
    this.videos = const [],
    this.hasMore = false,
    this.cursor,
  });

  factory PaginatedVideos.fromJson(Map<String, dynamic> json) {
    return PaginatedVideos(
      cursor: json['cursor'],
      hasMore: json['hasMore'] ?? false,
      videos: (json['results'] as List<dynamic>? ?? [])
          .map((e) => DownloadedVideo.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'results': videos.map((e) => e.toJson()).toList(),
    'hasMore': hasMore,
    'cursor': cursor,
  };

  PaginatedVideos mergeNextPage(PaginatedVideos nextPage) {
    return PaginatedVideos(
      videos: [...videos, ...nextPage.videos],
      hasMore: nextPage.hasMore,
      cursor: nextPage.cursor,
    );
  }

  bool equalsTo(PaginatedVideos other) =>
      videos.every((v) => other.videos.contains(v)) &&
      videos.length == other.videos.length &&
      hasMore == other.hasMore &&
      cursor == other.cursor;

  @override
  List<Object?> get props => [hasMore, cursor, videos];

  @override
  String toString() =>
      'PaginatedVideos(cursor: $cursor, hasMore: $hasMore, videos: ${videos.length})';
}
