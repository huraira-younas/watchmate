part of "bloc.dart";

abstract class TransferEvent {}

class AddTransfer extends TransferEvent {
  final DownloadedVideo video;
  final TransferType type;
  final String uploadUrl;
  final String file;

  AddTransfer({
    required this.uploadUrl,
    required this.video,
    required this.type,
    required this.file,
  });
}

class StartTransfer extends TransferEvent {}

class TransferProgress extends TransferEvent {
  final double progress;
  final String taskId;

  TransferProgress({required this.taskId, required this.progress});
}

class TransferCompleted extends TransferEvent {
  final String? url;
  final Task task;

  TransferCompleted({required this.task, required this.url});
}

class TransferFailed extends TransferEvent {
  final String error;
  final Task task;

  TransferFailed({required this.task, required this.error});
}

class CancelTransfer extends TransferEvent {
  final String taskId;

  CancelTransfer({required this.taskId});
}
