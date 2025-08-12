import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async' show StreamSubscription;
import 'package:path/path.dart' as path;
import 'dart:convert' show jsonDecode;
import 'dart:io' show File;

import 'package:watchmate_app/utils/logger.dart';
part 'events.dart';
part 'states.dart';

class UploaderBloc extends Bloc<UploaderEvent, UploaderState> {
  static const maxConcurrentUploads = 3;
  late final VideoRepository _repo;
  String? _userId;

  final FileDownloader _downloader = FileDownloader();
  StreamSubscription<TaskUpdate>? _subscription;

  UploaderBloc(this._repo) : super(UploaderState()) {
    on<UploadProgress>(_onUploadProgress);
    on<StartUploads>(_onStartUploads);
    on<CancelUpload>(_onCancelUpload);
    on<AddUpload>(_onAddUpload);
    _initializeDownloader();

    on<UploadCompleted>(
      (event, emit) => _handleUploadTermination(
        taskId: event.taskId,
        videoUrl: event.url,
        completed: true,
        emit: emit,
      ),
    );

    on<UploadFailed>(
      (event, emit) => _handleUploadTermination(
        taskId: event.taskId,
        failed: true,
        emit: emit,
      ),
    );
  }

  void _initializeDownloader() {
    _downloader
        .registerCallbacks(taskNotificationTapCallback: (task, type) {})
        .configureNotificationForGroup(
          FileDownloader.defaultGroup,
          running: const TaskNotification(
            'Download {filename}',
            'File: {filename} - {progress} - speed {networkSpeed} and {timeRemaining} remaining',
          ),
          complete: const TaskNotification(
            '{displayName} download {filename}',
            'Download complete',
          ),
          error: const TaskNotification(
            'Download {filename}',
            'Download failed',
          ),
          paused: const TaskNotification(
            'Download {filename}',
            'Paused with metadata {metadata}',
          ),
          canceled: const TaskNotification('Download {filename}', 'Canceled'),
          progressBar: true,
        )
        .configureNotificationForGroup(
          'bunch',
          running: const TaskNotification(
            '{numFinished} out of {numTotal}',
            'Progress = {progress}',
          ),
          complete: const TaskNotification("Done!", "Loaded {numTotal} files"),
          error: const TaskNotification(
            'Error',
            '{numFailed}/{numTotal} failed',
          ),
          groupNotificationId: 'notGroup',
          progressBar: false,
        )
        .configureNotification(
          complete: const TaskNotification(
            'Download {filename}',
            'Download complete',
          ),
          tapOpensFile: false,
        );

    _subscription = _downloader.updates.listen((u) {
      if (u is TaskStatusUpdate) {
        switch (u.status) {
          case TaskStatus.complete:
            if (u.responseBody == null) return;
            final url = jsonDecode(u.responseBody!);
            add(UploadCompleted(taskId: u.task.taskId, url: url!));
            break;
          case TaskStatus.failed:
            add(
              UploadFailed(
                error: u.exception?.description ?? 'Unknown error',
                taskId: u.task.taskId,
              ),
            );
            break;
          default:
            break;
        }
      } else if (u is TaskProgressUpdate) {
        add(UploadProgress(taskId: u.task.taskId, progress: u.progress));
      }
    });

    _downloader.start();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> _onAddUpload(
    AddUpload event,
    Emitter<UploaderState> emit,
  ) async {
    await _getPermission();

    _userId ??= event.video.userId;
    final newItem = UploadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filename: path.basename(event.file),
      filePath: event.file,
      url: event.uploadUrl,
      video: event.video,
    );

    emit(state.copyWith(queue: [...state.queue, newItem]));
    add(StartUploads());
  }

  Future<void> _onStartUploads(
    StartUploads event,
    Emitter<UploaderState> emit,
  ) async {
    if (state.active.length >= maxConcurrentUploads || state.queue.isEmpty) {
      Logger.info(tag: "Uploader", message: "Max Reached or Queue Empty");
      return;
    }

    final availableSlots = maxConcurrentUploads - state.active.length;
    final itemsToStart = state.queue.take(availableSlots).toList();

    if (itemsToStart.isEmpty) {
      Logger.warn(tag: "Uploader", message: "Task not found to start");
      return;
    }

    Logger.info(tag: "Uploader", message: "Uploading ${itemsToStart.length}");
    final enqueued = await _enqueueUploads(itemsToStart);
    if (enqueued.isEmpty) {
      Logger.info(tag: "Uploader", message: "Enqueued is empty");
      return;
    }

    emit(
      state.copyWith(
        queue: state.queue.where((q) => !enqueued.contains(q)).toList(),
        active: [...state.active, ...enqueued],
      ),
    );
  }

  Future<List<UploadItem>> _enqueueUploads(List<UploadItem> items) async {
    List<UploadItem> result = [];
    for (final upload in items) {
      final task = UploadTask.fromFile(
        headers: {'userid': _userId!, 'folder': "videos/${upload.video.id}"},
        updates: Updates.statusAndProgress,
        file: File(upload.filePath),
        taskId: upload.id,
        url: upload.url,
        retries: 3,
      );

      if (await _downloader.enqueue(task)) {
        result.add(upload);
      }
    }
    return result;
  }

  void _onUploadProgress(UploadProgress event, Emitter<UploaderState> emit) {
    final index = state.active.indexWhere((u) => u.id == event.taskId);
    if (index == -1) return;

    Logger.info(tag: "PROGRESS", message: "${event.taskId}: ${event.progress}");
    final updated = state.active[index].copyWith(progress: event.progress);
    final updatedActive = List<UploadItem>.from(state.active)
      ..[index] = updated;

    emit(state.copyWith(active: updatedActive));
  }

  Future<void> _onCancelUpload(
    CancelUpload event,
    Emitter<UploaderState> emit,
  ) async {
    await _downloader.cancelTasksWithIds([event.taskId]);
    _removeUploadById(event.taskId, emit);
    add(StartUploads());
  }

  Future<void> _handleUploadTermination({
    required Emitter<UploaderState> emit,
    required String taskId,
    bool completed = false,
    bool failed = false,
    String? videoUrl,
  }) async {
    final index = state.active.indexWhere((u) => u.id == taskId);
    if (index == -1) return;

    final uploadItem = state.active[index];
    if (videoUrl != null && completed) {
      await _repo.addVideo(
        uploadItem.video.copyWith(videoURL: videoUrl).toJson(),
      );
    }

    _removeUploadById(
      taskId,
      emit,
      addToCompleted: uploadItem.copyWith(
        progress: completed ? 1.0 : uploadItem.progress,
        completed: completed,
        failed: failed,
      ),
    );

    add(StartUploads());
  }

  void _removeUploadById(
    String taskId,
    Emitter<UploaderState> emit, {
    UploadItem? addToCompleted,
  }) {
    emit(
      state.copyWith(
        active: state.active.where((u) => u.id != taskId).toList(),
        queue: state.queue.where((u) => u.id != taskId).toList(),
        completed: addToCompleted != null
            ? [...state.completed, addToCompleted]
            : state.completed,
      ),
    );
  }

  Future<void> _getPermission() async {
    final permissionType = PermissionType.notifications;
    var status = await FileDownloader().permissions.status(
      PermissionType.notifications,
    );
    if (status != PermissionStatus.granted) {
      if (await FileDownloader().permissions.shouldShowRationale(
        permissionType,
      )) {
        Logger.info(tag: "Permission", message: 'Showing some rationale');
      }
      status = await FileDownloader().permissions.request(permissionType);
      Logger.info(
        message: 'Permission for notification was $status',
        tag: "Permission",
      );
    }
  }
}
