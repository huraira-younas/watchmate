part of 'bloc.dart';

enum TransferType { upload, download }

@immutable
class TransferItem {
  final DownloadedVideo video;
  final TransferType type;
  final String filename;
  final String filePath;
  final double progress;
  final bool completed;
  final bool failed;
  final String url;
  final String id;

  const TransferItem({
    required this.filename,
    required this.filePath,
    this.completed = false,
    this.progress = 0.0,
    required this.video,
    this.failed = false,
    required this.type,
    required this.url,
    required this.id,
  });

  TransferItem copyWith({
    DownloadedVideo? video,
    String? filePath,
    String? filename,
    double? progress,
    bool? completed,
    bool? failed,
    String? url,
    String? id,
  }) {
    return TransferItem(
      completed: completed ?? this.completed,
      filename: filename ?? this.filename,
      filePath: filePath ?? this.filePath,
      progress: progress ?? this.progress,
      failed: failed ?? this.failed,
      video: video ?? this.video,
      url: url ?? this.url,
      id: id ?? this.id,
      type: type,
    );
  }
}

@immutable
class TransferState {
  final List<TransferItem> completed;
  final List<TransferItem> active;
  final List<TransferItem> queue;

  const TransferState({
    this.completed = const [],
    this.active = const [],
    this.queue = const [],
  });

  TransferState copyWith({
    List<TransferItem>? completed,
    List<TransferItem>? active,
    List<TransferItem>? queue,
  }) {
    return TransferState(
      completed: completed ?? this.completed,
      active: active ?? this.active,
      queue: queue ?? this.queue,
    );
  }
}
