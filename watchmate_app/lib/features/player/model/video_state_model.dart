import 'package:flutter/foundation.dart' show immutable;

@immutable
class VideoState {
  final double playbackSpeed;
  final DateTime lastUpdate;
  final Duration position;
  final bool isPlaying;

  const VideoState({
    this.playbackSpeed = 1.0,
    required this.lastUpdate,
    required this.isPlaying,
    required this.position,
  });

  VideoState copyWith({
    double? playbackSpeed,
    DateTime? lastUpdate,
    Duration? position,
    bool? isPlaying,
  }) {
    return VideoState(
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      lastUpdate: lastUpdate ?? DateTime.now(),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdate': lastUpdate.toIso8601String(),
      'position': position.inMilliseconds,
      'playbackSpeed': playbackSpeed,
      'isPlaying': isPlaying,
    };
  }

  factory VideoState.fromJson(Map<String, dynamic> json) {
    return VideoState(
      lastUpdate: DateTime.tryParse(json['lastUpdate'] ?? '') ?? DateTime.now(),
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      position: Duration(milliseconds: json['position']),
      isPlaying: json['isPlaying'],
    );
  }

  @override
  String toString() {
    return 'VideoState('
        'position: ${position.inMilliseconds}ms, '
        'playbackSpeed: $playbackSpeed, '
        'lastUpdate: $lastUpdate, '
        'isPlaying: $isPlaying'
        ')';
  }
}
