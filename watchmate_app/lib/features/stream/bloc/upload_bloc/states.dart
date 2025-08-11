part of 'bloc.dart';

class UploadItem {
  final DownloadedVideo video;
  final String filename;
  final String filePath;
  final double progress;
  final bool completed;
  final bool failed;
  final String url;
  final String id;

  UploadItem({
    required this.filename,
    required this.filePath,
    this.completed = false,
    this.progress = 0.0,
    required this.video,
    this.failed = false,
    required this.url,
    required this.id,
  });

  UploadItem copyWith({
    DownloadedVideo? video,
    String? filePath,
    String? filename,
    double? progress,
    bool? completed,
    bool? failed,
    String? url,
    String? id,
  }) {
    return UploadItem(
      completed: completed ?? this.completed,
      filename: filename ?? this.filename,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      failed: failed ?? this.failed,
      video: video ?? this.video,
      url: url ?? this.url,
      id: id ?? this.id,
    );
  }
}

class UploaderState {
  final List<UploadItem> completed;
  final List<UploadItem> active;
  final List<UploadItem> queue;

  UploaderState({
    this.completed = const [],
    this.active = const [],
    this.queue = const [],
  });

  UploaderState copyWith({
    List<UploadItem>? completed,
    List<UploadItem>? active,
    List<UploadItem>? queue,
  }) {
    return UploaderState(
      completed: completed ?? this.completed,
      active: active ?? this.active,
      queue: queue ?? this.queue,
    );
  }
}
