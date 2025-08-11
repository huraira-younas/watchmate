part of "bloc.dart";

abstract class UploaderEvent {}

class AddUpload extends UploaderEvent {
  final DownloadedVideo video;
  final String uploadUrl;
  final String file;

  AddUpload({
    required this.uploadUrl,
    required this.video,
    required this.file,
  });
}

class StartUploads extends UploaderEvent {}

class UploadProgress extends UploaderEvent {
  final double progress;
  final String taskId;

  UploadProgress({required this.taskId, required this.progress});
}

class UploadCompleted extends UploaderEvent {
  final String taskId;
  final String url;

  UploadCompleted({required this.taskId, required this.url});
}

class UploadFailed extends UploaderEvent {
  final String taskId;
  final String error;

  UploadFailed({required this.taskId, required this.error});
}

class CancelUpload extends UploaderEvent {
  final String taskId;

  CancelUpload({required this.taskId});
}
