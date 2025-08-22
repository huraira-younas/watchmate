import 'package:watchmate_app/common/repositories/video_repository.dart';
import 'package:watchmate_app/common/models/video_model/exports.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/database/db.dart';
import 'dart:async' show StreamSubscription;
import 'dart:convert' show jsonDecode;
import 'dart:io' show File;

import 'package:watchmate_app/utils/logger.dart';
part 'events.dart';
part 'states.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  static const maxConTransfers = 5;
  String? _userId;

  late final VideoRepository _repo;
  late final AppDatabase _db;

  final FileDownloader _downloader = FileDownloader();
  StreamSubscription<TaskUpdate>? _subscription;

  TransferBloc(this._repo, this._db) : super(const TransferState()) {
    on<TransferProgress>(_onTransferProgress);
    on<CancelTransfer>(_onCancelTransfer);
    on<StartTransfer>(_onStartTransfer);
    on<AddTransfer>(_onAddTransfer);
    _initializeDownloader();

    on<TransferCompleted>(
      (event, emit) => _handleTransferTermination(
        task: event.task,
        completed: true,
        url: event.url,
        emit: emit,
      ),
    );

    on<TransferFailed>(
      (event, emit) => _handleTransferTermination(
        task: event.task,
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
          paused: const TaskNotification('{displayName}', 'Paused {metadata}'),
          complete: const TaskNotification('{displayName}', 'Task complete'),
          error: const TaskNotification('{displayName}', 'Task failed'),
          canceled: const TaskNotification('{displayName}', 'Canceled'),
          progressBar: true,
          running: const TaskNotification(
            '{displayName}',
            '{progress} - {networkSpeed} - {timeRemaining} remaining',
          ),
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
          complete: const TaskNotification('{displayName}', 'Task complete'),
          tapOpensFile: false,
        );

    _subscription = _downloader.updates.listen((u) {
      if (u is TaskStatusUpdate) {
        switch (u.status) {
          case TaskStatus.complete:
            final task = u.task;
            String? url;
            if (u.responseBody != null) url = jsonDecode(u.responseBody!);
            add(TransferCompleted(task: task, url: url));

            break;
          case TaskStatus.failed:
            add(
              TransferFailed(
                error: u.exception?.description ?? 'Unknown error',
                task: u.task,
              ),
            );
            break;
          default:
            break;
        }
      } else if (u is TaskProgressUpdate) {
        add(TransferProgress(taskId: u.task.taskId, progress: u.progress));
      }
    });

    _downloader.start();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> _onAddTransfer(
    AddTransfer event,
    Emitter<TransferState> emit,
  ) async {
    await _getPermission();

    _userId ??= event.video.userId;
    final newItem = TransferItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filename: event.video.title,
      filePath: event.file,
      url: event.uploadUrl,
      video: event.video,
      type: event.type,
    );

    emit(state.copyWith(queue: [...state.queue, newItem]));
    add(StartTransfer());
  }

  Future<void> _onStartTransfer(
    StartTransfer event,
    Emitter<TransferState> emit,
  ) async {
    if (state.active.length >= maxConTransfers || state.queue.isEmpty) {
      Logger.info(tag: "Transfer", message: "Max Reached or Queue Empty");
      return;
    }

    final availableSlots = maxConTransfers - state.active.length;
    final itemsToStart = state.queue.take(availableSlots).toList();

    if (itemsToStart.isEmpty) {
      Logger.warn(tag: "Transfer", message: "Task not found to start");
      return;
    }

    Logger.info(tag: "Transfer", message: "Uploading ${itemsToStart.length}");
    final enqueued = await _enqueueUploads(itemsToStart);
    if (enqueued.isEmpty) {
      Logger.info(tag: "Transfer", message: "Enqueued is empty");
      return;
    }

    emit(
      state.copyWith(
        queue: state.queue.where((q) => !enqueued.contains(q)).toList(),
        active: [...state.active, ...enqueued],
      ),
    );
  }

  Future<List<TransferItem>> _enqueueUploads(List<TransferItem> items) async {
    List<TransferItem> result = [];

    for (final item in items) {
      Task task;
      if (item.type == TransferType.upload) {
        task = UploadTask.fromFile(
          headers: {'userid': _userId!, 'folder': "videos/${item.video.id}"},
          updates: Updates.statusAndProgress,
          displayName: item.video.title,
          file: File(item.filePath),
          httpRequestMethod: "post",
          taskId: item.id,
          url: item.url,
          retries: 3,
        );
      } else {
        task = DownloadTask(
          updates: Updates.statusAndProgress,
          displayName: item.video.title,
          url: item.video.videoURL,
          directory: 'videos',
          allowPause: true,
          taskId: item.id,
          retries: 3,
        );
      }

      if (await _downloader.enqueue(task)) {
        result.add(item);
      }
    }
    return result;
  }

  void _onTransferProgress(
    TransferProgress event,
    Emitter<TransferState> emit,
  ) {
    final index = state.active.indexWhere((u) => u.id == event.taskId);
    if (index == -1) return;

    Logger.info(tag: "PROGRESS", message: "${event.taskId}: ${event.progress}");
    final updated = state.active[index].copyWith(progress: event.progress);
    final updatedActive = List<TransferItem>.from(state.active)
      ..[index] = updated;

    emit(state.copyWith(active: updatedActive));
  }

  Future<void> _onCancelTransfer(
    CancelTransfer event,
    Emitter<TransferState> emit,
  ) async {
    await _downloader.cancelTasksWithIds([event.taskId]);
    _removeUploadById(event.taskId, emit);
    add(StartTransfer());
  }

  Future<void> _handleTransferTermination({
    required Emitter<TransferState> emit,
    bool completed = false,
    bool failed = false,
    required Task task,
    String? url,
  }) async {
    final taskId = task.taskId;
    final index = state.active.indexWhere((u) => u.id == taskId);
    if (index == -1) return;

    final uploadItem = state.active[index];
    final video = uploadItem.video;
    if (url != null && completed) {
      if (uploadItem.type == TransferType.upload) {
        await _repo.addVideo(video.copyWith(videoURL: url).toJson());
      } else {
        await _db.upsert({
          ...video.toJson(),
          "localPath": await task.filePath(),
        });
      }
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

    add(StartTransfer());
  }

  void _removeUploadById(
    String taskId,
    Emitter<TransferState> emit, {
    TransferItem? addToCompleted,
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
    final permissions = [
      PermissionType.androidSharedStorage,
      PermissionType.notifications,
    ];

    for (final permission in permissions) {
      var status = await FileDownloader().permissions.status(permission);
      if (status != PermissionStatus.granted) {
        if (await FileDownloader().permissions.shouldShowRationale(
          permission,
        )) {
          Logger.info(tag: "Permission", message: 'Showing some rationale');
        }
        status = await FileDownloader().permissions.request(permission);
        Logger.info(
          message: 'Permission for notification was $status',
          tag: "Permission",
        );
      }
    }
  }
}
